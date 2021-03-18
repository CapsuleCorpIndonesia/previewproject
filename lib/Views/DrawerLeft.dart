import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BBillings.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/SyncData.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';
import 'Base.dart';
import 'Operator.dart';
import 'Order.dart';

class DrawerLeft extends StatefulWidget {
  Map<String, List<BProduct>> mapProducts = Map();
  Map<String, String> mapCategory = Map();
  DrawerLeft(
      {this.mapProducts,
      this.mapCategory,
      this.listenerUpdateData,
      this.listenerOpenSetting,
      this.listenerOpenRekap,
      this.listenerUpgrade});
  var listenerUpdateData;
  var listenerOpenSetting;
  var listenerOpenRekap;
  var listenerUpgrade;

  DrawerEnum selected = DrawerEnum.newOrder;
  @override
  _DrawerLeftState createState() => _DrawerLeftState();
}

GlobalKey keyDrawer = GlobalObjectKey("drawerKey");

class _DrawerLeftState extends State<DrawerLeft> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (billings == null) return Container();
    // bool pro = true;
    bool pro = billings.subscription_type == "paid";
    // if (billings != null && billings.subscription_type == "paid") pro = true;

    if (Order.widgetUnsync == null)
      Order.widgetUnsync = WidgetUnsync(
          listenerUpdateData: widget.listenerUpdateData,
          listenerUpdateDrawer: () async {
            // Helper.closePage(context);
          });
    return Drawer(
        key: keyDrawer,
        child: loader.isLoading
            ? loader
            : Column(children: [
                Expanded(
                    child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(children: [
                          header(),
                          cell(
                              img: "ic_cart.png",
                              text: "Transaksi Baru",
                              tag: DrawerEnum.newOrder,
                              color: Cons.COLOR_PRIMARY),
                          cell(
                              img: "ic_chrome_reader_mode_24_px.png",
                              text: "Riwayat Transaksi",
                              tag: DrawerEnum.history),
                          if (Order.permissions.contains("reconciliation"))
                            cell(
                                img: "ic_local_mall_hover_24_px.png",
                                text: "Rekap Kas",
                                tag: DrawerEnum.rekap),
                          // cell(
                          //     img: "ic_manajemen_kas_24px.png",
                          //     text: "Tambah Produk",
                          //     tag: DrawerEnum.addProduct),
                          // if (Order.permissions.contains("see_report"))
                          //   cell(
                          //       img: "ic_report.png",
                          //       text: "Laporan",
                          //       tag: DrawerEnum.laporan),
                          cell(
                              img: "ic_operator.png",
                              text: "Ganti Operator",
                              tag: DrawerEnum.changeOperator),
                          cell(
                              img: "ic_settings_blue_24dp.png",
                              text: "Pengaturan",
                              tag: DrawerEnum.settings),
                        ]))),
                if (!pro)
                  Row(children: [
                    Expanded(
                        child: Wgt.btn(context, "UPGRADE PREMIUM",
                            onClick: () => doOpenUpgrade(),
                            color: Cons.COLOR_ACCENT)),
                  ])
              ]));
  }

  Widget header() {
    return Container(
        padding: EdgeInsets.all(20),
        color: Cons.COLOR_PRIMARY,
        child: Column(children: [
          Row(children: [
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Image.asset("assets/pawoon_transparant_white.png"))),
            Expanded(child: Container()),
            Wgt.spaceLeft(20),
            memberType(),
          ]),
          Container(
              padding: EdgeInsets.only(top: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  Container(
                      width: 70,
                      child: Column(children: [
                        Image.asset("assets/ic_kasir.png"),
                        Wgt.spaceTop(5),
                        Container(
                            child: Wgt.textSecondary(context, "${op.name}",
                                align: TextAlign.center,
                                color: Colors.white,
                                weight: FontWeight.w700,
                                maxlines: 2)),
                      ])),
                  InternetStatus(),
                ]),
                Wgt.spaceLeft(15),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      lokasi(),
                      Order.widgetUnsync,
                    ]))
              ]))
        ]));
  }

  Widget lokasi() {
    return Row(children: [
      Icon(Icons.location_on, color: Colors.white),
      Wgt.spaceLeft(5),
      Wgt.textSecondary(context, "${outlet.name}",
          color: Colors.white, weight: FontWeight.normal),
    ]);
  }

  Widget memberType() {
    if (billings == null) return Container();
    String text = billings.tier;
    bool pro = billings.subscription_type == "paid";

    if (billings.subscription_type == "trial") {
      var date1 = DateTime.now();
      var date2 = Helper.parseDate(dateString: billings.trial_end_date);
      var difference = date2.difference(date1).inDays + 1;
      if (difference <= 14) {
        text = "${billings.tier} - $difference HARI";
      }
    }

    text = text.toUpperCase();

    return Container(
        child: Row(children: [
      if (pro)
        Container(
            margin: EdgeInsets.only(right: 5),
            child: Image.asset("assets/ic_star_favorite.png", height: 20)),
      Wgt.textSecondary(context, "$text",
          weight: FontWeight.bold, color: Colors.white)
    ]));
  }

  Widget cell({img, text, DrawerEnum tag, color}) {
    bool active = widget.selected == tag;
    return InkWell(
        onTap: () {
          widget.selected = tag;
          setState(() {});
          onSelected();
        },
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
            color: active ? Color(0x3000BBD4) : Colors.transparent,
            child: Row(children: [
              Image.asset("assets/$img", height: 25, color: color),
              Wgt.spaceLeft(20),
              Wgt.textSecondary(context, "$text", color: Colors.grey[800]),
            ])));
  }

  void doOpenUpgrade() {
    if (widget.listenerUpgrade != null) widget.listenerUpgrade();
    // if (billings == null) return;
    // Helper.openWeb(url: billings.upgrade_link);
  }

  void onSelected() {
    switch (widget.selected) {
      case DrawerEnum.changeOperator:
        // widget.selected = DrawerEnum.newOrder;
        Helper.closePage(context);
        Helper.openPageNoNav(context, Operator(firstPage: true));
        break;

      case DrawerEnum.history:
        Helper.closePage(context);
        Helper.openPage(context, Main.HISTORY);
        break;

      case DrawerEnum.laporan:
        Helper.closePage(context);
        Helper.openPage(context, Main.REPORT);
        break;

      case DrawerEnum.settings:
        // widget.selected = DrawerEnum.newOrder;
        Helper.closePage(context);
        if (widget.listenerOpenSetting != null) widget.listenerOpenSetting();
        break;

      case DrawerEnum.rekap:
        Helper.closePage(context);
        if (widget.listenerOpenRekap != null) widget.listenerOpenRekap();
        // Helper.openPage(context, Main.REKAP);
        break;
    }
  }

  Loader2 loader = Loader2();

  BOutlet outlet;
  BOperator op;
  BBillings billings;
  Future<void> loadData() async {
    List<Future> arrFut = List();
    arrFut.add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "")
        outlet = BOutlet.parseObject(json.decode(value));
    }));
    arrFut.add(UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null && value != "")
        op = BOperator.parseObject(json.decode(value));
    }));
    arrFut.add(UserManager.getString(UserManager.BILLING_OBJ).then((value) {
      if (value != null && value != "") {
        billings = BBillings.fromJson(json.decode(value));
      }
    }));

    await Future.wait(arrFut);
    loader.isLoading = false;
    setState(() {});
  }
}

