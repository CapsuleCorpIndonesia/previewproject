import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ars_dialog/ars_dialog.dart';
import 'package:ars_dialog/ars_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BPrinter.dart';
import 'package:pawoon/Helper/OrderOnlineHelper.dart';
import 'package:pawoon/Views/Order.dart';
import 'package:pawoon/Views/PrinterWifi.dart';
import 'package:pawoon/Views/RekapPopup.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'Cons.dart';
import 'DBPawoon.dart';
import 'Logic.dart';
import 'UserManager.dart';
import 'Wgt.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

class Helper {
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<bool> validateInternet(context,
      {bool popup = true,
      title = "",
      text =
          "Anda harus terhubung dengan internet untuk mengakses fitur ini"}) async {
    if (!(await Helper.hasInternet())) {
      if (popup) Helper.popupDialog(context, text: "$text", title: title);
      // Helper.hideProgress(context);
      return false;
    }
    return true;
  }

  // -------- CURRENCY FORMAT --------
  static String formatRupiah(String text, {currency = "Rp", comma = ""}) {
    if (text == null || text == "" || text == "null") return "";
    final formatter = new NumberFormat.currency(
        locale: "id", decimalDigits: 0, symbol: "", name: "");
    // if (double.parse(text) < 0)
    //   return '($currency${formatter.format(double.parse(text))})';
    return '$currency${formatter.format(double.parse(text))}';
  }

  static String formatRupiahInt(var price, {currency = "Rp", comma = false}) {
    try {
      final formatter = new NumberFormat.currency(
          locale: "id", decimalDigits: 0, symbol: "", name: "");
      if (price.runtimeType == double) {
        return formatRupiahDouble(price, currency: currency, comma: comma);
      } else if (price.runtimeType == String) {
        return formatRupiah(price, currency: currency, comma: comma);
      }
      if (price < 0) return '-$currency${formatter.format(price.abs())}';
      return '$currency${formatter.format(price)}';
    } catch (e) {
      return "$price";
    }
  }

  static String formatRupiahDouble(var price,
      {currency = "Rp", comma = false}) {
    if (price.runtimeType == int) {
      return formatRupiahInt(price, currency: currency, comma: comma);
    } else if (price.runtimeType == String) {
      return formatRupiah(price, currency: currency, comma: comma);
    }

    final formatter = new NumberFormat.currency(
        locale: "id", decimalDigits: 0, symbol: "", name: "");
//     if (price < 0) return '($currency${formatter.format(price)})';
    if (price < 0) return '-$currency${formatter.format(price.abs())}';

    return '$currency${formatter.format(price)}';
  }

  // -------- NAVIGATION --------
  static Future openPage(context, String nav, {Map<String, dynamic> arg}) {
    return Navigator.pushNamed(context, nav, arguments: arg);
  }

