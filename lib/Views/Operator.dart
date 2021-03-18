import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/HTTPImb.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/SyncData.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';
import 'Base.dart';

class Operator extends StatefulWidget {
  bool firstPage = false;
  Operator({this.firstPage = false});

  @override
  _OperatorState createState() => _OperatorState();
}

class _OperatorState extends State<Operator> {
  PullToRefresh pullToRefresh = PullToRefresh();
  Loader2 loader = Loader2();
  List<BOperator> arrOperator = List();
  String outletid;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (outletid == null) {
      UserManager.getString(UserManager.OUTLET_ID).then((value) {
        outletid = value;
        // print(value);
        doRefresh();
      });
    }

    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            name: "Pilih Operator", titleSpacing: 20),
        body: body());
  }

  Widget body() {
    return pullToRefresh.generate(
        // onRefresh: () {
        //   // doRefresh();
        // },
        child: loader.isLoading ? loader : listOperator());
  }

  Widget listOperator() {
    return ListView.builder(
        itemCount: arrOperator.length,
        itemBuilder: (context, index) {
          return cellOperator(arrOperator[index], index: index);
        });
  }

  // ic_staff_2.png
  // ic_operator.png
  Widget cellOperator(BOperator item, {index}) {
    var assetName = "ic_operator.png";
    if (item.type == "owner") assetName = "ic_staff_2.png";

    return Column(children: [
      InkWell(
          onTap: () => navPin(item),
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: Row(children: [
              Image.asset("assets/$assetName", height: 50),
              Wgt.spaceLeft(10),
              Wgt.textLarge(context, "${item.name}", weight: FontWeight.w600),
              Expanded(child: Container()),
              Icon(Icons.arrow_forward_ios, color: Cons.COLOR_PRIMARY)
            ]),
          )),
      Wgt.separator(),
    ]);
  }

  Future<void> navPin(BOperator item) async {
    Helper.openPage(context, Main.INPUT_PIN, arg: {"operator": item});
  }

  Future<void> doRefresh() async {
    Helper.showProgress(context, text: "Sinkronisasi data. Silahkan tunggu");
    bool hasil = await Helper.hasInternet();
    // Helper.hasInternet(listener: (hasil) async {
    if (hasil) {
      bool adaisi = await SyncData.masterDataKosong();

      if (adaisi) {
        await loadFromDB();
      } else {
        await SyncData.syncMasterData(context, force: true);
        await loadFromDB();
      }
    } else {
      await loadFromDB();
    }
    // });
    // pullToRefresh.stopRefresh();
    loader.isLoading = false;
    setState(() {});
    Helper.hideProgress(context);

    // await getOperator();
  }

  Future loadFromDB() async {
    List arr = await DBPawoon().select(tablename: DBPawoon.DB_OPERATOR);
    for (var item in arr) {
      BOperator op = BOperator.parseObject(item);
      arrOperator.add(op);
    }
  }

  Future getOperator() {
    return Logic(context)
        .operator(
            outletid: outletid,
            success: (json) {
              arrOperator.clear();
              if (json["data"] != null)
                for (var item in json["data"]) {
                  arrOperator.add(BOperator.fromJson(item));
                }
            })
        .then((value) {
      pullToRefresh.stopRefresh();
      loader.isLoading = false;
      setState(() {});
    });
  }
}
