import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pawoon/Bean/BIntegration.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BPayment.dart';
import 'package:pawoon/Bean/BPaymentCustom.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/main.dart';

class JenisBayar extends StatefulWidget {
  @override
  _JenisBayarState createState() => _JenisBayarState();
}

class _JenisBayarState extends State<JenisBayar> {
  BOrderParent orderParent;
  @override
  Widget build(BuildContext context) {
    if (orderParent == null) {
      orderParent = Helper.getPageData(context)["orderParent"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Pembayaran"), body: body());
  }

  Widget body() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          onlinePayment(),
          Wgt.spaceTop(40),
          customPayment(),
        ]));
  }

  Widget onlinePayment() {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wgt.textLarge(context, "Online Payment",
          size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.bold),
      Wgt.spaceTop(10),
      Row(children: [
        Expanded(
            child: btnOnlinePayment(
                imgName: "logo_gopay.png",
                padding: 16,
                listener: () => doClickGopay())),
        Wgt.spaceLeft(15),
        Expanded(
            child: btnOnlinePayment(
                imgName: "logo_ovo.png",
                padding: 25,
                listener: () => doClickOvo())),
        Wgt.spaceLeft(15),
        Expanded(
            child: btnOnlinePayment(
                imgName: "logo_dana.png",
                padding: 20,
                listener: () => doClickDana())),
        Wgt.spaceLeft(15),
        Expanded(
            child: btnOnlinePayment(
                imgName: "logo_linkaja.png", listener: () => doClickLinkaja())),
      ])
    ]));
  }

  Widget btnOnlinePayment({imgName, double padding = 15.0, listener}) {
    return InkWell(
      onTap: () => listener(),
      child: Container(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: padding, bottom: padding),
          height: 80,
          decoration: BoxDecoration(
              border: Border.all(color: Cons.COLOR_PRIMARY),
              borderRadius: BorderRadius.circular(5)),
          child: Container(
              child: Image.asset("assets/$imgName", fit: BoxFit.fitHeight))),
    );
  }

  Widget customPayment() {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wgt.textLarge(context, "Custom Payment",
          size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.bold),
      Wgt.spaceTop(10),
      // Row(children: [
      //   Expanded(child: btnCustomPayment(text: "\"OVO\"")),
      //   Wgt.spaceLeft(15),
      //   Expanded(child: btnCustomPayment(text: "\"GoPay\"")),
      //   Wgt.spaceLeft(15),
      //   Expanded(child: btnCustomPayment(text: "\"DANA\"")),
      //   Expanded(child: Container()),
      // ])
      Wrap(
          children: List.generate(
              orderParent.outlet.company.paymentmethods.length,
              (index) => btnCustomPayment(
                  item: orderParent.outlet.company.paymentmethods[index]))),
    ]));
  }

  Widget btnCustomPayment({BPaymentCustom item}) {
    return Container(
        margin: EdgeInsets.only(right: 20, bottom: 20),
        child: InkWell(
            onTap: () => doSelectCustom(item),
            child: Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Cons.COLOR_PRIMARY),
                    borderRadius: BorderRadius.circular(5)),
                child: Wgt.textLarge(context, "${item.name}",
                    align: TextAlign.center,
                    color: Cons.COLOR_PRIMARY,
                    weight: FontWeight.normal))));
  }

  void doSelectCustom(BPaymentCustom item) {
    // if (orderParent.payment.isNotEmpty){}
    orderParent.payment.clear();
    // orderParent.add
    BPayment p = BPayment.custom();
    p.isiCustom(customPayment: item);
    orderParent.payment.add(p);
    // orderParent.payment[0].isiCustom(customPayment: item);
    // print(orderParent.payment[0].title);
    Helper.closePage(context,
        payload: {"custom": true, "orderParent": orderParent});
  }

  bool checkIntegration({method = ""}) {
    // print("${orderParent.outlet.company.integrations}");

    for (BIntegration integration in orderParent.outlet.company.integrations) {
      if (method == integration.method) return true;
    }
    return false;
  }

  void navActivateGopay() {}
  void navActivateOvo() {}
  void navActivateDana() {}
  void navActivateLinkaja() {}

  Future<void> doClickGopay() async {
    if (!await Helper.validateInternet(context,
        popup: true,
        title: "Koneksi Internet Gagal",
        text:
            "Pastikan Anda terhubung dengan jaringan internet untuk menggunakan metode pembayaran GoPay"))
      return;
    if (!checkIntegration(method: "Go-Pay")) {
      Helper.confirm(context, "",
          "Nikmati kemudahan transaksi non-tunai menggunakan GoPay yang terintegrasi penuh dengan Pawoon POS",
          () {
        navActivateGopay();
      }, () {
        // Cancel do nothing
      }, textCancel: "GANTI METODE PEMBAYARAN", textOk: "AKTIVASI SEKARANG");
    } else {
      var balikan = await Helper.openPage(context, Main.PAYMENT_GATEWAY,
          arg: {"type": "gopay", "orderParent": orderParent});
      List arr = await DBPawoon().select(tablename: DBPawoon.DB_ORDERS);
      for (var item in arr) {
        orderParent = BOrderParent.fromMap(item);
        await DBPawoon()
            .delete(tablename: DBPawoon.DB_ORDERS, data: orderParent.toMap());
      }

      if (balikan != null) {
        Helper.closePage(context, payload: balikan);
      }
    }
  }

  Future<void> doClickOvo() async {
    if (!await Helper.validateInternet(context,
        popup: true,
        title: "Koneksi Internet Gagal",
        text:
            "Pastikan Anda terhubung dengan jaringan internet untuk menggunakan metode pembayaran OVO"))
      return;
    if (!checkIntegration(method: "ovo")) {
      Helper.confirm(context, "",
          "Nikmati kemudahan transaksi non-tunai menggunakan OVO yang terintegrasi penuh dengan Pawoon POS",
          () {
        navActivateOvo();
      }, () {
        // Cancel do nothing
      }, textCancel: "GANTI METODE PEMBAYARAN", textOk: "AKTIVASI SEKARANG");
    } else {
      Helper.openPage(context, Main.PAYMENT_GATEWAY_OVO,
          arg: {"orderParent": orderParent});
    }
  }

  Future<void> doClickDana() async {
    if (!await Helper.validateInternet(context,
        popup: true,
        title: "Koneksi Internet Gagal",
        text:
            "Pastikan Anda terhubung dengan jaringan internet untuk menggunakan metode pembayaran DANA"))
      return;
    if (!checkIntegration(method: "dana")) {
      Helper.confirm(context, "",
          "Nikmati kemudahan transaksi non-tunai menggunakan DANA yang terintegrasi penuh dengan Pawoon POS",
          () {
        navActivateDana();
      }, () {
        // Cancel do nothing
      }, textCancel: "GANTI METODE PEMBAYARAN", textOk: "AKTIVASI SEKARANG");
    }
  }

  Future<void> doClickLinkaja() async {
    if (!await Helper.validateInternet(context,
        popup: true,
        title: "Koneksi Internet Gagal",
        text:
            "Pastikan Anda terhubung dengan jaringan internet untuk menggunakan metode pembayaran LinkAja"))
      return;
    if (!checkIntegration(method: "linkaja")) {
      Helper.confirm(context, "",
          "Nikmati kemudahan transaksi non-tunai menggunakan LinkAja yang terintegrasi penuh dengan Pawoon POS",
          () {
        navActivateLinkaja();
      }, () {
        // Cancel do nothing
      }, textCancel: "GANTI METODE PEMBAYARAN", textOk: "AKTIVASI SEKARANG");
    } else {
      var balikan = await Helper.openPage(context, Main.PAYMENT_GATEWAY,
          arg: {"type": "linkaja", "orderParent": orderParent});
      if (balikan != null) {
        Helper.closePage(context, payload: balikan);
      }
    }
  }
}
