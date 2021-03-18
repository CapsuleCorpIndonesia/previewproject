import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/InputPin.dart';

class PaymentOvo extends StatefulWidget {
  @override
  _PaymentOvoState createState() => _PaymentOvoState();
}

class _PaymentOvoState extends State<PaymentOvo> {
  CustomInput inputPhone;
  TextEditingController contPhone = TextEditingController();
  BOrderParent orderParent;
  String errText;
  bool enableBayar = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (orderParent == null) {
      orderParent = Helper.getPageData(context)["orderParent"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "OVO"), body: body());
  }

  Widget body() {
    return Container(
        child: Row(children: [
      Expanded(child: panelKiri()),
      Expanded(child: panelKanan()),
    ]));
  }

  Widget panelKiri() {
    return Container(
        padding: EdgeInsets.all(50),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container()),
          Row(children: [
            Wgt.textLarge(context, "Pay by ",
                weight: FontWeight.w600, color: Colors.grey[700]),
            Image.asset("assets/logo_ovo.png", height: 30),
          ]),
          Wgt.spaceTop(10),
          Wgt.text(context, "Masukkan nomer handphone pelanggan",
              color: Colors.grey[600]),
          CustomInput(
              controller: contPhone,
              hint: "",
              enabled: false,
              errText: errText),
          Wgt.spaceTop(40),
          Wgt.textLarge(
              context, "${Helper.formatRupiahDouble(orderParent.grandTotal)}",
              weight: FontWeight.w600),
          Expanded(child: Container()),
        ]));
  }

  Widget panelKanan() {
    return Container(
        padding: EdgeInsets.all(50),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Row(children: [
                btnNumber(1),
                Wgt.spaceLeft(20),
                btnNumber(2),
                Wgt.spaceLeft(20),
                btnNumber(3),
              ])),
              Wgt.spaceTop(20),
              Expanded(
                  child: Row(children: [
                btnNumber(4),
                Wgt.spaceLeft(20),
                btnNumber(5),
                Wgt.spaceLeft(20),
                btnNumber(6),
              ])),
              Wgt.spaceTop(20),
              Expanded(
                  child: Row(children: [
                btnNumber(7),
                Wgt.spaceLeft(20),
                btnNumber(8),
                Wgt.spaceLeft(20),
                btnNumber(9),
              ])),
              Wgt.spaceTop(20),
              Expanded(
                  child: Row(children: [
                Expanded(child: Container()),
                Wgt.spaceLeft(20),
                btnNumber(0),
                Wgt.spaceLeft(20),
                btnDelete(),
              ])),
              Expanded(
                  child: Row(children: [
                Expanded(
                    child: Wgt.btn(context, "BAYAR",
                        enabled: enableBayar, onClick: () => doBayar())),
              ])),
            ]));
  }

  Widget btnNumber(qty) {
    return Expanded(
        child: Card(
            elevation: 2,
            child: InkWell(
                onTap: () {
                  contPhone.text += "$qty";
                  if (contPhone.text.length >= 8) enableBayar = true;
                  setState(() {});
                },
                child: FittedBox(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Wgt.text(context, "$qty"))))));
  }

  Widget btnDelete() {
    return Expanded(
        child: Card(
            elevation: 2,
            child: InkWell(
                onTap: () {
                  String txt = contPhone.text;
                  contPhone.text = txt.substring(0, txt.length - 1);
                  if (contPhone.text.length < 8) enableBayar = false;
                  setState(() {});
                },
                child: FittedBox(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.backspace,
                            color: Colors.grey, size: 13))))));
  }

  void doBayar() {}
}
