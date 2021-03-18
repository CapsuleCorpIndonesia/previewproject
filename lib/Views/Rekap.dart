import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BRekap.dart';
import 'package:pawoon/Bean/BRekapCashflow.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Lang.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/SyncData.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/RekapPopup.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';
import 'Order.dart';

class Rekap extends StatefulWidget {
  Rekap({Key key}) : super(key: key);

  @override
  _RekapState createState() => _RekapState();
}

class _RekapState extends State<Rekap> {
  Loader2 loader = Loader2(isLoading: false);
  Loader2 loaderKanan = Loader2(isLoading: false);
  BOutlet outlet;
  BOperator op;
  BDevice device;
  String time = "";
  List<BRekapCashflow> arrRekap = List();
  Map<String, List<BRekap>> mapData = Map();
  List<BRekapCashflow> arrCashflowIn = List();
  List<BRekapCashflow> arrCashflowOut = List();
  Map<String, BOperator> mapOperator = Map();
  bool uploading = false;
  StreamSubscription periodicSub;
  BRekap activeRekap;

  @override
  void initState() {
    super.initState();
    refresh();
    runSchedulerSync();
    time = Helper.toDate(
        datetime: DateTime.now(), parseToFormat: "dd MMM yyyy HH:mm:ss");
  }

  @override
  void dispose() {
    stopScheduler();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            name: "Kelola Kas", displayRight: true, arrIconButtons: btnRight()),
        body: body());
  }

  Widget body() {
    return loader.isLoading
        ? loader
        : InkWell(
            child: Container(
                child: Row(children: [
              Expanded(flex: 3, child: panelKiri()),
              Container(width: 1, color: Colors.grey[200]),
              Expanded(flex: 5, child: panelKanan()),
            ])),
          );
  }

  List<Widget> btnRight() {
    return <Widget>[
      InkWell(
        onTap: () => doRekap(),
        child: Container(
            height: 35,
            padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(50)),
            child: Row(children: [
              Image.asset("assets/ic_rp_blue.png"),
              Wgt.spaceLeft(10),
              Wgt.textSecondary(context, "REKAP KAS",
                  weight: FontWeight.bold, color: Cons.COLOR_PRIMARY)
            ])),
      ),
      Wgt.spaceLeft(10),
    ];
  }

  Future<void> doRekap() async {
    if (!await Helper.validateInternet(context, popup: true)) return;
    await forceSync();
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KIRI                                 */
/* -------------------------------------------------------------------------- */
  Widget panelKiri() {
    return Container(
        child: ListView.builder(
            itemCount: mapData.length,
            itemBuilder: (context, index) {
              String key = mapData.keys.toList()[index];
              return cellSection(key);
            }));
  }

  Widget cellKiri(BRekap rekap) {
    bool active = rekap == activeRekap;
    if (activeRekap != null && rekap != null)
      active = rekap.id == activeRekap.id;

    if (rekap.device_timestamp == "" && activeRekap == null) active = true;
    String status = "Terbuka";
    if (rekap.recon_code != null && rekap.recon_code != "") status = "Tertutup";

    String jam = "-";
    if (rekap.device_timestamp != "")
      jam = Helper.toDate(
          dateString: rekap.device_timestamp, parseToFormat: "HH:mm");

    String kasir = op.name;
    // print(mapOperator);
    if (rekap != null && rekap.op != null) {
      kasir = rekap.op.name;
    }

    return Material(
        color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
        child: InkWell(
            onTap: () => doClickRekap(rekap),
            child: Column(children: [
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                  child: Column(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Wgt.textSecondary(context, "Kasir",
                                    color: active
                                        ? Colors.grey[200]
                                        : Colors.grey),
                                Row(children: [
                                  Expanded(
                                      child: Wgt.text(context, "$kasir",
                                          weight: FontWeight.bold,
                                          color: active
                                              ? Colors.white
                                              : Colors.grey[800],
                                          maxlines: 100))
                                ])
                              ])),
                          Wgt.spaceLeft(10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Wgt.textSecondary(context, "Status",
                                    color: active
                                        ? Colors.grey[200]
                                        : Colors.grey),
                                Wgt.text(context, "$status",
                                    weight: FontWeight.bold,
                                    color: active
                                        ? Colors.white
                                        : Colors.grey[800]),
                              ])),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Wgt.textSecondary(context, "Jam",
                                    color: active
                                        ? Colors.grey[200]
                                        : Colors.grey),
                                Wgt.text(context, "$jam",
                                    weight: FontWeight.bold,
                                    color: active
                                        ? Colors.white
                                        : Colors.grey[800]),
                              ]))
                        ])
                  ])),
              Wgt.separator()
            ])));
  }

  Future<void> doClickRekap(BRekap rekap) async {
    this.activeRekap = rekap;
    // print("${rekap.}");
    if (rekap.id != null && rekap.id != "") {
      refreshRekapData(serverid: rekap.id);
    } else {
      this.activeRekap = null;
      setState(() {});
    }
  }

  Widget cellSection(String tag) {
    String textTag = tag;
    if (Helper.toDate(datetime: DateTime.now(), parseToFormat: "yyyy-MM-dd") ==
        tag) {
      textTag = "HARI INI";
    } else if (Helper.toDate(
            datetime: DateTime.now().subtract(Duration(days: 1)),
            parseToFormat: "yyyy-MM-dd") ==
        tag) {
      textTag = "KEMARIN";
    } else {
      textTag = Helper.toDate(dateString: tag, parseToFormat: "dd MM yyyy");
    }
    return Column(children: [
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          child: Row(children: [
            Expanded(
                child: Wgt.text(context, "$textTag", color: Colors.grey[600])),
          ]),
          color: Colors.grey[100]),
      Column(
          children: List.generate(mapData[tag].length, (index) {
        return cellKiri(mapData[tag][index]);
      }))
    ]);
  }

