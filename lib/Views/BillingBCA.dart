import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawoon/Bean/BInvoice.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';

class BillingBCA extends StatefulWidget {
  BillingBCA({Key key}) : super(key: key);

  @override
  _BillingBCAState createState() => _BillingBCAState();
}

class _BillingBCAState extends State<BillingBCA> {
  BInvoice invoice;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (invoice == null) {
      invoice = Helper.getPageData(context)["invoice"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Petunjuk Pembayaran"), body: body());
  }

  Widget body() {
    if (invoice == null) return Container();

    // No rek
    var buffer = new StringBuffer();
    String text = "${invoice.virtual_account}";
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();

    // deadline
    DateTime deadline = DateTime.fromMillisecondsSinceEpoch(invoice.timestamp)
        .add(Duration(hours: 4));

    return Container(
        child: SingleChildScrollView(
            // padding: EdgeInsets.all(20),
            child: Column(children: [
      widgetTimer(),
      Wgt.text(context, "Kode Pembayaran", color: Colors.grey[600]),
      Row(children: [
        Expanded(child: Container()),
        Wgt.textLarge(context, string),
        Wgt.spaceLeft(10),
        btnCopy(invoice.virtual_account),
        Expanded(child: Container()),
      ]),
      Wgt.spaceTop(20),
      Wgt.text(context, "Jumlah yang harus dibayar", color: Colors.grey[600]),
      Row(children: [
        Expanded(child: Container()),
        Wgt.textLarge(context, "${Helper.formatRupiahDouble(invoice.amount)}"),
        Wgt.spaceLeft(10),
        btnCopy(invoice.amount),
        Expanded(child: Container()),
      ]),
      Wgt.spaceTop(40),
      Wgt.text(context,
          "Segera lakukan pembayaran sebelum ${Helper.toDate(datetime: deadline, parseToFormat: "EEE dd MMM yyyy HH:mm:ss")}"),
      Wgt.spaceTop(40),
    ])));
  }

  Widget btnCopy(text) {
    return Wgt.btn(context, "SALIN",
        textcolor: Cons.COLOR_PRIMARY, transparent: true, onClick: () {
      Clipboard.setData(ClipboardData(text: "$text"));
      Helper.toastSuccess(context, "Berhasil di salin");
    });
  }

  Widget widgetTimer() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    DateTime deadline = DateTime.fromMillisecondsSinceEpoch(invoice.timestamp)
        .add(Duration(hours: 4));
    DateTime now = DateTime.now();
    var duration = deadline.difference(now);
    String twoDigitHour = twoDigits(duration.inHours.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String text = "$twoDigitHour:$twoDigitMinutes:$twoDigitSeconds";
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(10),
        color: Colors.yellow[50],
        child: Row(children: [
          Expanded(
              child: Wgt.text(context, "Sisa waktu bayar $text",
                  align: TextAlign.center, color: Colors.orange)),
        ]));
  }

  Timer timer;
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
  }

  void stopTimer() {
    if (timer != null) timer.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    stopTimer();
  }
}
