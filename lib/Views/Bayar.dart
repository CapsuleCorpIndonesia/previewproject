import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BPayment.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';
import 'OrderPopups.dart';

class Bayar extends StatefulWidget {
  @override
  _BayarState createState() => _BayarState();
}

class _BayarState extends State<Bayar> {
  BOrderParent orderParent;
  BPayment payment;
  int total = 0;
  bool firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (firstTime) {
      if (Helper.getPageData(context)["payment"] != null) {
        payment = Helper.getPageData(context)["payment"];
        total = payment.amount ?? 0;
      } else {
        total = Helper.getPageData(context)["total"] ?? 0;
        orderParent = Helper.getPageData(context)["order"];
        if (orderParent.payment.isNotEmpty &&
            orderParent.payment[0].responseRaw != null &&
            orderParent.payment[0].responseRaw != "") {
          navPaymmentMethod(payment: BPayment.custom());
        }
      }
      firstTime = false;
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            displayPawoonLogo: false,
            name: "Pembayaran",
            displayRight: true,
            arrIconButtons: rightIcons()),
        body: body());
  }

  List<Widget> rightIcons() {
    return [
      // if (orderParent != null)
      //   btnRightIcon(
      //       img: "ic_book_24_px.png",
      //       text: "CICILAN",
      //       listener: () {},
      //       height: 25),
      // if (orderParent != null)
      //   btnRightIcon(
      //       img: "ic_menu_split.png", text: "SPLIT", listener: () => doSplit()),
      btnRightIcon(
          img: "ic_menu_note.png", text: "CATATAN", listener: () => doNotes()),
      Wgt.spaceLeft(10),
    ];
  }

  Future<void> doSplit() async {
    var balikan =
        await showDialog(context: context, builder: (_) => BayarSplit());
    if (balikan != null && balikan == "payment") {
      Helper.openPage(context, Main.SPLIT_PAYMENT,
          arg: {"orderParent": orderParent});
    } else if (balikan != null && balikan == "bill") {
      // do something
    }
  }

  Future<void> doNotes() async {
    var balikan = await showDialog(
        context: context, builder: (_) => BayarNotes(orderParent: orderParent));
    if (balikan != null && balikan["orderParent"] != null) {
      setState(() {});
    }
  }

  Widget btnRightIcon({img, text, listener, double height = 30}) {
    return InkWell(
        onTap: () {
          if (listener != null) listener();
        },
        child: Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Row(children: [
              Image.asset("assets/$img", height: height, color: Colors.white),
              Wgt.spaceLeft(5),
              Wgt.textSecondary(context, "$text",
                  color: Colors.white, weight: FontWeight.w700),
            ])));
  }

  Widget body() {
    return Container(
        padding: EdgeInsets.all(40),
        child: SingleChildScrollView(
            child: Column(children: [
          totalTagihan(),
          if (orderParent != null) metodePembayaran(),
          jumlahPembayaran(),
        ])));
  }

/* -------------------------------------------------------------------------- */
/*                               TAGIHAN WIDGET                               */
/* -------------------------------------------------------------------------- */
  Widget totalTagihan() {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Column(children: [
          Wgt.textLarge(context, "Total Tagihan",
              size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.bold),
          Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.only(top: 15, bottom: 15),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300], width: 3),
                  borderRadius: BorderRadius.circular(5),
                  color: Color(0xFFF1F9FA)),
              child: Row(children: [
                Expanded(
                    child: Wgt.textLarge(
                        context, "${Helper.formatRupiahInt(total)}",
                        size: Wgt.FONT_SIZE_LARGE_X,
                        weight: FontWeight.bold,
                        align: TextAlign.center))
              ])),
        ]));
  }

/* -------------------------------------------------------------------------- */
/*                              METODE PEMBAYARA                              */
/* -------------------------------------------------------------------------- */
  List<BPayment> listPaymentMethods = [
    BPayment.cash(),
    BPayment.card(),
    BPayment.custom()
  ];
  Widget metodePembayaran() {
    return Container(
        margin: EdgeInsets.only(top: 30, bottom: 10),
        child: Column(children: [
          Wgt.textLarge(context, "Metode Pembayaran",
              size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.bold),
          Wgt.spaceTop(10),
          Row(
              children: List.generate(
                  listPaymentMethods.length,
                  (index) => Container(
                      child: Expanded(
                          child: btnMetode(
                              payment: listPaymentMethods[index],
                              listener: () {
                                if (listPaymentMethods[index].method ==
                                    "others")
                                  navPaymmentMethod(
                                      payment: listPaymentMethods[index]);
                                else
                                  doSelectPayment(
                                      payment: listPaymentMethods[index]);
                              }))))),
        ]));
  }

  void doSelectPayment({BPayment payment}) {
    orderParent.payment.clear();
    orderParent.payment.add(payment);
    setState(() {});
  }

  Widget btnMetode({listener, BPayment payment}) {
    if (orderParent.payment == null || orderParent.payment.isEmpty) {
      orderParent.payment = List();
      orderParent.payment.add(BPayment.cash());
    }
    bool active = orderParent.payment[0].method == payment.method;
    String text = payment.title;
    // print(orderParent.payment[0].method);
    if (orderParent.payment[0].method == "others" && active) {
      text = orderParent.payment[0].title;
    }
    return Container(
        margin: EdgeInsets.only(right: 20),
        child: InkWell(
            onTap: () {
              if (listener != null)
                listener();
              else
                doSelectPayment(payment: payment);
            },
            child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Cons.COLOR_PRIMARY)),
                child: Wgt.textLarge(context, "$text",
                    weight: FontWeight.bold,
                    align: TextAlign.center,
                    size: Wgt.FONT_SIZE_NORMAL_2,
                    color: active ? Colors.white : Cons.COLOR_PRIMARY))));
  }

  Future<void> navPaymmentMethod({BPayment payment}) async {
    var hasil = await Helper.openPage(context, Main.JENIS_BAYAR,
        arg: {"orderParent": BOrderParent.clone(orderParent)});
    if (hasil != null) {
      // orderParent.payment.clear();
      // orderParent.payment.add(payment);
      if (hasil["orderParent"] != null) orderParent = hasil["orderParent"];
      if (hasil["langsung"] != null && hasil["langsung"]) {
        navPaymentSuccess(
            kembalian: hasil["orderParent"].total_change,
            bayar: hasil["orderParent"].total_payment);
      } else {
        setState(() {});
      }
    }
  }

