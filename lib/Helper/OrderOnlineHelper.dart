import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BGrabModifier.dart';
import 'package:pawoon/Bean/BGrabParent.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Views/Base.dart';
import 'package:pawoon/Views/Order.dart';
import 'package:pawoon/Views/OrderOnline.dart';

import '../main.dart';
import 'Cons.dart';
import 'DBPawoon.dart';
import 'Helper.dart';
import 'Logic.dart';
import 'UserManager.dart';
import 'Wgt.dart';

class OrderOnlineHelper {
  static Future<void> displayOrderPush(context, message) async {
    String title = "";
    print("message : $message");

    if (message != null) {
      var from = message["from"] ?? "";
      var type = message["type"] ?? "";
      var body = json.decode(message["body"] ?? "");
      var source = body["source"] ?? "";
      var command = body["command"] ?? "";
      var transaction_id = body["transaction_id"] ?? "";
      var state = body["state"] ?? 0;
      await OrderOnlineHelper.grabOrderDetails(context,
          orderid: transaction_id, command: command, state: state);

      /*

      var outletid = await UserManager.getString(UserManager.OUTLET_ID);
      await Logic(context).grabGetStatus(
          orderid: transaction_id,
          outletid: outletid,
          success: (json) {
            // do something
          });
      */
    }
  }

  static Future confirmReceiveOrder(context, {orderid, state}) async {
    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    // Helper.showProgress(context);
    return Logic(context).grabConfirmServer(
        orderid: orderid,
        outletid: outletid,
        state: state,
        success: (json) {
          print(json);
        });
  }

  static Future grabOrderDetails(context, {orderid, command, state}) async {
    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    // Helper.showProgress(context);
    return Logic(context).grabGetDetails(
        orderid: orderid,
        outletid: outletid,
        success: (j) async {
          if (j["data"] == null) return;

          BGrabParent order = BGrabParent.fromJson(j["data"]);
          List<Future> arrFut = List();
          arrFut
              .add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
            if (value != null && value != "") {
              order.outlet = BOutlet.parseObject(json.decode(value));
            }
          }));
          arrFut.add(
              UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
            if (value != null && value != "") {
              order.op = BOperator.parseObject(json.decode(value));
            }
          }));
          arrFut
              .add(UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
            if (value != null && value != "") {
              order.device = BDevice.parseObject(json.decode(value));
            }
          }));

          await Future.wait(arrFut);
          await DBPawoon().insertOrUpdate(
              data: order.toMap(),
              id: "grab_short_order_number",
              tablename: DBPawoon.DB_ORDER_ONLINE);

          if (order.online_order_status == "ACCEPTED")
            UserManager.getBool(UserManager.SETTING_ONLINE_STRUK).then((value) {
              if (value != null && value) {
                Helper.printReceipt(context, order, showSelection: false);
              }
            });

          if (command == "new_order") {
            Helper.toastNotif(context, multigrab: true, listener: (ctx) {
              openPageOrder(ctx);
            });

            OrderOnlineHelper.startTimerWarning(context,
                order: order, command: command);
          } else if (command == "update_order") {
            Helper.toastNotif(context,
                multigrab: false,
                title:
                    "Pesanan ${order.grab_short_order_number} ${Order.mapStatus[order.online_order_status].notification}",
                listener: (ctx) {
              openPageOrder(ctx);
            });
            OrderOnlineHelper.cancelTimer(key: order.grab_short_order_number);
          }
          await OrderOnlineHelper.confirmReceiveOrder(context,
              orderid: orderid, state: state);
        });
  }

  static void startTimerWarning(context, {BGrabParent order, command}) {
    if (command == "new_order") {
      Base.mapTimerAcceptOrder[order.grab_short_order_number] =
          Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        // print("timer:${timer.tick}");

        Duration duration = Duration(seconds: 300 - timer.tick);
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
        String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

        int cond1 = 180;
        int cond2 = 240;
        int cond3 = 300;
        // 180 sec
        if (timer.tick >= cond1 && timer.tick < cond2) {
          Helper.toastNotifWarning(context,
              title:
                  "Pesanan ${order.grab_short_order_number} Belum dikonfirmasi $twoDigitMinutes:$twoDigitSeconds",
              listener: (ctx) {
            openPageOrder(ctx);
          });
        } else if (timer.tick == cond2) {
          // 240 sec
          showDialog(
              context: Base.context,
              builder: (_) => PopupWarningGrab(order: order),
              barrierDismissible: false);
        } else if (timer.tick == cond3) {
          // 300 sec
          cancelTimer(key: order.grab_short_order_number);
        }
      });
    } else {
      cancelTimer(key: order.grab_short_order_number);
    }
  }

  static void openPageOrder(ctx) {
    // if (ModalRoute.of(navigatorKey.currentContext).settings.name ==
    //     "OrderOnline") {
    Navigator.of(navigatorKey.currentContext)
        .pushNamedIfNotCurrent(Main.ORDER_ONLINE);

    /*if (Base.page_tag != "orderonline") {
      // navigatorKey.currentState.pushReplacementNamed(Main.ORDER_ONLINE);
      navigatorKey.currentState.pushNamed(Main.ORDER_ONLINE);

      // Helper.openPage(Base.context, Main.ORDER_ONLINE);
    } else {
      //   // Refresh page
      if (Base.broadcast != null) Base.broadcast();
    }*/
  }

  static void cancelTimer({key}) {
    if (Base.mapTimerAcceptOrder[key] != null) {
      Base.mapTimerAcceptOrder[key].cancel();
      Base.mapTimerAcceptOrder[key] = null;
    }
  }
}