enum DrawerEnum {
  newOrder,
  history,
  rekap,
  addProduct,
  laporan,
  changeOperator,
  settings,
}
GlobalKey<_WidgetUnsyncState> stateUnsync = new GlobalKey<_WidgetUnsyncState>();

class WidgetUnsync extends StatefulWidget {
  var listenerUpdateData;
  var listenerUpdateDrawer;
  WidgetUnsync({this.listenerUpdateData, this.listenerUpdateDrawer});

  @override
  _WidgetUnsyncState createState() {
    return _WidgetUnsyncState();
  }
}

class _WidgetUnsyncState extends State<WidgetUnsync> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        key: stateUnsync,
        child: Column(children: [
          pending(),
          btnUpdate(),
        ]));
  }

  void refresh() {
    setState(() {});
  }

  Widget pending() {
    return Container(
        padding: EdgeInsets.only(top: 5, left: 5),
        child: Wgt.textSecondary(
            context, "${SyncData.unsyncCount} transaksi belum terupdate",
            color: Colors.white));
  }

  Widget btnUpdate() {
    return InkWell(
        onTap: () async {
          doUpdateData();
        },
        child: Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            decoration: BoxDecoration(boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, blurRadius: 0.5, offset: Offset(0.0, 0.2))
            ], borderRadius: BorderRadius.circular(3), color: Colors.white),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SyncData.syncing
                  ? Container(
                      margin: EdgeInsets.only(right: 10),
                      child: SizedBox(
                          child: CircularProgressIndicator(),
                          height: 15,
                          width: 15),
                    )
                  : Container(
                      height: 25,
                      child: Image.asset("assets/ic_sync_24_px.png")),
              Wgt.spaceLeft(10),
              Wgt.textSecondary(context, "UPDATE DATA",
                  color: Cons.COLOR_PRIMARY, weight: FontWeight.bold),
            ])));
  }

  Future<void> doUpdateData() async {
    // Helper.closePage(context);

    if (!await Helper.validateInternet(context)) return;

    SyncData.syncing = true;
    setState(() {});
    try {
      await SyncData.syncMasterData(navigatorKey.currentContext, force: false);
      await SyncData.syncTransactions(navigatorKey.currentContext);
      if (widget.listenerUpdateData != null) widget.listenerUpdateData();
      if (widget.listenerUpdateDrawer != null) widget.listenerUpdateDrawer();

      Helper.toastSuccess(
          navigatorKey.currentContext, "Data berhasil diperbarui");
    } catch (e) {
      print(e);
    }
    setState(() {});
  }
}

class InternetStatus extends StatefulWidget {
  @override
  _InternetStatusState createState() => _InternetStatusState();
}

class _InternetStatusState extends State<InternetStatus> {
  bool hasInternet = true;
  @override
  void initState() {
    super.initState();
    getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: 2,
        top: 2,
        child: Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                color: hasInternet ? Colors.lightGreen : Colors.redAccent,
                borderRadius: BorderRadius.circular(20))));
  }

  void getStatus() {
    Helper.hasInternet().then((value) {
      hasInternet = value ?? false;
      setState(() {});
    });
  }
}
