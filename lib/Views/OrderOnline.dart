import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BGrabModifier.dart';
import 'package:pawoon/Bean/BGrabOrder.dart';
import 'package:pawoon/Bean/BGrabParent.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/OrderOnlineHelper.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/BGrabStatus.dart';

import '../main.dart';
import 'Base.dart';
import 'Order.dart';

class OrderOnline extends StatefulWidget {
  @override
  _OrderOnlineState createState() => _OrderOnlineState();
}

class _OrderOnlineState extends State<OrderOnline> {
  CustomInput inputSearch;
  TextEditingController contSearch = TextEditingController();
  Dropdown2 ddStatus;
  Loader2 loader = Loader2();
  PullToRefresh pullToRefresh = PullToRefresh();
  BGrabParent parentActive;
  StreamSubscription periodicSub;

  @override
  void initState() {
    super.initState();
    contSearch.addListener(() {
      doFilter();
    });
    inputSearch = CustomInput(
      hint: "Cari Transaksi",
      controller: contSearch,
      polosan: true,
    );

    ddStatus = Dropdown2(
        list: Order.mapStatusDd,
        selected: "",
        showUnderline: false,
        onValueChanged: () {
          doFilter();
        });
    refresh();
    autoRefreshActive();
  }

  @override
  void dispose() {
    stopScheduler();
    Base.page_tag = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Base.page_tag = "orderonline";
    // Base.context = context;
    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            displayLeft: true,
            leftIcon: InkWell(
                onTap: () {
                  Helper.closePage(context);
                },
                child: Icon(Icons.clear, color: Colors.white)),
            onLeftClick: () {
          Helper.closePage(context);
        }, name: "List Order Online", displayRight: true, arrIconButtons: [
          InkWell(
              onTap: () {
                page = 1;
                refresh();
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(children: [
                    Icon(Icons.refresh),
                    Wgt.spaceLeft(5),
                    Wgt.textSecondary(context, "REFRESH", color: Colors.white)
                  ])))
        ]),
        body: body(),
        page_tag: "orderonline", broadcast: () {
      page = 1;
      refresh();
    });
  }

  Widget body() {
    return loader.isLoading
        ? Center(child: loader)
        : Container(
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
          Wgt.separator(),
          filterStatus(),
          Expanded(child: listKiri()),
        ]));
  }

  Widget filterStatus() {
    return Container(
        color: Colors.grey[100],
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: ddStatus);
  }

  Widget search() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(children: [
          Icon(Icons.search, color: Colors.grey, size: 25),
          Wgt.spaceLeft(10),
          Expanded(child: inputSearch),
        ]));
  }

  Widget listKiri() {
    return pullToRefresh.generate(
        onRefresh: () {
          page = 1;
          refresh();
        },
        // onLoading: () {
        //   page++;
        //   refresh();
        // },
        child: SingleChildScrollView(
            child: Column(children: [
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: arrGrabOrderFiltered.length,
              itemBuilder: (context, index) {
                return cellKiri(index);
              }),
          summaryKiri(),
        ])));
  }

  Widget cellKiri(index) {
    BGrabParent item = arrGrabOrderFiltered[index];
    String code = item.grab_short_order_number;
    if (code == null || code == "") {
      code = item.receipt_code;
    }

    BGrabStatus status = Order.mapStatus[item.online_order_status];
    var color = Colors.black;
    var statusText = "";
    if (status != null) {
      color = status.color;
      statusText = status.title;
    }

    bool active = false;
    active =
        parentActive != null && parentActive.receipt_code == item.receipt_code;
    return Material(
        color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
        child: InkWell(
            onTap: () => doSelectTransaksi(item),
            child: Column(children: [
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  child: Row(children: [
                    Expanded(
                        child: Wgt.textSecondary(context, "$code",
                            weight: FontWeight.w700,
                            color: active ? Colors.white : Colors.black)),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.only(left: 20),
                            child: Wgt.textSecondary(context, "$statusText",
                                color: active ? Colors.white : color))),
                  ])),
              Wgt.separator(),
            ])));
  }

  Widget summaryKiri() {
    int jumlah = 0;
    for (var item in arrGrabOrder) {
      if (item.online_order_status == "SUBMITTED") jumlah++;
    }
    if (jumlah == 0) return Container();
    return Container(
        padding: EdgeInsets.all(20),
        color: Colors.grey[100],
        child: Row(children: [
          Expanded(
            child: Wgt.text(context, "$jumlah Transaksi menunggu konfirmasi",
                color: Colors.grey[700]),
          ),
        ]));
  }

  void doSelectTransaksi(BGrabParent order) {
    parentActive = order;
    setState(() {});
  }

  /* -------------------------------------------------------------------------- */
  /*                                 PANEL KANAN                                */
  /* -------------------------------------------------------------------------- */
  Widget panelKanan() {
    if (parentActive == null) return Container();
    String statusText = "";
    var status = Order.mapStatus[parentActive.online_order_status];
    var color = Colors.grey[300];
    if (status != null) {
      statusText = status.title;
      color = status.color ?? Colors.grey[300];
    }
    String code = parentActive.grab_short_order_number;
    if (code == null || code == "") {
      code = parentActive.receipt_code;
    }
    return Column(children: [
      Expanded(
          child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey[200])),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wgt.spaceTop(10),
                    // Status
                    Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        child: Wgt.text(context, "$statusText", color: color)),
                    // order id
                    Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        color: Colors.grey[200],
                        child: Row(children: [
                          Wgt.text(context, "Order ID : $code"),
                        ])),
                    Expanded(child: listKanan()),
                    catatan(),
                    btnAction(),
                  ])))
    ]);
  }

  Widget btnAction() {
    return Container(
        child: Container(
      margin: EdgeInsets.all(20),
      child: parentActive.online_order_status == "SUBMITTED"
          ? Row(children: [
              Expanded(
                  child: Wgt.btn(context, "TOLAK PESANAN",
                      onClick: () => doTolakPesanan(),
                      transparent: true,
                      textcolor: Cons.COLOR_PRIMARY,
                      borderColor: Cons.COLOR_PRIMARY)),
              Wgt.spaceLeft(10),
              Expanded(
                  child: Wgt.btn(context, "TERIMA PESANAN",
                      onClick: () => doTerimaPesanan(),
                      color: Cons.COLOR_ACCENT)),
            ])
          : parentActive.online_order_status == "ACCEPTED"
              ? Row(children: [
                  Expanded(
                      child: Wgt.btn(context, "BATALKAN TRANSAKSI",
                          onClick: () => doCancelOrder(),
                          transparent: true,
                          borderColor: Cons.COLOR_PRIMARY,
                          textcolor: Cons.COLOR_PRIMARY))
                ])
              : Row(children: [
                  if (parentActive.online_order_status != "SUBMITTED")
                    Expanded(
                        child: Wgt.btn(context, "RIWAYAT TRANSAKSI",
                            onClick: () => doOpenHistory(),
                            color: Cons.COLOR_ACCENT))
                ]),
    ));
  }

  void doCancelOrder() {
    Helper.popupDialog(context,
        title: parentActive.grab_short_order_number,
        text:
            "Hi, jika ingin membatalkan pesanan, Silahkan menghubungi Grab Customer Service di nomor 021-8064 8777. Terima Kasih");
  }

  Widget listKanan() {
    return ListView.builder(
        // shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: parentActive.items.length,
        itemBuilder: (context, index) {
          return cellKanan(index);
        });
  }

  Widget cellKanan(index) {
    var item = parentActive.items[index];
    var totalMod = 0;
    for (var mod in item.modifiers) {
      totalMod += mod.price * mod.qty * item.qty;
    }
    return Column(children: [
      Container(
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 40, right: 40),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Qty
            Container(
              child: Container(
                  height: 60,
                  width: 60,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Cons.COLOR_ACCENT,
                      borderRadius: BorderRadius.circular(60)),
                  child: FittedBox(
                      child: Wgt.text(context, "${item.qty}",
                          color: Colors.white, weight: FontWeight.w700))),
            ),
            Wgt.spaceLeft(10),
            // Text
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Wgt.text(context, "${item.title}", weight: FontWeight.w700),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                          item.modifiers.length,
                          (index) =>
                              cellModifier(item.modifiers[index], item.qty))),
                  if (item.note != null && item.note != "")
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Row(children: [
                        Wgt.textSecondary(context, "Catatan : ",
                            color: Colors.grey[800]),
                        Wgt.textSecondary(context, " ${item.note}",
                            color: Cons.COLOR_PRIMARY, weight: FontWeight.w600),
                      ]),
                    )
                ])),
            Wgt.spaceLeft(20),
            Wgt.text(context,
                "${Helper.formatRupiahInt(item.price * item.qty + totalMod)}")
          ])),
      Wgt.separator(),
    ]);
  }

  Widget cellModifier(BGrabModifier mod, qty) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Wgt.textSecondary(context,
            "+ ${mod.title} x ${mod.qty}  ( ${Helper.formatRupiahInt(mod.price * mod.qty * qty ?? 0)} )",
            color: Colors.grey[800]));
  }

  Widget modifierNotes(BGrabModifier mod, qty) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Wgt.textSecondary(context,
            "+ ${mod.title} x ${mod.qty}  ( ${Helper.formatRupiahInt(mod.price * mod.qty * qty ?? 0)} )",
            color: Colors.grey[800]));
  }

  Widget catatan() {
    if (parentActive.note == null || parentActive.note == "")
      return Container();

    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: Colors.grey[300]),
                bottom: BorderSide(color: Colors.grey[300]))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.text(context, "Catatan :", color: Colors.grey[800]),
          Row(children: [
            Expanded(child: Wgt.text(context, parentActive.note, maxlines: 100))
          ]),
        ]));
  }

  /* -------------------------------------------------------------------------- */
  /*                                    LOGIC                                   */
  /* -------------------------------------------------------------------------- */
  int page = 1;
  int perpage = 100;
  String timestamp = "";
  List<BGrabParent> arrGrabOrder = List();
  List<BGrabParent> arrGrabOrderFiltered = List();

  Future<void> refresh({showProgress = false}) async {
    if (showProgress) Helper.showProgress(context);
    if (page == 1) {
      timestamp = Uri.encodeFull(Helper.toDate(
          datetime: DateTime.now(),
          parseToFormat: "yyyy-MM-dd'T'HH:mm:ss+00:00"));
      loader.isLoading = true;
      setState(() {});
    }
    List<Future> arrFut = List();
    // arrFut.add(loadDataWs());
    // arrFut.add(loadDataLocal());
    await loadDataLocal();
    if (arrGrabOrder.isEmpty) await loadDataWs();

    await Future.wait(arrFut);

    loader.isLoading = false;
    pullToRefresh.stopRefresh();
    Helper.hideProgress(context);

    if (arrGrabOrderFiltered.isNotEmpty) {
      parentActive = arrGrabOrderFiltered[0];
    }

    setState(() {});
  }

  Future loadDataLocal() async {
    var items = await DBPawoon().select(tablename: DBPawoon.DB_ORDER_ONLINE);
    arrGrabOrder.clear();
    for (var item in items) {
      arrGrabOrder.add(BGrabParent.fromMap(item));
    }
    doFilter();
  }

  Future<void> doRefreshActive() async {
    if (parentActive == null) return;
    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    return Logic(context).grabGetDetails(
        orderid: parentActive.id,
        outletid: outletid,
        success: (json) async {
          if (json["data"] == null) return;

          parentActive = BGrabParent.fromJson(json["data"]);
          DBPawoon().insertOrUpdate(
              data: parentActive.toMap(),
              id: "grab_short_order_number",
              tablename: DBPawoon.DB_ORDER_ONLINE);
          setState(() {});
        });
  }

  Future<void> loadDataWs() async {
    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    return Logic(context).grabGet(
        outletid: outletid,
        page: page,
        perpage: perpage,
        timestamp: timestamp,
        // timestamp: DateTime.now().millisecondsSinceEpoch,
        success: (json) {
          if (page == 1) arrGrabOrder.clear();
          timestamp = Uri.encodeFull(Helper.toDate(
              datetime: DateTime.now(),
              parseToFormat: "yyyy-MM-dd'T'HH:mm:ss+00:00"));

          if (json["data"] != null) {
            for (var item in json["data"]) {
              BGrabParent order = BGrabParent.fromJson(item);
              arrGrabOrder.add(order);
            }

            if (arrGrabOrder.length >= page * perpage &&
                json["data"].length > 0) {
              pullToRefresh.enableLoading = true;
            } else {
              pullToRefresh.enableLoading = false;
            }
          }
          doFilter();
        });
  }

  void doFilter() {
    arrGrabOrderFiltered.clear();
    String text = contSearch.text;
    if (text != null && text != "") text = text.toLowerCase();
    // print(ddStatus.selected);
    if (ddStatus.selected == "" && text == "") {
      arrGrabOrderFiltered.addAll(arrGrabOrder);
    } else {
      List<BGrabParent> temp = List();
      if (ddStatus.selected != "") {
        for (var item in arrGrabOrder) {
          var status = Order.mapStatus[item.online_order_status.toString()];
          if (status != null && status.id == ddStatus.selected) {
            temp.add(item);
          }
        }
      }else{
        temp.addAll(arrGrabOrder);
      }

      // if (temp.isEmpty) temp.addAll(arrGrabOrder);
      arrGrabOrderFiltered.addAll(temp);

      for (var item in temp) {
        if (!(text == "" ||
            item.grab_short_order_number
                .toString()
                .toLowerCase()
                .contains(text) ||
            item.receipt_code.toString().toLowerCase().contains(text))) {
          arrGrabOrderFiltered.remove(item);
        }
      }
    }

    arrGrabOrderFiltered.sort((a, b) {
      return b.timestamp.toString().compareTo(a.timestamp.toString());
    });

    setState(() {});
  }

  void doOpenHistory() {
    Helper.openPage(context, Main.HISTORY)
        .then((value) => Base.page_tag = "orderonline");
  }

  Future<void> doTolakPesanan() async {
    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    Helper.showProgress(context);
    await Logic(context)
        .grabRejectOrder(
            orderid: parentActive.id,
            outletid: outletid,
            integrationid: parentActive.integration_order_id,
            type: parentActive.sales_type.mode,
            success: (json) {
              doRefreshActive();
              OrderOnlineHelper.cancelTimer(
                  key: parentActive.grab_short_order_number);
            })
        .then((value) => Helper.hideProgress(context));
  }

  Future<void> doTerimaPesanan() async {
    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    Helper.showProgress(context);

    return Logic(context)
        .grabAcceptOrder(
            orderid: parentActive.id,
            outletid: outletid,
            integrationid: parentActive.integration_order_id,
            type: parentActive.sales_type.mode,
            success: (json) {
              doRefreshActive();
              OrderOnlineHelper.cancelTimer(
                  key: parentActive.grab_short_order_number);
            })
        .then((value) => Helper.hideProgress(context));
  }

  void autoRefreshActive() {
    periodicSub = new Stream.periodic(const Duration(seconds: 13)).listen((_) {
      doRefreshActive();
    });
  }

  void stopScheduler() {
    periodicSub.cancel();
  }
}