/* -------------------------------------------------------------------------- */
/*                                 PANEL KANAN                                */
/* -------------------------------------------------------------------------- */
  Widget panelKanan() {
    if (op == null) return Container();
    // if (activeRekap != null) return panelKananDetails();
    String name = op.name;
    if (activeRekap != null && activeRekap.op != null) {
      name = activeRekap.op.name;
    }
    return Container(
        child: Column(children: [
      Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wgt.text(context, "$name",
                  size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.bold),
              Wgt.spaceTop(5),
              Wgt.textSecondary(context, "$time", color: Colors.grey[700])
            ]),
            Expanded(child: Container()),
            if (activeRekap != null)
              Wgt.btn(context, "Cetak Struk",
                  color: Cons.COLOR_ACCENT, onClick: () => doPrintRekap()),
            if (activeRekap == null)
              Wgt.btn(context, "Kas Masuk / Keluar",
                  color: Cons.COLOR_ACCENT, onClick: () => doTambah()),
          ])),
      Wgt.separator(),
      if (activeRekap != null) panelKananDetails(),
      if (activeRekap == null)
        (arrRekap == null || arrRekap.isEmpty)
            ? Expanded(child: panelKananEmpty())
            : Expanded(child: listRekap()),
    ]));
  }

  Widget panelKananDetails() {
    return loaderKanan.isLoading
        ? loaderKanan
        : Expanded(
            child: SingleChildScrollView(
                padding:
                    EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cellKananDetails1(
                          title: "Penjualan",
                          content:
                              Helper.formatRupiahInt(activeRekap.sales_amount)),
                      cellKananDetails1(
                          title: "Void",
                          content: Helper.formatRupiahInt(
                              activeRekap.void_transactions * -1),
                          color: Colors.red),
                      cellKananDetails1(
                          title: "Penerimaan Cicilan",
                          content: Helper.formatRupiahInt(
                              activeRekap.total_installment_income)),
                      cellKananDetails1(
                          title: "Kas Masuk",
                          content: Helper.formatRupiahInt(activeRekap.cash_in),
                          list: arrCashflowIn),
                      cellKananDetails1(
                          title: "Kas Keluar",
                          content:
                              Helper.formatRupiahInt(activeRekap.cash_out * -1),
                          list: arrCashflowOut,
                          color: Colors.red),
                      Wgt.separator(marginbot: 20, margintop: 20),
                      cellKananDetails1(
                          title: "Penerimaan Sistem",
                          content: Helper.formatRupiahInt(
                              activeRekap.system_amount)),
                      Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Wgt.textSecondary(context,
                              "(Penjualan - Void + Penerimaan Cicilan + Kas Masuk - Kas Keluar)",
                              color: Colors.grey[700])),
                      cellKananDetails1(
                          title: "Penerimaan Aktual",
                          content: Helper.formatRupiahInt(
                              activeRekap.actual_income)),
                      // Cash kartu
                      Column(children: [
                        cellKananDetails2(
                            title: "Tunai",
                            content:
                                Helper.formatRupiahInt(activeRekap.total_cash)),
                        cellKananDetails2(
                            title: "Kartu",
                            content: Helper.formatRupiahInt(
                                activeRekap.total_non_cash)),
                        if (activeRekap.custom_payment_json != null)
                          Column(
                              children: List.generate(
                                  activeRekap.custom_payment_json.length,
                                  (index) => cellKananDetails2(
                                      title: activeRekap
                                          .custom_payment_json[index].name,
                                      content: Helper.formatRupiah(activeRekap
                                          .custom_payment_json[index]
                                          .amount)))),
                        if (activeRekap.integrated_payments != null)
                          Column(
                              children: List.generate(
                                  activeRekap.integrated_payments.length,
                                  (index) => cellKananDetails2(
                                      title: activeRekap
                                          .integrated_payments[index]["title"],
                                      content: Helper.formatRupiahDouble(
                                          activeRekap.integrated_payments[index]
                                              ["amount"]))))
                      ]),

                      cellKananDetails1(
                          title: "Selisih",
                          content: Helper.formatRupiahInt(
                              activeRekap.actual_income -
                                  activeRekap.system_amount)),
                      Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Wgt.textSecondary(context,
                              "(Penerimaan aktual - penerimaan sistem)",
                              color: Colors.grey[700])),
                      Wgt.separator(marginbot: 20, margintop: 20),
                      cellKananDetails1(
                          title: "Transaksi Tersimpan",
                          content: (activeRekap.total_pending_transaction)),
                      cellKananDetails1(
                          title: "Transaksi Berlangsung",
                          content:
                              (activeRekap.total_ongoing_installment_order)),
                      Wgt.spaceTop(40),
                      // Row(children: [
                      //   Expanded(
                      //       child: Wgt.btn(context, "Cetak Struk",
                      //           onClick: () => doPrintRekap(),
                      //           color: Cons.COLOR_ACCENT)),
                      // ]),
                    ])));
  }

  Future<void> doPrintRekap({BRekap rekap}) async {
    if (rekap == null) rekap = activeRekap;
    List items = await DBPawoon().select(
        tablename: DBPawoon.DB_TRANSACTION,
        whereKey: "rekapid",
        whereArgs: [rekap.id]);

    List<BOrderParent> arrOrders = List();
    for (var item in items) {
      arrOrders.add(BOrderParent.fromMap(item));
    }

    Helper.printRekap(context,
        rekap: rekap, op: op, outlet: outlet, arrOrders: arrOrders);
  }

  Widget cellKananDetails1(
      {title, content, List<BRekapCashflow> list, color = Colors.black}) {
    return Container(
        padding: EdgeInsets.only(left: 0, top: 15, bottom: 0),
        child: Column(children: [
          Row(children: [
            Wgt.text(context, "$title",
                weight: FontWeight.w600, color: Colors.black),
            Expanded(child: Container()),
            Wgt.text(context, "$content",
                weight: FontWeight.w600, color: color),
          ]),
          if (list != null)
            Column(
                children: List.generate(
                    list.length,
                    (index) => cellKananDetails2(
                        title: list[index].note,
                        color: color == Colors.black ? Colors.grey[700] : color,
                        content: Helper.formatRupiahDouble(
                            list[index].amount.toDouble())))),
        ]));
  }

  Widget cellKananDetails2({title, content, color}) {
    if (color == null) color = Colors.grey[700];
    return Container(
        padding: EdgeInsets.only(left: 20, top: 15, bottom: 0),
        child: Row(children: [
          Wgt.textSecondary(context, "$title", color: Colors.grey[700]),
          Expanded(child: Container()),
          Wgt.textSecondary(context, "$content", color: color),
        ]));
  }

  Widget panelKananEmpty() {
    return Container(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
      Expanded(child: Container()),
      Wgt.text(context, "Tidak Ada Data Kas Masuk / Keluar",
          size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.bold),
      Wgt.spaceTop(5),
      Wgt.text(context, "Anda belum pernah memasukkan data kas masuk / keluar",
          color: Colors.grey[700]),
      Wgt.spaceTop(10),
      Icon(Icons.book, size: 50, color: Colors.grey),
      Wgt.spaceTop(50),
      Expanded(child: Container()),
    ]));
  }

  Widget listRekap() {
    return Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: arrRekap.length,
                itemBuilder: (context, index) {
                  return cellRekap(rekap: arrRekap[index], index: index);
                })));
  }

  Widget cellRekap({BRekapCashflow rekap, index}) {
    String tipe;
    Color color = Colors.green[400];
    int multiplier = 1;
    if (rekap.type == Cons.KAS_MASUK) {
      tipe = Lang.KAS_MASUK;
      color = Colors.green[600];
    } else {
      tipe = Lang.KAS_KELUAR;
      color = Colors.red[600];
      multiplier = -1;
    }
    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    color:
                        (index == 0) ? Colors.grey[300] : Colors.transparent),
                left: BorderSide(color: Colors.grey[300]),
                right: BorderSide(color: Colors.grey[300]),
                bottom: BorderSide(color: Colors.grey[300]))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Wgt.textSecondary(context, "Jumlah"),
                Wgt.text(context,
                    "${Helper.formatRupiahDouble(rekap.amount * multiplier)}",
                    weight: FontWeight.w600),
              ])),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Wgt.textSecondary(context, "Tipe"),
                Wgt.text(context, "$tipe",
                    color: color, weight: FontWeight.w600),
              ])),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Wgt.textSecondary(context, "Catatan"),
                Wgt.text(context, "${rekap.note}",
                    weight: FontWeight.w600, maxlines: 5),
              ])),
          Container(
              padding: EdgeInsets.only(top: 10, left: 20),
              child: uploading && !rekap.uploaded
                  ? Container(
                      height: 20, width: 20, child: CircularProgressIndicator())
                  : Icon(Icons.check_circle,
                      color: rekap.uploaded ? Colors.green : Colors.grey[400]))
        ]));
  }

  Future<void> doTambah() async {
    // if (!await Helper.validateInternet(context, popup: true)) return;
    var item =
        await showDialog(context: context, builder: (_) => PopupRekapTambah());
    if (item != null && item["rekap"] != null) {
      arrRekap.add(item["rekap"]);
      DBPawoon().insert(
          data: item["rekap"].toMap(),
          tablename: DBPawoon.DB_RECONCILIATION_CASHFLOW);
      sort();
      setState(() {});
    }
  }

