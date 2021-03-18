import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';
import 'Order.dart';

class InputPin extends StatefulWidget {
  InputPin({Key key}) : super(key: key);

  @override
  _InputPinState createState() => _InputPinState();
}

class _InputPinState extends State<InputPin> {
  BDevice device;
  BOutlet outlet;
  BOperator op;
  PinNumpad pinNumpad;
  Loader2 loader = Loader2();
  @override
  void initState() {
    super.initState();
    initNumpad();
  }

  /**
   * Ini dipakai, krn after manggil webservice, nanti mesti nge clear pin nya
   */
  void initNumpad() {
    pinNumpad = PinNumpad(listener: (pin) {
      if (pin == outlet.company.owner.pin)
        doCheckPin();
      else {
        Helper.toastError(context, "Pin yang anda masukkan salah");
        pinNumpad.pinText = "";
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (device == null || outlet == null) {
      loadData();
    }
    if (op == null) {
      op = Helper.getPageData(context)["operator"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Masukkan PIN"),
        body: loader.isLoading ? loader : body());
  }

  Future<void> loadData() async {
    List<Future> arrFut = List();
    arrFut.add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "")
        outlet = BOutlet.parseObject(json.decode(value));
    }));
    // arrFut.add(UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
    //   if (value != null && value != "") {
    //     op = BOperator.parseObject(json.decode(value));
    //   }
    // }));
    arrFut.add(UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
      if (value != null && value != "")
        device = BDevice.parseObject(json.decode(value));
    }));
    await Future.wait(arrFut);
    loader.isLoading = false;
    setState(() {});
  }

  Widget body() {
    return Container(
        child: Row(children: [
      Expanded(child: note()),
      Expanded(child: numpad()),
    ]));
  }

  Widget numpad() {
    return pinNumpad;
  }

  Widget note() {
    return Container(
        padding: EdgeInsets.only(left: 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container()),
          Wgt.textLarge(context, "Halo,"),
          Wgt.spaceTop(30),
          Wgt.textLarge(context, "${op.name}", weight: FontWeight.bold),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 15),
            height: 5,
            width: 50,
            color: Cons.COLOR_PRIMARY,
          ),
          Wgt.text(context, "Default PIN : 1111", color: Colors.grey),
          Expanded(child: Container()),
        ]));
  }

  /**
   * Cek webservice pin di sini
   */
  void doCheckPin() {
    navOrder();
  }

  Future<void> navOrder() async {
    print(json.encode(op.saveObject()));
    await UserManager.saveString(
        UserManager.OPERATOR_OBJ, json.encode(op.saveObject()));
    Helper.openPageNoNav(context, Order());
    // Helper.openPage(context, Main.ORDER,
    //     arg: {"outlet": outlet, "device": device, "operator": operator});
  }
}

class PinNumpad extends StatefulWidget {
  String pinText = "";
  var listener;
  PinNumpad({this.listener});

  @override
  _PinNumpadState createState() => _PinNumpadState();
}

class _PinNumpadState extends State<PinNumpad> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 20, right: 40),
        child: Column(children: [
          Expanded(child: Container()),
          Row(children: [
            Expanded(child: Container()),
            pinHint(),
            Expanded(child: Container()),
          ]),
          Wgt.spaceTop(40),
          Expanded(
              child: Row(children: [
            Expanded(child: tombol("1")),
            Wgt.spaceLeft(20),
            Expanded(child: tombol("2")),
            Wgt.spaceLeft(20),
            Expanded(child: tombol("3")),
          ])),
          Wgt.spaceTop(20),
          Expanded(
              child: Row(children: [
            Expanded(child: tombol("4")),
            Wgt.spaceLeft(20),
            Expanded(child: tombol("5")),
            Wgt.spaceLeft(20),
            Expanded(child: tombol("6")),
          ])),
          Wgt.spaceTop(20),
          Expanded(
              child: Row(children: [
            Expanded(child: tombol("7")),
            Wgt.spaceLeft(20),
            Expanded(child: tombol("8")),
            Wgt.spaceLeft(20),
            Expanded(child: tombol("9")),
          ])),
          Wgt.spaceTop(20),
          Expanded(
              child: Row(children: [
            Expanded(child: Container()),
            Wgt.spaceLeft(20),
            Expanded(child: tombol("0")),
            Wgt.spaceLeft(20),
            Expanded(
                child: tombol("--",
                    icon: Icon(Icons.backspace,
                        color: Colors.grey[500], size: 35))),
          ])),
          Expanded(child: Container()),
        ]));
  }

  Widget tombol(txt, {icon}) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]),
            borderRadius: BorderRadius.all(Radius.circular(7)),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey[300],
                blurRadius: 1,
                offset: Offset(0.0, 2.0),
              )
            ]),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () => input(txt),
                child: Center(
                    child: icon == null
                        ? Wgt.textLarge(context, "$txt",
                            align: TextAlign.center, size: 35)
                        : icon))));
  }

  double buletSize = 20;

  Widget pinHint() {
    List<Widget> arrBulet = List();
    for (var i = 0; i < 4; i++) {
      if (i < widget.pinText.length)
        arrBulet.add(buletActive());
      else
        arrBulet.add(buletInactive());
    }
    return Row(children: arrBulet);
  }

  Widget buletActive() {
    return Container(
        height: buletSize,
        width: buletSize,
        margin: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
          color: Cons.COLOR_PRIMARY,
          border: Border.all(color: Cons.COLOR_PRIMARY),
          borderRadius: BorderRadius.circular(buletSize),
        ));
  }

  Widget buletInactive() {
    return Container(
        height: buletSize,
        width: buletSize,
        margin: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Cons.COLOR_PRIMARY),
          borderRadius: BorderRadius.circular(buletSize),
        ));
  }

  void input(txt) {
    if (txt == "--") {
      if (widget.pinText.length == 0) return;
      widget.pinText = widget.pinText.substring(0, widget.pinText.length - 1);
    } else {
      if (widget.pinText.length == 4) return;
      widget.pinText += txt;
    }

    if (widget.listener != null && widget.pinText.length == 4) {
      widget.listener(widget.pinText);
    }

    setState(() {});
  }
}
