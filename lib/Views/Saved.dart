import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BModifierData.dart';
import 'package:pawoon/Bean/BOrder.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBHelper.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Enums.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';

class Saved extends StatefulWidget {
  Saved({Key key}) : super(key: key);

  @override
  _SavedState createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  Map<String, List<BOrderParent>> mapData = Map();
  Map<String, List<BOrderParent>> mapDataFiltered = Map();
  BOrderParent orderActive;
  CustomInput inputSearch;
  TextEditingController contSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    inputSearch = CustomInput(
      hint: "Cari Transaksi",
      controller: contSearch,
      polosan: true,
    );
    contSearch.addListener(() {
      doFilter();
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Transaksi Tersimpan"), body: body());
  }

  Widget body() {
    return Container(
        child: Row(children: [
      Expanded(flex: 1, child: panelKiri()),
      Expanded(flex: 2, child: panelKanan()),
    ]));
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KIRI                                 */
/* -------------------------------------------------------------------------- */
  Widget panelKiri() {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Column(children: [
          search(),
          Expanded(
              child: ListView.builder(
                  itemCount: mapDataFiltered.length,
                  itemBuilder: (context, index) {
                    String key = mapDataFiltered.keys.toList()[index];
                    List<BOrderParent> arr = mapDataFiltered[key];
                    return listHistory(tanggal: key, data: arr);
                  })),
        ]));
  }

  Widget search() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
        child: Row(children: [
          Icon(Icons.search, color: Colors.grey, size: 25),
          Expanded(child: inputSearch),
        ]));
  }

  void doFilter() {
    String filter = contSearch.text;
    mapDataFiltered.clear();
    if (filter == "") {
      mapDataFiltered.addAll(mapData);
      return;
    }

    filter = filter.toLowerCase();

    mapData.forEach((key, value) {
      for (BOrderParent parent in value) {
        bool ada = false;

        parent.mappingOrder.forEach((key2, value2) {
          if (value2.nameOrder.toString().toLowerCase().contains(filter)) {
            if (mapDataFiltered[key] == null) mapDataFiltered[key] = List();
            ada = true;
          }
        });

        if (ada) {
          mapDataFiltered[key].add(parent);
        }
      }
    });

    setState(() {});
  }

  Widget listHistory({tanggal, List<BOrderParent> data}) {
    String tglStr = tanggal;
    if (tglStr == Helper.toDate(datetime: DateTime.now())) {
      tglStr = "HARI INI";
    }
    return Column(children: [
      Container(
          color: Colors.grey[100],
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          child: Row(children: [
            Wgt.textSecondary(context, "$tglStr"),
            Expanded(child: Container()),
            Wgt.textSecondary(context, "${data.length} TRANSAKSI"),
          ])),
      ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            BOrderParent item = data[index];
            return cellHistory(item);
          })
    ]);
  }

  Widget cellHistory(BOrderParent item) {
    bool active = orderActive != null && orderActive == item;
    return Material(
        color: active ? Cons.COLOR_PRIMARY : Colors.white,
        child: InkWell(
            onTap: () => clickHistory(item),
            child: Column(children: [
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "Total",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context,
                              "${Helper.formatRupiahDouble(item.grandTotal)}",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : Colors.grey[800])
                        ])),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Wgt.textSecondary(context, "No. Transaksi",
                              color: active ? Colors.white : Colors.grey[500]),
                          Wgt.text(context, "${item.id}",
                              weight: FontWeight.bold,
                              color: active ? Colors.white : Colors.grey[800])
                        ]))
                  ])),
              Wgt.separator(),
            ])));
  }

  void clickHistory(BOrderParent item) {
    orderActive = item;
    setState(() {});
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KANAN                                */
/* -------------------------------------------------------------------------- */
  Widget panelKanan() {
    if (orderActive == null) return Container();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Container(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wgt.spaceTop(5),
                        Wgt.textSecondary(context, "INFORMASI TRANSAKSI"),
                        Wgt.spaceTop(15),
                        Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey[300])),
                            child: Row(children: [
                              Expanded(
                                  child: Row(children: [
                                Image.asset(
                                    "assets/ic_settings_cell_black_24dp.png",
                                    color: Colors.grey[600],
                                    height: 25),
                                Wgt.spaceLeft(10),
                                Wgt.text(context, "${orderActive.op.name}",
                                    color: Colors.grey[600]),
                              ])),
                              Expanded(
                                  child: Row(children: [
                                Image.asset("assets/ic_query_builder_24px.png",
                                    color: Colors.grey[600], height: 22),
                                Wgt.spaceLeft(10),
                                Wgt.text(context,
                                    "${Helper.toDate(timestamp: orderActive.timestamp, parseToFormat: "HH:mm")}",
                                    color: Colors.grey[600])
                              ])),
                              if (orderActive.pelanggan.name != null &&
                                  orderActive.pelanggan.name.isNotEmpty)
                                Expanded(
                                    child: Row(children: [
                                  Image.asset("assets/ic_account_box_24_px.png",
                                      color: Colors.grey[500], height: 22),
                                  Wgt.spaceLeft(10),
                                  Wgt.text(
                                      context, "${orderActive.pelanggan.name}",
                                      color: Colors.grey[600])
                                ])),
                            ])),
                        pesanan(),
                      ])))),
      summary(),
      btnActions(),
    ]);
  }

  Widget pesanan() {
    return Container(
        margin: EdgeInsets.only(top: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.textSecondary(context, "PESANAN"),
          Wgt.spaceTop(15),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: orderActive.mappingOrder.length,
              itemBuilder: (context, index) {
                String key = orderActive.mappingOrder.keys.toList()[index];
                return cellPesanan(
                    item: orderActive.mappingOrder[key], key: key);
              }),
          cellCustomAmount(),
        ]));
  }

  Widget cellPesanan({key, BOrder item}) {
    return Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                height: 50,
                width: 50,
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Cons.COLOR_ACCENT),
                child: FittedBox(
                    child:
                        Wgt.text(context, "${item.qty}", color: Colors.white))),
            Wgt.spaceLeft(20),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Wgt.spaceTop(10),
                  Row(children: [
                    Expanded(child: Wgt.text(context, "${item.nameOrder}")),
                    Wgt.spaceLeft(20),
                    Wgt.text(
                        context, "${Helper.formatRupiahInt(item.priceTotal)}"),
                  ]),
                  listModifiers(item),
                  if (item.notes != null && item.notes != "")
                    Container(
                      margin: EdgeInsets.only(top: 10),
                        child: Row(children: [
                      Wgt.text(context, "Catatan : ",
                          color: Colors.black),
                      Wgt.text(context, "${item.notes}",
                          color: Cons.COLOR_PRIMARY),
                    ])),
                ])),
          ]),
        ]));
  }

  Widget cellCustomAmount() {
    if (orderActive.customAmount == null || orderActive.customAmount.total <= 0)
      return Container();
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        padding: EdgeInsets.all(15),
        child: Column(children: [
          Row(children: [
            Wgt.text(context, "Custom Amount"),
            Expanded(child: Container()),
            Wgt.text(context,
                "${Helper.formatRupiahInt(orderActive.customAmount.total)}"),
          ]),
          orderActive.customAmount.notes != ""
              ? Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(children: [
                    Wgt.text(context, "Catatan : ", color: Colors.black),
                    Wgt.text(context, "${orderActive.customAmount.notes}",
                        color: Cons.COLOR_PRIMARY)
                  ]))
              : Container(),
        ]));
  }

  Widget listModifiers(BOrder item) {
    if (item.modifiers == null || item.modifiers.isEmpty) return Container();

    return Container(
        margin: EdgeInsets.only(top: 10),
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: item.modifiers.length,
            itemBuilder: (context, index) {
              BModifierData mod = item.modifiers[index];
              return Container(
                  child: Row(children: [
                Expanded(
                    child: Wgt.text(context, "+ ${mod.name} x ${mod.qty}")),
                Wgt.text(context,
                    "${Helper.formatRupiahInt(mod.price * mod.qty * item.qty)}"),
              ]));
            }));
  }

  Widget summary() {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[200])),
        child: Column(children: [
          rowSummary(
              text: "Tipe penjualan", isi: "${orderActive.salestype.name}"),
          rowSummary(
              text: "Subtotal",
              isi: "${Helper.formatRupiahDouble(orderActive.subtotal)}"),
          if (orderActive.serviceAmount != 0)
            rowSummary(
                text:
                    "Service Charge (${orderActive.service.toStringAsFixed(0)}%)",
                isi: "${Helper.formatRupiahDouble(orderActive.serviceAmount)}"),
          if (orderActive.taxAmount != 0)
            rowSummary(
                text: "PPN (${orderActive.tax.toStringAsFixed(0)}%)",
                isi: "${Helper.formatRupiahDouble(orderActive.taxAmount)}"),
          orderActive.pembulatan > 0
              ? rowSummary(
                  text: "Pembulatan",
                  isi: "-${Helper.formatRupiahDouble(orderActive.pembulatan)}")
              : Container(),
          rowSummary(
              text: "TOTAL",
              isi: "${Helper.formatRupiahDouble(orderActive.grandTotal)}"),
        ]));
  }

  Widget rowSummary({text, isi}) {
    return Container(
        padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
        child: Row(children: [
          Expanded(
              child: Wgt.textSecondary(context, "$text", color: Colors.black)),
          Expanded(
              child: Wgt.textSecondary(context, "$isi",
                  align: TextAlign.end, color: Colors.black)),
        ]));
  }

  Widget btnActions() {
    return Container(
        margin: EdgeInsets.all(20),
        child: Row(children: [
          Expanded(
              child: Material(
                  color: Cons.COLOR_PRIMARY,
                  child: InkWell(
                    onTap: () => doCetakStruk(orderActive),
                    child: Container(
                        padding: EdgeInsets.all(12),
                        child: Row(children: [
                          Expanded(child: Container()),
                          Image.asset("assets/ic_receipt_white.png",
                              height: 20),
                          Wgt.spaceLeft(10),
                          Wgt.text(context, "Cetak Struk",
                              size: Wgt.FONT_SIZE_NORMAL_2,
                              weight: FontWeight.bold,
                              color: Colors.white),
                          Expanded(child: Container()),
                        ])),
                  ))),
          Wgt.spaceLeft(20),
          Expanded(
              child: Material(
                  color: Cons.COLOR_ACCENT,
                  child: InkWell(
                    onTap: () => doLanjutkanTransaksi(),
                    child: Container(
                        padding: EdgeInsets.all(12),
                        child: Row(children: [
                          Expanded(child: Container()),
                          Icon(Icons.shopping_cart,
                              size: 25, color: Colors.white),
                          Wgt.spaceLeft(10),
                          Wgt.text(context, "Lanjutkan Transaksi",
                              size: Wgt.FONT_SIZE_NORMAL_2,
                              weight: FontWeight.bold,
                              color: Colors.white),
                          Expanded(child: Container()),
                        ])),
                  ))),
        ]));
  }

  void doCetakStruk(order) {
    Helper.printReceipt(context, order, showSelection: true, reprint: true);
  }

  void doLanjutkanTransaksi() {
    Helper.closePage(context, payload: orderActive);
  }

  Future<void> loadData() async {
    List<Map> list = await DBPawoon().select(tablename: DBPawoon.DB_ORDERS);
    List<BOrderParent> arrData = List();

    for (Map m in list) {
      arrData.add(BOrderParent.fromMap(m));
    }

    mapData.clear();
    mapDataFiltered.clear();

    for (BOrderParent parent in arrData) {
      String dt = Helper.toDate(timestamp: parent.timestamp);
      if (mapData[dt] == null) mapData[dt] = List();

      mapData[dt].add(parent);
    }

    mapDataFiltered.addAll(mapData);
    if (orderActive == null) {
      mapDataFiltered.forEach((key, value) {
        value.sort((a, b) {
          return b.timestamp.toString().compareTo(a.timestamp.toString());
        });
        // Kalau kosong, otomatis di pasang yang paling atas
        if (orderActive == null)
          for (var item in value) {
            orderActive = item;
            break;
          }
      });
    }
    setState(() {});
  }
}