/* -------------------------------------------------------------------------- */
/*                              JUMLAH PEMBAYARAN                             */
/* -------------------------------------------------------------------------- */
  List<int> bayarDenganUang = List();
  num ambilBerapa = 3;

  Widget jumlahPembayaran() {
    doHitungCash();

    List<Widget> arrWidget = List();
    arrWidget.add(Expanded(
        child: btnJumlah(
            key: Helper.fabUangpas,
            text: "Uang Pas",
            listener: () {
              // orderParent.payment.clear();
              // BPayment p = BPayment.cash();
              if (orderParent.payment.isNotEmpty) {
                BPayment p = orderParent.payment[0];
                p.amount = total;
                p.change = 0;
                navPaymentSuccess(kembalian: 0, bayar: total);
              }
            })));
    displayHighlightTutorial();
    for (num i = 0; i < ambilBerapa; i++) {
      if (i >= bayarDenganUang.length) break;
      arrWidget.add(Expanded(
          child: btnJumlah(
              text: "${Helper.formatRupiahInt(bayarDenganUang[i])}",
              listener: () {
                // orderParent.payment.clear();
                // BPayment p = BPayment.cash();
                if (orderParent.payment.isNotEmpty) {
                  BPayment p = orderParent.payment[0];
                  p.amount = bayarDenganUang[i].toDouble();
                  p.change = (bayarDenganUang[i] - total).toDouble();
                  navPaymentSuccess(
                      kembalian: bayarDenganUang[i] - total,
                      bayar: bayarDenganUang[i]);
                }
              })));
    }
    arrWidget.add(Expanded(
        child: btnJumlah(text: "Lainnya", listener: () => doJumlahLainnya())));

    return Container(
        margin: EdgeInsets.only(top: 30, bottom: 10),
        child: Column(children: [
          Wgt.textLarge(context, "Jumlah Pembayaran",
              size: Wgt.FONT_SIZE_NORMAL_2, weight: FontWeight.bold),
          Wgt.spaceTop(10),
          Row(children: arrWidget),
        ]));
  }

  Widget btnJumlah({text, listener, key}) {
    return Container(
        key: key,
        margin: EdgeInsets.only(left: 5, right: 5),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  if (listener != null) listener();
                },
                child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(5)),
                    child: Wgt.text(context, "$text",
                        color: Colors.white,
                        weight: FontWeight.bold,
                        align: TextAlign.center)))));
  }

  Future<void> doJumlahLainnya() async {
    var totalBaru = await showDialog(
        context: context,
        builder: (_) => JumlahBayar(hargaTagihan: total.toInt()));
    if (totalBaru != null && totalBaru > 0) {
      navPaymentSuccess(kembalian: totalBaru - total, bayar: totalBaru);
    }
  }

  Future<void> navPaymentSuccess({kembalian, bayar}) async {
    if (orderParent != null) {
      orderParent.total_payment = bayar;
      orderParent.total_change = kembalian;
    }

    if (payment != null) {
      payment.bayar = bayar.toDouble();
      payment.change = kembalian.toDouble();
    }
    var balikan = await Helper.openPage(context, Main.BAYAR_SUKSES,
        arg: {"order": BOrderParent.clone(orderParent), "payment": payment});
    if (balikan != null) {
      Helper.closePage(context, payload: balikan);
    }
  }

  List<int> kelipatan = [100000, 50000, 20000, 10000, 5000];

  void doHitungCash() {
    Map<String, int> bayarDengan = Map();

    for (int kel in kelipatan) {
      num a = (total / kel).ceil();
      bayarDengan["$kel"] = a;
    }
    List<int> listHasil = List();
    bayarDengan.forEach((key, value) {
      num val = value * num.parse(key);
      if (val != total) listHasil.add(val);
    });

    listHasil.sort();
    bayarDenganUang.clear();
    bayarDenganUang.addAll(listHasil);
  }

  void displayHighlightTutorial() {
    UserManager.getBool(UserManager.DISPLAY_TUTORIAL_BAYAR).then((value) {
      if (value == null || value) {
        Timer(Duration(seconds: 1), () {
          Helper.highlightOverlayUangpas(context, listenerClose: () {
            UserManager.saveBool(UserManager.DISPLAY_TUTORIAL_BAYAR, false);
          }, name: orderParent.op.name);
        });
      }
    });
  }
}
