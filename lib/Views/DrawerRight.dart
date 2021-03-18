import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';

class DrawerRight extends StatefulWidget {
  var listenerClick;
  BOrderParent orderParent;
  DrawerRight({this.listenerClick, this.orderParent});
  @override
  _DrawerRightState createState() => _DrawerRightState();
}

enum DrawerRightClick {
  diskon,
  pelanggan,
  promo,
  cancel,
}

class _DrawerRightState extends State<DrawerRight> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        padding: EdgeInsets.only(top: 50, bottom: 50),
        color: Colors.white,
        child: Container(
          child: Column(children: [
            Container(
                padding: EdgeInsets.only(top: 40, bottom:40),
                child: Wgt.text(
                    context, "No. Transaksi : ${widget.orderParent.id}")),
            // Expanded(
            //     child: Material(
            //         color: Colors.transparent,
            //         child: InkWell(
            //             onTap: () => doClick(tag: DrawerRightClick.diskon),
            //             child: Container(
            //                 padding: EdgeInsets.only(left: 20, right: 20),
            //                 child: Row(children: [
            //                   Icon(Icons.cut, color: Cons.COLOR_PRIMARY),
            //                   Wgt.spaceLeft(20),
            //                   Wgt.text(context, "Diskon"),
            //                 ]))))),
            Container(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () => doClick(tag: DrawerRightClick.pelanggan),
                        child: Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Row(children: [
                              Image.asset("assets/ic_person.png",
                                  color: Cons.COLOR_PRIMARY, height: 20),
                              Wgt.spaceLeft(20),
                              Wgt.text(context, "Nama"),
                            ]))))),
            // Expanded(
            //     child: Material(
            //         color: Colors.transparent,
            //         child: InkWell(
            //             onTap: () => doClick(tag: DrawerRightClick.promo),
            //             child: Container(
            //                 padding: EdgeInsets.only(left: 20, right: 20),
            //                 child: Row(children: [
            //                   Image.asset("assets/ic_voucher.png",
            //                       color: Cons.COLOR_PRIMARY, height: 20),
            //                   Wgt.spaceLeft(20),
            //                   Wgt.text(context, "Daftar Promo"),
            //                 ]))))),
            Container(
                padding: EdgeInsets.only(top: 40, bottom: 40),
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () => doClick(tag: DrawerRightClick.cancel),
                        child: Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Row(children: [
                              Icon(Icons.remove_shopping_cart,
                                  color: Colors.red[800]),
                              Wgt.spaceLeft(20),
                              Wgt.text(context, "Batalkan Transaksi"),
                            ]))))),
          ]),
        ));
  }

  void doClick({tag}) {
    Helper.closePage(context);

    if (widget.listenerClick != null) {
      widget.listenerClick(tag);
    }
  }
}
