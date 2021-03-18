import 'dart:convert';
import 'dart:ffi';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BLaporanKas.dart';
import 'package:pawoon/Bean/BLaporanKasDetail.dart';
import 'package:pawoon/Bean/BLaporanNote.dart';
import 'package:pawoon/Bean/BLaporanProduct.dart';
import 'package:pawoon/Bean/BLaporanSales.dart';
import 'package:pawoon/Bean/BLaporanSummary.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Lang.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

class Report extends StatefulWidget {
  Report({Key key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  Map<String, String> mapDurasi = {
    "0": "Hari Ini",
    "1": "Kemarin",
    "2": "7 Hari",
    "3": "Bulan ini",
    "4": "30 Hari",
  };
  Dropdown2 ddDurasi = Dropdown2();
  BOutlet outlet;
  String dateStart = "";
  String dateEnd = "";
  BLaporanSummary summary;
  BLaporanSales sales;
  BLaporanKas activeKas;
  BLaporanKasDetail kasDetail;

  List<BLaporanNote> arrCashIn;
  List<BLaporanNote> arrCashOut;
  List<BLaporanNote> arrCashActual;
  List<BLaporanNote> arrSalesNote;
  List<BLaporanProduct> arrSalesProduct;

  String activeSalesDetail = "";
  Loader2 loader2 = Loader2();
  Loader2 loader3 = Loader2(isLoading: false);

  @override
  void initState() {
    super.initState();
    refresh();
    ddDurasi = Dropdown2(
        list: mapDurasi,
        selected: "0",
        showUnderline: false,
        onValueChanged: () {
          changeDate();
          loadData();
        });

    changeDate();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context, appbar: Wgt.appbar(context, name: "Laporan"), body: body());
  }

  Widget body() {
    return Container(
        color: Colors.grey[100],
        child: Row(children: [
          panel1(),
          Expanded(child: panel2()),
          Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              width: 1,
              child: DottedLine(dashLength: 10, dashColor: Colors.grey[400], direction: Axis.vertical)),
          Expanded(child: panel3()),
        ]));
  }

/* -------------------------------------------------------------------------- */
/*                                   PANEL 1                                  */
/* -------------------------------------------------------------------------- */
  String activeMode = Cons.LAPORAN_SALES;
  Widget panel1() {
    return Container(
        width: 250,
        padding: EdgeInsets.all(20),
        child: Column(children: [
          kotak1(title: Lang.LAPORAN_SALES, tag: Cons.LAPORAN_SALES),
          Wgt.separator(),
          kotak1(title: Lang.LAPORAN_SUMMARY, tag: Cons.LAPORAN_SUMMARY),
          Wgt.separator(),
          kotak1(title: Lang.LAPORAN_KAS, tag: Cons.LAPORAN_KAS),
          panelOutlet(),
          panelDurasi(),
        ]));
  }