class PopupWarningGrab extends StatefulWidget {
  BGrabParent order;
  PopupWarningGrab({this.order});

  @override
  PopupWarningGrabState createState() => PopupWarningGrabState();
}

class PopupWarningGrabState extends State<PopupWarningGrab> {
  Duration duration;
  Timer timer;

  @override
  void initState() {
    super.initState();
    BotToast.cleanAll();
    duration = Duration(
        seconds: 300 -
            Base.mapTimerAcceptOrder[widget.order.grab_short_order_number]
                .tick);

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (Base.mapTimerAcceptOrder[widget.order.grab_short_order_number] !=
          null) {
        duration = Duration(
            seconds: 300 -
                Base.mapTimerAcceptOrder[widget.order.grab_short_order_number]
                    .tick);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (duration == null) return Container();

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width * 2 / 3,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wgt.text(
                            context, "${widget.order.grab_short_order_number}",
                            weight: FontWeight.bold),
                        Wgt.textSecondary(
                            context, "$twoDigitMinutes:$twoDigitSeconds",
                            color: Colors.red),
                      ])),
              Wgt.separator(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(children: [
                            Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: Column(
                                    children: List.generate(
                                        widget.order.items.length,
                                        (index) => cell(index)))),
                            Row(children: [
                              Expanded(
                                  child: Wgt.btn(context, "TERIMA PESANAN",
                                      onClick: () => doTerimaPesanan())),
                            ]),
                            Wgt.spaceTop(20),
                            Row(children: [
                              Expanded(
                                  child: Wgt.btn(context, "TOLAK PESANAN",
                                      onClick: () => doTolakPesanan(),
                                      transparent: true,
                                      borderColor: Cons.COLOR_PRIMARY,
                                      textcolor: Cons.COLOR_PRIMARY)),
                            ]),
                          ])))),
            ])));
  }

  Widget cell(index) {
    var item = widget.order.items[index];
    return Column(children: [
      Container(
          padding: EdgeInsets.only(bottom: 20),
          child: Row(children: [
            // Qty
            Container(
                child: Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Cons.COLOR_ACCENT,
                        borderRadius: BorderRadius.circular(8000)),
                    child: FittedBox(
                        child: Wgt.text(context, "${item.qty}",
                            color: Colors.white, weight: FontWeight.w700)))),
            Wgt.spaceLeft(10),
            // Text
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Wgt.text(context, "${item.title}", weight: FontWeight.w700),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(item.modifiers.length,
                          (index) => cellModifier(item.modifiers[index]))),
                  if (item.note != null && item.note != "")
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Row(children: [
                          Wgt.textSecondary(context, "Catatan : ",
                              color: Colors.grey[800]),
                          Wgt.textSecondary(context, " ${item.note}",
                              color: Cons.COLOR_PRIMARY,
                              weight: FontWeight.w600),
                        ])),
                ])),
            // Expanded(child: Container()),
            Wgt.spaceLeft(20),
            Wgt.text(context, "${Helper.formatRupiahInt(item.price)}")
          ])),
      Wgt.separator(),
    ]);
  }

  Widget cellModifier(BGrabModifier mod) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        child: Wgt.textSecondary(context,
            "+ ${mod.title} x ${mod.qty}  ( ${Helper.formatRupiahInt(mod.price ?? 0)} )",
            color: Colors.grey[800]));
  }

  Future<void> doTolakPesanan() async {
    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    Helper.showProgress(context);
    await Logic(context)
        .grabRejectOrder(
            orderid: widget.order.id,
            outletid: outletid,
            integrationid: widget.order.integration_order_id,
            type: widget.order.sales_type.mode,
            success: (json) {
              Helper.closePage(context);
              OrderOnlineHelper.cancelTimer(
                  key: widget.order.grab_short_order_number);
            })
        .then((value) => Helper.hideProgress(context));
  }

  Future<void> doTerimaPesanan() async {
    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    Helper.showProgress(context);

    return Logic(context)
        .grabAcceptOrder(
            orderid: widget.order.id,
            outletid: outletid,
            integrationid: widget.order.integration_order_id,
            type: widget.order.sales_type.mode,
            success: (json) {
              Helper.closePage(context);
              OrderOnlineHelper.cancelTimer(
                  key: widget.order.grab_short_order_number);
            })
        .then((value) => Helper.hideProgress(context));
  }
}

extension NavigatorStateExtension on NavigatorState {
  void pushNamedIfNotCurrent(String routeName, {Object arguments}) {
    if (!isCurrent(routeName)) {
      pushNamed(routeName, arguments: arguments);
    }
  }

  bool isCurrent(String routeName) {
    bool isCurrent = false;
    popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }
}