/* -------------------------------------------------------------------------- */
/*                                    LOGIC                                   */
/* -------------------------------------------------------------------------- */
  void sort() {
    arrRekap.sort((a, b) {
      return a.device_timestamp
          .toString()
          .compareTo(b.device_timestamp.toString());
    });

    // arrData.sort((a, b) {
    //   return b.device_timestamp
    //       .toString()
    //       .compareTo(a.device_timestamp.toString());
    // });
  }

  Future<void> refresh() async {
    List<Future> arrFut1 = List();
    arrFut1.add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "")
        outlet = BOutlet.parseObject(json.decode(value));
    }));
    arrFut1.add(UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null && value != "")
        op = BOperator.parseObject(json.decode(value));
    }));
    arrFut1.add(UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
      if (value != null && value != "")
        device = BDevice.parseObject(json.decode(value));
    }));

    arrRekap.clear();
    arrFut1.add(DBPawoon().select(
        tablename: DBPawoon.DB_RECONCILIATION_CASHFLOW,
        whereKey: "recon_id",
        whereArgs: [""]).then((value) {
      for (var item in value) {
        arrRekap.add(BRekapCashflow.fromMap(item));
      }
      sort();
    }));
    arrFut1
        .add(DBPawoon().select(tablename: DBPawoon.DB_RECONCILE).then((value) {
      mapData.clear();

      for (var item in value) {
        BRekap rekap = BRekap.fromMap(item);
        print("json : ${item["operator"]}");
        print("obj : ${rekap.op.name}");
        String tag = Helper.toDate(
            dateString: rekap.device_timestamp, parseToFormat: "yyyy-MM-dd");
        if (mapData[tag] == null) mapData[tag] = List();
        mapData[tag].add(rekap);
      }

      mapData.forEach((key, value) {
        value.sort((a, b) {
          return b.device_timestamp
              .toString()
              .compareTo(a.device_timestamp.toString());
        });
      });

      // Add 1 more default field
      BRekap rek = BRekap();
      String tag =
          Helper.toDate(datetime: DateTime.now(), parseToFormat: "yyyy-MM-dd");
      if (mapData[tag] == null) mapData[tag] = List();
      mapData[tag].insert(0, rek);
    }));

    arrFut1
        .add(DBPawoon().select(tablename: DBPawoon.DB_OPERATOR).then((value) {
      mapOperator.clear();
      for (var item in value) {
        BOperator o = BOperator.parseObject(item);
        mapOperator["${o.id}"] = o;
      }
    }));

    await Future.wait(arrFut1);

    // List<Future> arrFut = List();
    // arrFut.add(getRekapCashflow());
    // arrFut.add(getRekapCashCards());
    // arrFut.add(getRekapCustomPayments());
    // arrFut.add(getRekapIntegratedPayments());
    // arrFut.add(getRekapGet());

    // await Future.wait(arrFut);

    loader.isLoading = false;
    uploading = false;
    setState(() {});
  }

  Future forceSync() async {
    // Cek punya saved data
    await forceSync2();
  }

  Future<void> forceSync2() async {
    Helper.showProgress(context);

    // Sync transactions
    await SyncData.syncTransactions(context);

    // Sync cashflow
    List arr = await DBPawoon().select(
        tablename: DBPawoon.DB_RECONCILIATION_CASHFLOW,
        whereKey: "serverId",
        whereArgs: [""]);
    if (arr.isNotEmpty) {
      await syncRekap(autorefresh: true);
    }

    Helper.hideProgress(context);

    var item =
        await showDialog(context: context, builder: (_) => PopupRekapKas());
    if (item != null) {
      uploadRekap(item);
    }
  }

  Future<void> syncRekap({autorefresh = true}) async {
    List arr = await DBPawoon().select(
        tablename: DBPawoon.DB_RECONCILIATION_CASHFLOW,
        whereKey: "serverId",
        whereArgs: [""]);

    List<Map<String, dynamic>> arrData = List();
    for (var item in arr) {
      arrData.add(BRekapCashflow.fromMap(item).toJson());
    }
    if (arrData.isEmpty) {
      uploading = false;
      setState(() {});
      return;
    }

    uploading = true;
    setState(() {});

    Map<String, String> data = <String, String>{"data": json.encode(arrData)};
    List<Future> arrFut = List();

    await Logic(context).rekapSync(
        data: data,
        success: (json) async {
          for (var item in json["data"]) {
            arrFut.add(DBPawoon()
                .update(tablename: DBPawoon.DB_RECONCILIATION_CASHFLOW, data: {
              "id": item["local_id"],
              "serverId": item["id"],
              "uploaded": 1,
            }));
          }
        });

    await Future.wait(arrFut);
    if (autorefresh) refresh();
  }

  void runSchedulerSync() {
    periodicSub =
        new Stream.periodic(const Duration(milliseconds: 30000)).listen((_) {
      syncRekap();
    });
  }

  void stopScheduler() {
    periodicSub.cancel();
  }

  Future<void> uploadRekap(BRekap rekap) async {
    loader.isLoading = true;
    setState(() {});
    List<Map> list = await DBPawoon().select(tablename: DBPawoon.DB_ORDERS);
    rekap.total_pending_transaction = list.length;
    // List<Map> list = await DBPawoon().select(tablename: DBPawoon.DB_ORDERS);
    // rekap.total_pending_transaction = list.length;
    // Clipboard.setData(ClipboardData(text: "${json.encode(rekap.toJson())}"));
    // return;
    // print({"data": json.encode(rekap.toMap())});
    // print(json.encode({"data": rekap.toJson()}));

    await Logic(context).rekapUpload(
        data: json.encode({"data": rekap.toJson()}),
        success: (json) async {
          if (json["data"] != null) {
            Helper.toastSuccess(
                context, "Data kas ini telah berhasil terkirim ke server",
                title: "Data Berhasil Terkirim");

            rekap.id = json["data"]["id"];
            rekap.recon_code = json["data"]["id"];
            rekap.op = this.op;
            // print(rekap.toMap());

            await DBPawoon().insertOrUpdate(
                tablename: DBPawoon.DB_RECONCILE, data: rekap.toMap());
            // await DBPawoon().deleteAll(tablename: DBPawoon.DB_LOG_PESANAN);
            Database db = await DBPawoon().getDB();
            await db.rawQuery("DROP TABLE ${DBPawoon.DB_LOG_PESANAN}");
            await db.execute(DBPawoon.CREATE_LOG_PESANAN);
            Order.shouldRefreshOrderid = true;

            // // Helper.popupDialog(context,
            // //     title: "Data Berhasil Terkirim",
            // //     text: "Data kas ini telah berhasil terkirim ke server");
            await updateRekapCashflow(
                serverid: json["data"]["id"], recon_code: json["data"]["id"]);
            await isiTransactionsWithRekapid(rekapid: json["data"]["id"]);
            rekap.id = json["data"]["id"];
            doPopupPrint(rekap: rekap);
          } else
            Helper.toastError(context, "Rekap gagal");
        });

    loader.isLoading = false;
    setState(() {});
  }

  Future isiTransactionsWithRekapid({rekapid}) async {
    Database db = await DBPawoon().getDB();
    List items = await db.rawQuery(
        "select * from ${DBPawoon.DB_TRANSACTION} where rekapid is null");

    List<Future> arrFut = List();
    for (var item in items) {
      BOrderParent o = BOrderParent.fromMap(item);
      o.rekapid = rekapid;
      arrFut.add(DBPawoon()
          .update(tablename: DBPawoon.DB_TRANSACTION, data: o.toMap()));
    }

    return Future.wait(arrFut);
  }

  Future<void> updateRekapCashflow({serverid, recon_code}) async {
    List<Future> arrFut = List();
    for (BRekapCashflow cf in arrRekap) {
      cf.serverId = serverid;
      cf.recon_id = recon_code;
      arrFut.add(DBPawoon().update(
          tablename: DBPawoon.DB_RECONCILIATION_CASHFLOW, data: cf.toMap()));
    }

    arrFut.add(getRekap(serverid: serverid));
    return Future.wait(arrFut);
  }

  Future getRekap({serverid}) async {
    return Logic(context).rekapGet(
        outletid: serverid,
        success: (json) async {
          BRekap rekap = BRekap.fromJson(json["data"]);
          rekap.cashflow.addAll(arrRekap);
          // rekap.op = op;
          await DBPawoon().insertOrUpdate(
              tablename: DBPawoon.DB_RECONCILE, data: rekap.toMap());

          refresh();
        });
  }

  Future refreshRekapData({serverid}) async {
    BRekap rekap;
    List<Future> arrFut = List();

    loaderKanan.isLoading = true;
    setState(() {});

    arrFut.add(Logic(context).rekapGet(
        outletid: serverid,
        success: (json) async {
          // print(json);
          rekap = BRekap.fromJson(json["data"]);
          if (activeRekap != null) rekap.op = activeRekap.op;
          await DBPawoon().insertOrUpdate(
              tablename: DBPawoon.DB_RECONCILE, data: rekap.toMap());
        }));

    arrCashflowIn.clear();
    arrCashflowOut.clear();
    arrFut.add(DBPawoon().select(
        tablename: DBPawoon.DB_RECONCILIATION_CASHFLOW,
        whereKey: "serverId",
        whereArgs: ["$serverid"]).then((value) {
      for (var item in value) {
        BRekapCashflow cf = BRekapCashflow.fromMap(item);
        if (cf.type == Cons.KAS_KELUAR) {
          cf.amount *= -1;
          arrCashflowOut.add(cf);
        } else
          arrCashflowIn.add(cf);
      }
    }));

    await Future.wait(arrFut);
    activeRekap = rekap;

    loaderKanan.isLoading = false;
    setState(() {});
  }

  void doPopupPrint({BRekap rekap}) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 5,
            child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  JudulPopup(context: context, title: "Rekap Kas Berhasil"),
                  Wgt.separator(),
                  Container(
                      padding: EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 70),
                        Wgt.spaceTop(20),
                        Wgt.text(context,
                            "Apakah anda ingin mencetak struk rekap kas?",
                            align: TextAlign.center,
                            maxlines: 5,
                            size: Wgt.FONT_SIZE_NORMAL_2),
                        Wgt.spaceTop(20),
                        Row(children: [
                          Expanded(
                              child: Wgt.btn(context, "Tidak", onClick: () {
                            Helper.closePage(context);
                          })),
                          Wgt.spaceLeft(20),
                          Expanded(
                              child:
                                  Wgt.btn(context, "Cetak Struk", onClick: () {
                            doPrintRekap(rekap: rekap);
                            Helper.closePage(context);
                          }, color: Cons.COLOR_ACCENT)),
                        ])
                      ]))
                ]))));
  }
}
