import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';

class Outlet extends StatefulWidget {
  Outlet({Key key}) : super(key: key);

  @override
  _OutletState createState() => _OutletState();
}

class _OutletState extends State<Outlet> {
  PullToRefresh pullToRefresh = PullToRefresh();
  Loader2 loader = Loader2();
  List<BOutlet> arrOutlet = List();

  @override
  void initState() {
    super.initState();
    doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Pilih Outlet",titleSpacing: 20), body: body());
  }

  Widget body() {
    return Container(
        child: pullToRefresh.generate(
            onRefresh: () => doRefresh(),
            child: loader.isLoading ? loader : listOutlet()));
  }

  Widget listOutlet() {
    return ListView.builder(
        itemCount: arrOutlet.length,
        itemBuilder: (context, index) {
          return cellOutlet(arrOutlet[index]);
        });
  }

  Widget cellOutlet(BOutlet outlet) {
    return Column(children: [
      InkWell(
          onTap: () => navDevice(outlet),
          child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: Row(children: [
                Image.asset("assets/x_ic_outlet.png", height: 50),
                Wgt.spaceLeft(10),
                Wgt.textLarge(context, "${outlet.name}",
                    weight: FontWeight.w600),
                Expanded(child: Container()),
                Icon(Icons.arrow_forward_ios, color: Cons.COLOR_PRIMARY)
              ]))),
      Wgt.separator(),
    ]);
  }

  void navDevice(BOutlet outlet) {
    // UserManager.saveString(UserManager.OUTLET_ID, outlet.id);
    // UserManager.saveString(UserManager.OUTLET_OBJ, json.encode(outlet.saveObject()));
    Helper.openPage(context, Main.DEVICE, arg: {"outlet": outlet});
  }

  Future<void> doRefresh() async {
    await getOutlet();
    loader.isLoading = false;
    pullToRefresh.stopRefresh();
    setState(() {});
  }

  Future getOutlet() {
    return Logic(context).outlet(success: (json) {
      arrOutlet.clear();
      if (json["data"] != null)
        for (var item in json["data"]) {
          // print(item);
          arrOutlet.add(BOutlet.fromJson(item));
        }
    });
  }
}