  static Future openPageClass(context, Widget page,
      {Map<String, dynamic> arg}) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static openPageNoNav(context, page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (Route<dynamic> route) => false,
    );
  }

  static closePage(context, {payload}) {
    Navigator.pop(context, payload);
  }

  static closePageUntil(context, String nav) {
    Navigator.popUntil(context, ModalRoute.withName(nav));
  }

  static closePageToHome(context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static Map<String, dynamic> getPageData(context) {
    return ModalRoute.of(context).settings.arguments == null
        ? Map<String, dynamic>()
        : ModalRoute.of(context).settings.arguments;
  }

  // -------- TOAST --------
  static void toast(context, String message) {
    showToastWidget(
        Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Color(0xFFaeaeae).withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Wgt.text(context, message,
                align: TextAlign.center, color: Colors.black)),
        position: ToastPosition.bottom);
  }

  static void toastSuccess(context, String message, {title = "Success!"}) {
    showToastWidget(
        Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
                width: double.infinity - 40,
                child: Card(
                    color: Colors.transparent,
                    elevation: 2,
                    child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(children: <Widget>[
                          Icon(Icons.check_circle, color: Colors.white),
                          // Image.asset("assets/checked.png",
                          //     color: Colors.white, height: 35, width: 35),
                          SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                Wgt.text(context, "$title",
                                    weight: FontWeight.w700,
                                    color: Colors.white),
                                SizedBox(height: 0),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Wgt.textSecondary(
                                          context, "$message",
                                          color: Colors.white,
                                          weight: FontWeight.w300))
                                ])
                              ]))
                        ]))))),
        position: ToastPosition.bottom,
        context: context);
  }

  static void toastError(context, String message, {title = "Error!"}) {
    showToastWidget(
        Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
                width: double.infinity - 40,
                child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Cons.COLOR_RED,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(children: <Widget>[
                          Icon(Icons.cancel, color: Colors.white),
                          // Image.asset("assets/cancel.png",
                          // color: Colors.white, height: 25, width: 25),
                          SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                Wgt.text(context, "$title",
                                    weight: FontWeight.w700,
                                    color: Colors.white),
                                SizedBox(height: 3),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Wgt.textSecondary(
                                          context, "$message",
                                          color: Colors.white,
                                          weight: FontWeight.w300))
                                ])
                              ]))
                        ]))))),
        position: ToastPosition.bottom);
  }

  static void toastProvide(context, {message}) {
    Helper.toastError(context, message, title: "Please provide :");
  }

  static void toastPopup(context, {title, message}) {
    showToastWidget(
        Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
                width: double.infinity - 40,
                child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Cons.COLOR_PRIMARY,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: Colors.grey[300])),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                Wgt.text(context, "$title",
                                    weight: FontWeight.w700,
                                    color: Colors.white),
                                SizedBox(height: 3),
                                Row(children: <Widget>[
                                  Expanded(
                                      child: Wgt.textSecondary(
                                          context, "$message",
                                          color: Colors.white,
                                          weight: FontWeight.w300))
                                ])
                              ]))
                        ]))))),
        position: ToastPosition.bottom,
        duration: Duration(seconds: 2));
  }

  static toastNotif(context, {title = "", multigrab = false, listener}) async {
    if (title == null) title = "";
    var height = AppBar().preferredSize.height;

    BotToast.showCustomNotification(
        duration: Duration(days: 1),
        toastBuilder: (ctx) {
          return GestureDetector(
              onTap: () {
                BotToast.cleanAll();
                if (listener != null) listener(ctx);
              },
              child: Container(
                margin: EdgeInsets.only(top: height),
                  padding: EdgeInsets.all(15),
                  color: Colors.green,
                  child: Row(children: [
                    Icon(Icons.clear, color: Colors.green),
                    Wgt.spaceLeft(10),
                    if (multigrab)
                      Expanded(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Wgt.text(context, "Pesanan dari ",
                                color: Colors.white),
                            Container(
                                height: 30,
                                child: Image.asset("assets/ic_grab.png")),
                            Wgt.text(context, " telah masuk",
                                color: Colors.white),
                          ])),
                    if (!multigrab)
                      Expanded(
                          child: Wgt.text(context, "$title",
                              weight: FontWeight.w600,
                              maxlines: 2,
                              align: TextAlign.center,
                              color: Colors.white)),
                    Wgt.spaceLeft(10),
                    GestureDetector(
                        onTap: () {
                          BotToast.cleanAll();
                        },
                        child: Icon(Icons.clear, color: Colors.white)),
                  ])));
        });
  }

  static toastNotifWarning(context,
      {title = "", multigrab = false, listener}) async {
    if (title == null) title = "";
    BotToast.showCustomNotification(
        wrapToastAnimation: null,
        enableSlideOff: false,
        // animationDuration: Duration(seconds: 0),
        duration: Duration(days: 1),
        toastBuilder: (ctx) {
          return GestureDetector(
              onTap: () {
                BotToast.cleanAll();
                if (listener != null) listener(ctx);
              },
              child: Container(
                  padding: EdgeInsets.all(15),
                  color: Colors.red[400],
                  child: Row(children: [
                    Icon(Icons.clear, color: Colors.red[400]),
                    Wgt.spaceLeft(10),
                    if (multigrab)
                      Expanded(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Wgt.text(context, "Pesanan dari ",
                                color: Colors.white),
                            Container(
                                height: 30,
                                child: Image.asset("assets/ic_grab.png")),
                            Wgt.text(context, " telah masuk",
                                color: Colors.white),
                          ])),
                    if (!multigrab)
                      Expanded(
                          child: Wgt.text(context, "$title",
                              weight: FontWeight.w600,
                              maxlines: 2,
                              align: TextAlign.center,
                              color: Colors.white)),
                    Wgt.spaceLeft(10),
                    GestureDetector(
                        onTap: () {
                          BotToast.cleanAll();
                        },
                        child: Icon(Icons.clear, color: Colors.white)),
                  ])));
        });
  }

  // -------- POPUP --------
  static void confirm(context, String title, String text,
      ListenerConfirm confirm, ListenerCancel cancel,
      {image = "logo.png", textOk = "OK", textCancel = "Cancel"}) {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(title: new Text(title), content: new Text(text), actions: <Widget>[
//            FlatButton(
//                child: Wgt.text(context, "No", color: Colors.blue),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                  if (cancel != null) cancel();
//                }),
//            FlatButton(
//                child: Wgt.text(context, "Yes", color: Colors.blue),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                  confirm();
//                })
//          ]);
//        });
    ImbDialog.show(context,
        titleText: title,
        descText: text,
        confirmListener: confirm,
        cancelListener: cancel,
        btnCancelText: textCancel,
        btnConfirmText: textOk,
        image: image);
  }

  static void popupDialog(context,
      {text, title, image = "logo.png", descAlignment = TextAlign.center}) {
    // flutter defined function
    ImbDialog.show(context,
        titleText: title,
        descText: text,
        image: image,
        descAlignment: descAlignment);
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          // return object of type Dialog
//          return AlertDialog(
//              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: BorderSide(style: BorderStyle.solid)),
//              content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
//                title != null ? Wgt.textLarge(context, title, weight: FontWeight.w700) : Container(),
//                title != null ? Wgt.spaceTop(10) : Container(),
//                Wgt.text(context, "$text")
//              ]),
//              actions: <Widget>[
//                // usually buttons at the bottom of the dialog
//                FlatButton(
//                    child: Text("Close"),
//                    onPressed: () {
//                      Navigator.of(context).pop();
//                    })
//              ]);
//        });
  }

  static void popupSlide(context, {title, text}) {
    slideDialog.showSlideDialog(
      barrierDismissible: true,
      context: context,
      child: Row(children: <Widget>[
        Wgt.spaceLeft(20),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Wgt.textLarge(context, title, weight: FontWeight.bold),
              Wgt.spaceTop(5),
              Wgt.text(context, text),
            ])),
        Wgt.spaceLeft(20)
      ]),
      barrierColor: Colors.white.withOpacity(0.9),
      pillColor: Colors.grey,
      backgroundColor: Colors.white,
    );
  }

  static void selection(context,
      {selections, success, title = "Please select"}) {
    List<Widget> arrWidget = List();
    selections.forEach((key, value) {
      arrWidget.add(InkWell(
          child: Row(children: <Widget>[
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(bottom: 10, top: 10),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Wgt.text(context, value, color: Colors.black)))
          ]),
          onTap: () {
            success(key);
            Navigator.of(context).pop();
          }));
    });
    // flutter defined function
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return alert dialog object
          return AlertDialog(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wgt.text(context, title, color: Colors.grey)
                  ]),
              content: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: arrWidget),
              ));
        });
  }

  static void popupInput(context, String title, ListenerString listener,
      {String hint, TextInputType type = TextInputType.text}) {
    var ctr = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: SizedBox(
                  width: double.infinity,
                  child: Wgt.edittext(context,
                      hint: hint,
                      displayTopHint: false,
                      controller: ctr,
                      type: type)),
              actions: <Widget>[
                FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                    child: new Text(
                      'OK',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      listener(ctr.text);
                    })
              ]);
        });
  }

  static String formatISOTime(String date) {
    final iso = date.toString();
    if (iso.endsWith("Z")) {
      return iso;
    }
    var duration = DateTime.now().timeZoneOffset;
    if (duration.isNegative)
      return (iso +
          "-${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    else
      return (iso +
          "+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
  }

  static String toDate(
      {timestamp,
      dateString,
      parseToFormat = "dd MMM, yyyy",
      DateTime datetime}) {
    if (timestamp == 0 && dateString == null && datetime == null) return "";
    var format = new DateFormat(parseToFormat);

    if (datetime != null) {
      return format.format(datetime);
    }

    if (timestamp != null) {
      return format
          .format(DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000));
    }

    if (dateString != null) {
      return format.format(DateTime.parse(dateString).toLocal());
    }

    return "";
  }

  static DateTime parseDate(
      {timestamp, dateString, parseFormat = "yyyy-MM-dd HH:mm:ss"}) {
    if (timestamp == 0 && dateString == null) return DateTime.now();

    if (timestamp != null) {
      return DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    }

    if (dateString != null) {
      return DateTime.parse(dateString);
    }

    return DateTime.now();
  }

  static CustomProgressDialog progressDialog;
// CustomProgressDialog
  static void showProgress(context, {text}) {
    progressDialog = CustomProgressDialog(context,
        dismissable: false,
        blur: 10,
        loadingWidget: text != null
            ? Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Wgt.spaceTop(20),
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue)),
                  if (text != null)
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Wgt.text(context, "$text",
                            size: Wgt.FONT_SIZE_NORMAL_2))
                ]))
            : null,
        backgroundColor: Colors.black.withOpacity(0.8));
    progressDialog.show(useSafeArea: false);
  }

  static void hideProgress(context) {
    try {
      // print("hide");
      progressDialog.dismiss();
      // progressDialog.dismiss();
      // Helper.closePage(context);

      // dismissProgressDialog();
    } catch (e) {
      print(e);
    }

    // Default
//    if (dialog != null) {
//      Navigator.pop(context);
//      dialog = null;
//    }
  }

  static void openWebview(context, {url, title}) {
    if (url == null || url == "") return;
    Helper.openPageClass(context, ImbWebview(url: url, title: title));
  }

  static void webview({url}) async {
//    bool valid = await canLaunch(url);
//    if (!valid) return;

//    var wv = FlutterWebView();
//    wv.launch(url, javaScriptEnabled: true, toolbarActions: [new ToolbarAction("Reload", 1), new ToolbarAction("Close", 2)], tintColor: Colors.white);
//    wv.onToolbarAction.listen((identifier) {
//      switch (identifier) {
//        case 2:
//          wv.dismiss();
//          break;
//        case 1:
//          wv.load(url);
//          break;
//      }
//    });
  }

  static Future openWeb({url, fallbackurl}) async {
    print(url);
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackurl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackurl, forceSafariVC: false, forceWebView: false);
    }

    // if (await canLaunch(url)) {
    //   await launch(url, forceSafariVC: false);
    // } else {
    //   print('Could not launch $url');
    // }
  }

  static var userid;

  static bool showAdvanced() {
    if (userid != null && userid != "") {
      var id = num.tryParse(userid);
      if (id != null && id < 1100) return true;
//      if (id != null && id < 1) return true;
    }

    return false;
  }

  static FirebaseMessaging firebaseMessaging;

  static subscribeToFirebase(context) async {
    if (firebaseMessaging == null) {
      firebaseMessaging = FirebaseMessaging();
      firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onmessage");
          displayPushMessage(context, message);
        },
        onResume: (Map<String, dynamic> message) async {
          print("onresume");
          displayPushMessage(context, message);
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onlaunch");
          displayPushMessage(context, message);
        },
      );

      firebaseMessaging.getToken().then((token) {
        print("Device token : $token");
      });
    }
  }

  static displayPushMessage(context, Map<String, dynamic> message) {
    print("$message");
    OrderOnlineHelper.displayOrderPush(context, message);
    // Helper.toastNotif(context, payload: {"message": message});
  }

  static bool validateInputs(context,
      {List<TextEditingController> arr, TextEditingController cont}) {
    if (cont != null && arr == null) {
      arr = [cont];
    }

    for (var item in arr) {
      if (item.text == null || item.text == "") {
        Helper.toastError(context, "Please fill required fields");
        return false;
      }
    }

    return true;
  }

  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  static String generateRandomString() {
    var r = Random();
    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    return List.generate(13, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  static printReceipt(context, order,
      {showSelection = false, reprint = false}) async {
    if (showSelection) {
      if (!Order.permissions.contains("reprint_receipt") &&
          !Order.permissions.contains("reprint_kitchen_ticket")) {
        Helper.toastError(context, "Anda tidak memiliki akses mencetak ulang");
        return;
      }
      showDialog(
          context: context,
          builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              elevation: 5,
              child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        JudulPopup(context: context, title: "Cetak Struk"),
                        Wgt.separator(),
                        Container(
                            padding: EdgeInsets.all(20),
                            child: Column(children: [
                              if (Order.permissions.contains("reprint_receipt"))
                                Row(children: [
                                  Expanded(
                                      child: Wgt.btn(context, "Cetak Struk",
                                          onClick: () {
                                    Helper.closePage(context);
                                    printOrder(context, order: order);
                                  })),
                                ]),
                              if (Order.permissions.contains("reprint_receipt"))
                                Wgt.spaceTop(20),
                              if (Order.permissions
                                  .contains("reprint_kitchen_ticket"))
                                Row(children: [
                                  Expanded(
                                      child: Wgt.btn(context, "Cetak Dapur",
                                          onClick: () {
                                    Helper.closePage(context);
                                    printDapur(context, order: order);
                                  })),
                                ]),
                            ]))
                      ]))));
    } else {
      List items = await DBPawoon().select(tablename: DBPawoon.DB_PRINTERS);
      for (var item in items) {
        BPrinter printer = BPrinter.fromMap(item);

        if (reprint) {
          printer.enableCetakStruk =
              Order.permissions.contains("reprint_receipt");
          printer.enableCetakDapur =
              Order.permissions.contains("reprint_kitchen_ticket");
        }

        if (printer.enableCetakDapur && printer.enableCetakStruk) {
          printOrder(context, order: order, printer: printer);
          printDapur(context, order: order, printer: printer);
          if (printer.enableCetakLabel)
            printLabel(context, order: order, printer: printer);
        } else if (printer.enableCetakStruk) {
          printOrder(context, order: order, printer: printer);

          if (printer.enableCetakLabel)
            printLabel(context, order: order, printer: printer);
        } else if (printer.enableCetakDapur) {
          printDapur(context, order: order, printer: printer);

          if (printer.enableCetakLabel)
            printLabel(context, order: order, printer: printer);
        } else {
          Helper.toast(context, "Anda tidak memiliki akses");
        }
        /*
      if (printer.address.toString().contains(":")){
        // Panggil print bluetooth
      }else if (printer.address.toString().contains(".")){
        // Panggil print wifi
        PrinterWifiLogic.printOrder(order: order, printer: printer);
      }
      */
      }
    }
  }

  static printOrder(context, {order, BPrinter printer}) async {
    if (printer == null) {
      List items = await DBPawoon().select(tablename: DBPawoon.DB_PRINTERS);
      for (var item in items) {
        BPrinter p = BPrinter.fromMap(item);
        printOrder(context, order: order, printer: p);
      }
    } else {
      if (printer.address.toString().contains(":")) {
        // Panggil print bluetooth
      } else if (printer.address.toString().contains(".")) {
        // Panggil print wifi
        PrinterWifiLogic.printOrder(context, order: order, printer: printer);
      }
    }
  }

  static printDapur(context, {order, BPrinter printer}) async {
    if (printer == null) {
      List items = await DBPawoon().select(tablename: DBPawoon.DB_PRINTERS);
      for (var item in items) {
        BPrinter p = BPrinter.fromMap(item);
        printDapur(context, order: order, printer: p);
      }
    } else {
      if (printer.address.toString().contains(":")) {
        // Panggil print bluetooth
      } else if (printer.address.toString().contains(".")) {
        // Panggil print wifi
        PrinterWifiLogic.printDapur(context, order: order, printer: printer);
      }
    }
  }

  static printRekap(context,
      {rekap,
      BPrinter printer,
      BOutlet outlet,
      BOperator op,
      List<BOrderParent> arrOrders}) async {
    if (printer == null) {
      List items = await DBPawoon().select(tablename: DBPawoon.DB_PRINTERS);
      for (var item in items) {
        BPrinter p = BPrinter.fromMap(item);
        printRekap(context,
            rekap: rekap,
            printer: p,
            outlet: outlet,
            op: op,
            arrOrders: arrOrders);
      }
    } else {
      if (printer.address.toString().contains(":")) {
        // Panggil print bluetooth
      } else if (printer.address.toString().contains(".")) {
        // Panggil print wifi
        PrinterWifiLogic.printRekap(context,
            rekap: rekap,
            printer: printer,
            outlet: outlet,
            op: op,
            arrOrders: arrOrders);
      }
    }
  }

  static printLabel(context, {order, BPrinter printer}) {
    if (printer.address.toString().contains(":")) {
      // Panggil print bluetooth
    } else if (printer.address.toString().contains(".")) {
      // Panggil print wifi
      PrinterWifiLogic.printLabel(context, order: order, printer: printer);
    }
  }

  static GlobalKey fabKey = GlobalObjectKey("fab");
  static highlightOverlay1(context, {listenerClose}) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = fabKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    // markRect = Rect.fromCircle(
    //     center: markRect.center, radius: markRect.longestSide * 1);

    coachMarkFAB.show(
        targetContext: fabKey.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.top,
              left: markRect.right + 30,
              child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                      width: 300,
                      child: Wgt.text(context,
                          "Tekan pada gambar untuk memasukkan produk ke daftar pesanan",
                          maxlines: 100,
                          color: Colors.white,
                          size: Wgt.FONT_SIZE_NORMAL_2),
                    ),
                    Wgt.spaceTop(10),
                    Wgt.btn(context, "OK"),
                  ])))
        ],
        duration: null,
        onClose: () {
          if (listenerClose != null) listenerClose();
        });
  }

  static GlobalKey fabKey2 = GlobalObjectKey("fab2");
  static highlightOverlay2(context, {listenerClose, name}) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = fabKey2.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;

    // markRect = Rect.fromCircle(
    //     center: markRect.center, radius: markRect.longestSide * 1);

    coachMarkFAB.show(
        markShape: BoxShape.rectangle,
        targetContext: fabKey2.currentContext,
        markRect: markRect,
        children: [
          Positioned(
              top: markRect.bottom,
              right: 0,
              child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        width: 300,
                        child: Wgt.text(context, "Hi $name,",
                            maxlines: 100,
                            color: Colors.white,
                            size: Wgt.FONT_SIZE_NORMAL_2,
                            weight: FontWeight.bold)),
                    Wgt.spaceTop(10),
                    Container(
                        width: 250,
                        child: Wgt.text(context,
                            "Tekan pada tombol untuk memilih \"Tipe Penjualan\"",
                            maxlines: 100,
                            color: Colors.white,
                            size: Wgt.FONT_SIZE_NORMAL_2)),
                    Wgt.spaceTop(10),
                    Wgt.btn(context, "SAYA MENGERTI"),
                  ])))
        ],
        duration: null,
        onClose: () {
          if (listenerClose != null) listenerClose();
        });
  }

  static GlobalKey fabUangpas = GlobalObjectKey("fabUangpas");
  static highlightOverlayUangpas(context, {listenerClose, name}) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = fabUangpas.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    // markRect = Rect.fromCircle(
    //     center: markRect.center, radius: markRect.longestSide * 1);

    coachMarkFAB.show(
        targetContext: fabUangpas.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.top - 250,
              // bottom: markRect.top,
              left: markRect.left,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 300,
                            child: Wgt.text(context, "Hi, $name",
                                maxlines: 1,
                                color: Colors.black,
                                weight: FontWeight.bold,
                                size: Wgt.FONT_SIZE_NORMAL_2)),
                        Wgt.spaceTop(10),
                        Container(
                            width: 300,
                            child: Wgt.text(context,
                                "Tekan tombol \"UANG PAS\"\nuntuk melakukan pembayaran.",
                                maxlines: 100,
                                color: Colors.black,
                                size: Wgt.FONT_SIZE_NORMAL_2)),
                        Wgt.spaceTop(10),
                        Wgt.btn(context, "SAYA MENGERTI"),
                      ])))
        ],
        duration: null,
        onClose: () {
          if (listenerClose != null) listenerClose();
        });
  }

  static GlobalKey fabBayar = GlobalObjectKey("fabBayar");
  static highlightOverlayBayar(context, {listenerClose, name}) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = fabBayar.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    // markRect = Rect.fromCircle(
    //     center: markRect.center, radius: markRect.longestSide * 1);

    coachMarkFAB.show(
        targetContext: fabBayar.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.top - 270,
              // bottom: markRect.top,
              left: markRect.left - 150,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 250,
                            child: Wgt.text(context, "Hi, $name",
                                maxlines: 2,
                                color: Colors.black,
                                weight: FontWeight.bold,
                                size: Wgt.FONT_SIZE_NORMAL_2)),
                        Wgt.spaceTop(10),
                        Container(
                            width: 250,
                            child: Wgt.text(context,
                                "Tekan tombol \"BAYAR\"\nuntuk melanjutkan ke pembayaran.",
                                maxlines: 3, color: Colors.black)),
                        Wgt.spaceTop(10),
                        Wgt.btn(context, "SAYA MENGERTI"),
                      ])))
        ],
        duration: null,
        onClose: () {
          if (listenerClose != null) listenerClose();
        });
  }
}