  Widget kotak1({title, tag}) {
    bool active = tag == activeMode;
    return Material(
        color: active ? Cons.COLOR_PRIMARY : Colors.white,
        child: InkWell(
            onTap: () {
              activeMode = tag;
              loadData();
              setState(() {});
            },
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                      child: Wgt.text(context, "$title", color: active ? Colors.white : Colors.black)))
            ])));
  }

  Widget panelOutlet() {
    return Row(children: [
      Expanded(
          child: Container(
              margin: EdgeInsets.only(top: 20),
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: outlet == null
                  ? Loader2()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Wgt.textSecondary(context, "Outlet"), Wgt.spaceTop(3), Wgt.text(context, "${outlet.name}")])))
    ]);
  }

  Widget panelDurasi() {
    return Container(
        margin: EdgeInsets.only(top: 20, bottom: 20),
        color: Colors.white,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(children: [
          Icon(Icons.date_range, color: Cons.COLOR_PRIMARY),
          Wgt.spaceLeft(10),
          Expanded(child: ddDurasi),
        ]));
  }

  /* -------------------------------------------------------------------------- */
  /*                                   PANEL 2                                  */
  /* -------------------------------------------------------------------------- */
  Widget panel2() {
    return Container(
        margin: EdgeInsets.only(top: 20, bottom: 20),
        color: Colors.white,
        child: loader2.isLoading
            ? Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [loader2])
            : Column(mainAxisSize: MainAxisSize.max, children: [
                bodySummary(),
                bodySales(),
                bodyKas(),
              ]));
  }

  Widget panelEmpty() {
    return Expanded(
        child: Container(
            color: Colors.grey[100],
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Expanded(child: Container()),
              Icon(Icons.receipt, size: 50, color: Colors.grey[300]),
              Wgt.spaceTop(10),
              Wgt.text(context, "Laporan tidak tersedia", color: Colors.grey[400]),
              Expanded(child: Container()),
            ])));
  }

  /* --------------------------------- SUMMARY -------------------------------- */
  Widget bodySummary() {
    if (summary == null || activeMode != Cons.LAPORAN_SUMMARY) return Container();

    if (summary.total_transaction_amount == 0) return panelEmpty();

    return Expanded(
          child: Container(
          padding: EdgeInsets.only(top: 0, bottom: 10),
          child: SingleChildScrollView(
              child: Column(children: [
            cellSummaryA(title: "Penjualan Kotor", amount: summary.sales_amount),
            cellSummaryB(title: "Diskon", amount: summary.discount_amount),
            cellSummaryB(title: "Void", amount: summary.voided_sales_amount * -1),
            cellSummaryB(title: "Penukaran Poin", amount: summary.point_amount),
            cellSummaryB(title: "Pembulatan", amount: summary.rounding_amount),
            cellSummaryA(title: "Penjualan Bersih", amount: summary.net_sales_amount),
            cellSummaryB(title: "Service Charge", amount: summary.service_amount),
            cellSummaryB(title: "Pajak", amount: summary.tax_amount),
            cellSummaryA(title: "Total Transaksi", amount: summary.total_transaction_amount),
            Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                height: 1,
                child: DottedLine(dashLength: 10, dashColor: Colors.grey[400], direction: Axis.horizontal)),
            cellSummaryA(title: "Total Penerimaan", amount: summary.total_income_amount, spacetop: 5),
          ]))),
    );
  }

  Widget cellSummaryA({title, num amount, double spacetop = 20, rupiah = true}) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: spacetop, bottom: 5),
        child: Row(children: [
          Wgt.text(context, "$title", color: Colors.grey[600]),
          Expanded(child: Container()),
          Wgt.text(context, "${rupiah ? Helper.formatRupiahInt(amount.toInt()) : amount}", weight: FontWeight.bold),
        ]));
  }

  Widget cellSummaryB({title, num amount}) {
    return Container(
        padding: EdgeInsets.only(left: 40, right: 20, top: 5, bottom: 5),
        child: Row(children: [
          Wgt.text(context, "$title"),
          Expanded(child: Container()),
          Wgt.text(context, "${Helper.formatRupiahInt(amount.toInt())}"),
        ]));
  }

  /* ---------------------------------- SALES --------------------------------- */
  Widget bodySales() {
    if (sales == null || activeMode != Cons.LAPORAN_SALES) return Container();
    if (sales.transaction_count <= 0) return panelEmpty();
    return Expanded(
        child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Column(children: [
              cellSalesA(
                  title1: "Total penjualan",
                  amount1: sales.sales_amount,
                  title2: "Total transaksi",
                  amount2: sales.transaction_count,
                  rupiah2: false),
              cellSalesA(title1: "Rata - rata", amount1: sales.sales_average, title2: "Diskon Transaksi", amount2: sales.discount_amount),
              cellSalesA(title1: "Service Charge", amount1: sales.service_amount, title2: "Diskon Produk", amount2: sales.product_discount_amount),
              cellSalesA(title1: "Pajak", amount1: sales.tax_amount),
              Wgt.spaceTop(40),
              cellSalesCustom(title: Lang.LAPORAN_METODE, tag: Cons.LAPORAN_SALES_DETAILS_PAYMENT),
              cellSalesCustom(title: Lang.LAPORAN_TERLARIS, tag: Cons.LAPORAN_SALES_DETAILS_PRODUCT),
            ])));
  }

  Widget cellSalesA({title1, num amount1, title2, num amount2, rupiah1 = true, rupiah2 = true}) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wgt.text(context, "$title1", color: Colors.grey[600]),
            Wgt.spaceTop(5),
            Wgt.text(context, "${rupiah1 ? Helper.formatRupiahInt(amount1.toInt()) : amount1}"),
          ]),
          Expanded(child: Container()),
          if (title2 != null)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Wgt.textSecondary(context, "$title2", color: Colors.grey[600]),
              Wgt.spaceTop(3),
              Wgt.text(context, "${rupiah2 ? Helper.formatRupiahInt(amount2.toInt()) : amount2}"),
            ])
        ]));
  }

  Widget cellSalesCustom({title, tag}) {
    bool active = tag == activeSalesDetail;
    return Material(
        color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
        child: InkWell(
            onTap: () {
              activeSalesDetail = tag;
              arrSalesNote = null;
              arrSalesProduct = null;
              setState(() {});

              if (activeSalesDetail == Cons.LAPORAN_SALES_DETAILS_PAYMENT)
                loadSalesPayment();
              else if (activeSalesDetail == Cons.LAPORAN_SALES_DETAILS_PRODUCT) loadSalesProduct();
            },
            child: Column(children: [
              Wgt.spaceTop(20),
              Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(children: [
                    Wgt.text(context, "$title", color: active ? Colors.white : Colors.grey),
                    Expanded(child: Container()),
                    Icon(Icons.arrow_forward_ios, color: active ? Colors.white : Colors.grey, size: 20),
                  ])),
              Wgt.spaceTop(20),
              Wgt.separator()
            ])));
  }

  /* ----------------------------------- KAS ---------------------------------- */
  Widget bodyKas() {
    if (arrKas == null || activeMode != Cons.LAPORAN_KAS) return Container();
    if (arrKas.isEmpty) return panelEmpty();

    return Expanded(
        child: Container(
            child: ListView.builder(
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: arrKas.length,
                itemBuilder: (context, index) {
                  return cellKas(arrKas[index]);
                })));
  }

  Widget cellKas(BLaporanKas item) {
    bool active = activeKas != null && activeKas.id == item.id;
    return Material(
        color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
        child: InkWell(
            onTap: () {
              activeKas = item;
              setState(() {});
              refresh3();
            },
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: EdgeInsets.all(20),
                  child: Row(children: [
                    Wgt.text(context, "${Helper.toDate(dateString: item.device_timestamp, parseToFormat: "dd MMM yyyy - HH:mm:ss")}",
                        color: active ? Colors.white : Colors.black),
                    Expanded(child: Container()),
                    Icon(Icons.arrow_forward_ios, size: 20, color: active ? Colors.white : Colors.grey),
                  ])),
              Wgt.separator(),
            ])));
  }

  /* -------------------------------------------------------------------------- */
  /*                                   PANEL 3                                  */
  /* -------------------------------------------------------------------------- */
  Widget panel3() {
    return Container(
        margin: EdgeInsets.only(top: 20, bottom: 20, right: 20),
        color: Colors.white,
        child: Column(children: [
          panel3Summary(),
          panel3Sales(),
          panel3Kas(),
        ]));
  }

  Widget panel3Summary() {
    if (summary == null || activeMode != Cons.LAPORAN_SUMMARY) return Container();

    if (summary.total_transaction_amount == 0) return panelEmpty();
    return Container();
  }

  Widget panel3Sales() {
    if (sales == null || activeMode != Cons.LAPORAN_SALES) return Container();

    if (sales.transaction_count == 0) return panelEmpty();
    return Expanded(
        child: Container(
            child: Column(children: [
      salesPayment(),
      salesProduct(),
    ])));
  }

  Widget salesPayment() {
    if (activeSalesDetail != Cons.LAPORAN_SALES_DETAILS_PAYMENT) return Container();
    return Expanded(
        child: Container(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
      if (arrSalesNote == null) Expanded(child: Container()),
      if (arrSalesNote == null && activeSalesDetail == Cons.LAPORAN_SALES_DETAILS_PAYMENT) Loader2(),
      if (arrSalesNote == null) Expanded(child: Container()),
      if (arrSalesNote != null)
        Container(
            padding: EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wgt.text(context, "Metode Pembayaran", color: Colors.grey),
              Wgt.spaceTop(10),
              Column(
                  children: List.generate(arrSalesNote.length, (index) {
                return Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                    child: Row(children: [
                      Wgt.text(context, "${arrSalesNote[index].title}"),
                      Expanded(child: Container()),
                      Wgt.text(context, "${Helper.formatRupiahInt(arrSalesNote[index].amount.toInt())}"),
                    ]));
              })),
            ]))
    ])));
  }

  Widget salesProduct() {
    if (activeSalesDetail != Cons.LAPORAN_SALES_DETAILS_PRODUCT) return Container();
    return Expanded(
        child: Container(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
      if (arrSalesProduct == null) Expanded(child: Container()),
      if (arrSalesProduct == null && activeSalesDetail == Cons.LAPORAN_SALES_DETAILS_PRODUCT) Loader2(),
      if (arrSalesProduct == null) Expanded(child: Container()),
      if (arrSalesProduct != null)
        Container(
            padding: EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wgt.text(context, "5 Produk Terlaris", color: Colors.grey),
              Wgt.spaceTop(10),
              Column(
                  children: List.generate(arrSalesProduct.length, (index) {
                return Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                    child: Row(children: [
                      Expanded(child: Wgt.text(context, "${arrSalesProduct[index].name}")),
                      Expanded(child: Wgt.text(context, "${arrSalesProduct[index].qty}", align: TextAlign.center)),
                      Expanded(child: Wgt.text(context, "${Helper.formatRupiahInt(arrSalesProduct[index].amount.toInt())}", align: TextAlign.end)),
                    ]));
              })),
            ]))
    ])));
  }

  Widget panel3Kas() {
    if (kasDetail == null || activeMode != Cons.LAPORAN_KAS) return Container();
    if (arrKas.isEmpty) return panelEmpty();

    return Expanded(
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                child: Column(children: [
                  cell3Kas(
                      title: "Waktu Mulai", isi: Helper.toDate(dateString: kasDetail.order_start_datetime, parseToFormat: "dd MMM yyyy, HH:mm:ss")),
                  cell3Kas(
                      title: "Waktu Berakhir", isi: Helper.toDate(dateString: kasDetail.order_end_datetime, parseToFormat: "dd MMM yyyy, HH:mm:ss")),
                  cell3Kas(title: "Penjualan", isi: Helper.formatRupiahInt(kasDetail.sales_amount.toInt())),
                  cell3Kas(title: "Void", isi: Helper.formatRupiahInt(kasDetail.voided_sales_amount.toInt())),
                  cell3Kas(title: "Penerimaan Cicilan", isi: Helper.formatRupiahInt(kasDetail.total_installment_income.toInt())),
                  kasAwal(),
                  kasAkhir(),
                  cell3Kas(title: "Penerimaan Sistem", isi: Helper.formatRupiahInt(kasDetail.system_income.toInt())),
                  kasActual(),
                  cell3Kas(
                      title: "Selisih",
                      isi: Helper.formatRupiahInt(kasDetail.income_differences.toInt()),
                      merah: kasDetail.income_differences.toInt() < 0,
                      ijo: kasDetail.income_differences.toInt() > 0),
                  Wgt.separator(margintop: 20, marginbot: 20),
                  cell3Kas(title: "Transaksi Tersimpan", isi: kasDetail.total_pending_transactions.toInt()),
                  cell3Kas(title: "Transaksi Berlangsung", isi: kasDetail.total_ongoing_installment_order.toInt()),
                  Wgt.separator(margintop: 20, marginbot: 20),
                ]))));
  }

  Widget cell3Kas({title, isi, merah = false, ijo = false}) {
    var color = Colors.black;
    if (merah) color = Colors.red;
    if (ijo) color = Cons.COLOR_PRIMARY;
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Row(children: [
          Wgt.text(context, "$title"),
          Expanded(child: Container()),
          Wgt.text(context, "$isi", color: color),
        ]));
  }

  Widget kasAwal() {
    return Container(
        child: ExpansionTile(
            onExpansionChanged: (opened) {
              if (opened && arrCashIn == null) loadKasIn(activeKas.id);
            },
            tilePadding: EdgeInsets.zero,
            title: Row(children: [
              Wgt.text(context, "Kas Awal"),
              Expanded(child: Container()),
              Wgt.text(context, "${Helper.formatRupiahInt(kasDetail.cashflow_in_amount.toInt())}"),
            ]),
            children: [
          if (arrCashIn == null) Loader2(),
          if (arrCashIn != null)
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                    children: List.generate(arrCashIn.length, (index) => cellIsiNote(title: arrCashIn[index].title, isi: arrCashIn[index].amount)))),
        ]));
  }

  Widget kasAkhir() {
    return Container(
        child: ExpansionTile(
            onExpansionChanged: (opened) {
              if (opened && arrCashOut == null) loadKasOut(activeKas.id);
            },
            tilePadding: EdgeInsets.zero,
            title: Row(children: [
              Wgt.text(context, "Kas Akhir"),
              Expanded(child: Container()),
              Wgt.text(context, "${Helper.formatRupiahInt(kasDetail.cashflow_out_amount.toInt())}"),
            ]),
            children: [
          if (arrCashOut == null) Loader2(),
          if (arrCashOut != null)
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                    children:
                        List.generate(arrCashOut.length, (index) => cellIsiNote(title: arrCashOut[index].title, isi: arrCashOut[index].amount)))),
        ]));
  }

  Widget kasActual() {
    return Container(
        child: ExpansionTile(
            onExpansionChanged: (opened) {
              if (opened && arrCashActual == null) loadActual(activeKas.id);
            },
            tilePadding: EdgeInsets.zero,
            title: Row(children: [
              Wgt.text(context, "Penerimaan Aktual"),
              Expanded(child: Container()),
              Wgt.text(context, "${Helper.formatRupiahInt(kasDetail.actual_income.toInt())}"),
            ]),
            children: [
          if (arrCashActual == null) Loader2(),
          if (arrCashActual != null)
            Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                    children: List.generate(
                        arrCashActual.length, (index) => cellIsiNote(title: arrCashActual[index].title, isi: arrCashActual[index].amount)))),
        ]));
  }

  Widget cellIsiNote({title, num isi}) {
    return Container(
        padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.text(context, "${title ?? "Tunai"}", color: Colors.black),
          Expanded(child: Container()),
          Wgt.spaceLeft(10),
          Wgt.text(context, "${Helper.formatRupiahInt(isi.toInt())}", color: Colors.black),
        ]));
  }

  /* -------------------------------------------------------------------------- */
  /*                                    LOGIC                                   */
  /* -------------------------------------------------------------------------- */
  Future<void> refresh() async {
    await UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "") outlet = BOutlet.parseObject(json.decode(value));
    });
    arrSalesNote = null;
    arrSalesProduct = null;
    setState(() {});
  }

  Future<void> loadData() async {
    loader2.isLoading = true;
    setState(() {});
    summary = null;
    sales = null;
    activeKas = null;
    kasDetail = null;
    arrCashIn = null;
    arrCashOut = null;
    arrCashActual = null;
    arrSalesNote = null;
    arrSalesProduct = null;
    activeSalesDetail = "";

    if (activeMode == Cons.LAPORAN_SUMMARY) {
      await loadSummary();
    } else if (activeMode == Cons.LAPORAN_SALES) {
      await loadSales();
    } else if (activeMode == Cons.LAPORAN_KAS) {
      await loadKas();
    }

    loader2.isLoading = false;
    setState(() {});
  }

  Future loadSummary() {
    return Logic(context).laporanSummary(
        start: dateStart,
        end: dateEnd,
        success: (json) {
          print(json);
          summary = BLaporanSummary.fromJson(json["data"]);
          setState(() {});
        });
  }

  Future loadSales() {
    return Logic(context).laporanSales(
        start: dateStart,
        end: dateEnd,
        success: (json) {
          sales = BLaporanSales.fromJson(json["data"]);
          setState(() {});
        });
  }

  Future loadSalesPayment() {
    return Logic(context).laporanSalesPayment(
        start: dateStart,
        end: dateEnd,
        success: (json) {
          arrSalesNote = List();
          for (var item in json["data"]) {
            arrSalesNote.add(BLaporanNote.fromJson2(item));
          }
          setState(() {});
        });
  }

  Future loadSalesProduct() {
    return Logic(context).laporanSalesProduct(
        start: dateStart,
        end: dateEnd,
        success: (json) {
          arrSalesProduct = List();
          for (var item in json["data"]) {
            arrSalesProduct.add(BLaporanProduct.fromJson(item));
          }
          setState(() {});
        });
  }

  int page = 1;
  List<BLaporanKas> arrKas = List();
  Future loadKas() {
    return Logic(context).laporanKas(
        start: dateStart,
        end: dateEnd,
        limit: 20,
        page: page,
        success: (json) {
          arrKas.clear();
          for (var item in json["data"]) {
            arrKas.add(BLaporanKas.fromJson(item));
          }
          setState(() {});
        });
  }

  Future<void> refresh3() async {
    loader3.isLoading = true;
    setState(() {});
    arrCashIn = null;
    arrCashOut = null;
    arrCashActual = null;

    if (activeMode == Cons.LAPORAN_SUMMARY) {
      // await loadSummary();
    } else if (activeMode == Cons.LAPORAN_SALES) {
      // await loadSales();
    } else if (activeMode == Cons.LAPORAN_KAS) {
      await loadKasDetail(activeKas);
    }

    loader3.isLoading = false;
    setState(() {});
  }

  Future loadKasDetail(BLaporanKas kas) {
    return Logic(context).laporanKasDetail(
        laporanid: kas.id,
        success: (json) {
          kasDetail = BLaporanKasDetail.fromJson(json["data"]);
          setState(() {});
        });
  }

  Future loadKasIn(id) {
    return Logic(context).laporanKasIn(
        id: id,
        success: (json) {
          arrCashIn = List();
          for (var item in json["data"]) {
            arrCashIn.add(BLaporanNote.fromJson(item));
          }
          setState(() {});
        });
  }

  Future loadKasOut(id) {
    return Logic(context).laporanKasOut(
        id: id,
        success: (json) {
          arrCashOut = List();
          for (var item in json["data"]) {
            arrCashOut.add(BLaporanNote.fromJson(item));
          }
          setState(() {});
        });
  }

  Future loadActual(id) {
    return Logic(context).laporanKasActual(
        id: id,
        success: (json) {
          arrCashActual = List();
          for (var item in json["data"]) {
            arrCashActual.add(BLaporanNote.fromJson(item));
          }
          setState(() {});
        });
  }

  void changeDate() {
    String format = "yyyy-MM-dd";
    switch (ddDurasi.selected) {
      case "0":
        dateStart = Helper.toDate(datetime: DateTime.now(), parseToFormat: format);
        dateEnd = Helper.toDate(datetime: DateTime.now(), parseToFormat: format);
        break;
      case "1":
        dateStart = Helper.toDate(datetime: DateTime.now().subtract(Duration(days: 1)), parseToFormat: format);
        dateEnd = Helper.toDate(datetime: DateTime.now(), parseToFormat: format);
        break;
      case "2":
        dateStart = Helper.toDate(datetime: DateTime.now().subtract(Duration(days: 7)), parseToFormat: format);
        dateEnd = Helper.toDate(datetime: DateTime.now(), parseToFormat: format);
        break;
      case "3":
        dateStart = Helper.toDate(datetime: DateTime.now(), parseToFormat: format);
        dateEnd = Helper.toDate(datetime: DateTime.now(), parseToFormat: format);
        break;
      case "4":
        dateStart = Helper.toDate(datetime: DateTime.now().subtract(Duration(days: 30)), parseToFormat: format);
        dateEnd = Helper.toDate(datetime: DateTime.now(), parseToFormat: format);
        break;
    }
  }
}