class DateTimePicker extends StatefulWidget {
  DateTime date;
  DateTime maxDate;
  DateTime minDate;
  var align;
  var hint;
  var onPick;
  var format;

  DateTimePicker(
      {this.date,
      this.maxDate,
      this.minDate,
      this.hint = "Select date",
      this.onPick,
      this.align = TextAlign.left,
      this.format = "dd MMM, yyyy"});

  @override
  State<StatefulWidget> createState() {
    return _DateTimePicker();
  }
}

class _DateTimePicker extends State<DateTimePicker> {
  @override
  void initState() {
    super.initState();
    if (widget.maxDate == null) widget.maxDate = DateTime.now();
    if (widget.minDate == null)
      widget.minDate = DateTime(
        widget.maxDate.year - 10,
        widget.maxDate.month,
        widget.maxDate.day,
        widget.maxDate.hour,
        widget.maxDate.minute,
        widget.maxDate.second,
      );
  }

  @override
  Widget build(BuildContext context) {
    var text = widget.hint;
    Color color = Colors.grey;
    if (widget.date != null) {
      text = Helper.toDate(
          timestamp: widget.date.millisecondsSinceEpoch,
          parseToFormat: widget.format);
      color = Colors.black;
    }
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: widget.minDate,
                  maxTime: widget.maxDate, onChanged: (date) {
                widget.date = date;
                setState(() {});
              }, onConfirm: (date) {
                widget.date = date;
                if (widget.onPick != null) widget.onPick(date);
                setState(() {});
              },
                  currentTime:
                      widget.date == null ? DateTime.now() : widget.date,
                  locale: LocaleType.en);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Wgt.text(context, text,
                        color: color, align: widget.align)),
                Wgt.separator(color: Colors.grey[300]),
              ],
            )));
  }
}

typedef ListenerConfirm = void Function();
typedef ListenerCancel = void Function();
typedef ListenerSelection = void Function(int);
typedef ListenerString = void Function(String);
