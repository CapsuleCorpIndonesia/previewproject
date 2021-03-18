import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BCompany.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Helper/Api.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';
import 'Operator.dart';

class Device extends StatefulWidget {
  Device({Key key}) : super(key: key);

  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  PullToRefresh pullToRefresh = PullToRefresh();
  Loader2 loader = Loader2();
  List<BDevice> arrDevice = List();
  // String outletid;
  BOutlet outlet;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (outletid == null) {
    //   UserManager.getString(UserManager.OUTLET_ID).then((value) {
    //     outletid = value;
    //     doRefresh();
    //   });
    // }
    if (outlet == null) {
      outlet = Helper.getPageData(context)["outlet"];
      doRefresh();
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Pilih Device"), body: body());
  }

  Widget body() {
    return Container(
        child: pullToRefresh.generate(
            onRefresh: () => doRefresh(),
            child: loader.isLoading ? loader : listDevice()));
  }

  Widget listDevice() {
    if (arrDevice.isEmpty) return empty();
    return ListView.builder(
        itemCount: arrDevice.length,
        itemBuilder: (context, index) {
          return cellDevice(arrDevice[index]);
        });
  }

  Widget cellDevice(BDevice item) {
    return Column(children: [
      InkWell(
          onTap: () => assignDevice(item),
          child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: Row(children: [
                Image.asset("assets/x_ic_tablet.png", height: 50),
                Wgt.spaceLeft(10),
                Wgt.textLarge(context, "${item.name}", weight: FontWeight.w600),
                Expanded(child: Container()),
                Icon(Icons.arrow_forward_ios, color: Cons.COLOR_PRIMARY)
              ]))),
      Wgt.separator(),
    ]);
  }

  Widget empty() {
    return Center(
        child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wgt.text(context,
                      "Semua lisensi perangkat kasir Anda sudah digunakan di perangkat lain.\nJika ingin menggunakan Pawoon di perangkat ini, Anda harus logout terlebih dahulu di perangkat sebelumnya.\n",
                      align: TextAlign.center,
                      size: Wgt.FONT_SIZE_NORMAL_2,
                      maxlines: 100),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Wgt.text(context, "Atau klik",
                        align: TextAlign.center,
                        size: Wgt.FONT_SIZE_NORMAL_2,
                        maxlines: 100),
                    InkWell(
                        onTap: () => openCabutLisensi(),
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Wgt.text(context, "di sini",
                              align: TextAlign.center,
                              size: Wgt.FONT_SIZE_NORMAL_2,
                              color: Colors.red[700],
                              maxlines: 100),
                        )),
                    Wgt.text(
                        context, "untuk mencabut lisensi melalui back office.",
                        align: TextAlign.center,
                        size: Wgt.FONT_SIZE_NORMAL_2,
                        maxlines: 100),
                  ])
                ])));
  }

  void openCabutLisensi() {
    Helper.openWeb(url: Api.URL_DASHBOARD);
  }

  Future<void> navOperator() async {
    await UserManager.saveString(UserManager.ACCESS_TOKEN, Logic.ACCESS_TOKEN);
    await UserManager.saveBool(UserManager.IS_LOGGED_IN, true);
    Helper.openPageNoNav(context, Operator());
  }

  Future<void> doRefresh() async {
    await getDevice();

    pullToRefresh.stopRefresh();
    loader.isLoading = false;
    setState(() {});
  }

  BOutlet outletNew;
  BDevice deviceNew;
  BOperator op;
  String loginEmail;
  String loginEmailSimpan;
  Future assignDevice(BDevice item) async {
    await UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null) outletNew = BOutlet.fromJson(json.decode(value));
    });
    await UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
      if (value != null) deviceNew = BDevice.fromJson(json.decode(value));
    });

    await UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null) op = BOperator.fromJson(json.decode(value));
    });
    await UserManager.getString(UserManager.LOGIN_EMAIL_SIMPAN).then((value) {
      if (value != null) loginEmailSimpan = value;
    });
    await UserManager.getString(UserManager.LOGIN_EMAIL).then((value) {
      if (value != null) loginEmail = value;
    });
    // if ((outletNew != null && deviceNew != null) &&
    //     ((outlet.id != outletNew.id) || (item.id != deviceNew.id))) {
    if (loginEmailSimpan != null &&
        loginEmail != null &&
        loginEmailSimpan != loginEmail) {
      doAssignDevice(item);
    } else if (outletNew != null && outlet.id != outletNew.id) {
      String tambahan = "";
      if (deviceNew.id != item.id) {
        tambahan = "dan device berbeda ";
      }
      Helper.confirm(context, "Perhatian",
          "Apakah anda ingin melanjutkan dengan outlet berbeda ${tambahan}dan tidak menggunakan data anda sebelumnya?",
          () {
        Helper.confirm(
            context, "Perhatian", "Data anda akan terhapus, Anda yakin?", () {
          doAssignDevice(item);
        }, () {});
      }, () {});
    } else if ((deviceNew != null) && (item.id != deviceNew.id)) {
      Helper.confirm(context, "Perhatian",
          "Apakah anda ingin melanjutkan dengan device berbeda dan tidak menggunakan data anda sebelumnya?",
          () {
        Helper.confirm(
            context, "Perhatian", "Data anda akan terhapus, Anda yakin?", () {
          doAssignDevice(item);
        }, () {});
      }, () {});
    } else if (outletNew != null &&
        deviceNew != null &&
        outlet.id == outletNew.id &&
        item.id == deviceNew.id) {
      Helper.confirm(context, "Perhatian",
          "Apakah anda ingin menggunakan data anda sebelumnya?", () {
        Helper.confirm(
            context, "Perhatian", "Data anda akan tetap ada, Anda yakin?", () {
          doAssignDevice(item, clearData: false);
        }, () {});
      }, () {
        Helper.confirm(
            context, "Perhatian", "Data anda akan terhapus, Anda yakin?", () {
          doAssignDevice(item);
        }, () {});
      });
    } else {
      doAssignDevice(item);
    }
  }

  Future doAssignDevice(BDevice item, {clearData = true}) async {
// return;

    Helper.showProgress(context);
    if (clearData) await UserManager.clearDataNewDevice();
    var j;
    await Logic(context).deviceAssignment(
        deviceid: item.id,
        outletid: outlet.id,
        success: (json) async {
          j = json;
        });
    Logic.ASSIGNMENT_TOKEN = "${j["data"]["id"]}";
    await UserManager.saveString(
        UserManager.ASSIGNMENT_TOKEN, "${j["data"]["id"]}");
    await UserManager.saveString(
        UserManager.DEVICE_OBJ, json.encode(item.saveObject()));

    var outletobj = await UserManager.getString(UserManager.OUTLET_OBJ);
    if (outletobj == null || outletobj == "") {
      await UserManager.saveString(
          UserManager.OUTLET_OBJ, json.encode(outlet.saveObject()));
    }

    await getCompanyDetails();

    var outletid = await UserManager.getString(UserManager.OUTLET_ID);
    if (outletid == null || outletid == "") {
      await UserManager.saveString(UserManager.OUTLET_ID, outlet.id);
    }

    await UserManager.saveString(UserManager.LOGIN_EMAIL_SIMPAN, loginEmail);
    Helper.hideProgress(context);
    navOperator();
  }

  Future getCompanyDetails() {
    return Logic(context).companyDetails(
        outletid: outlet.id,
        success: (j) {
          outlet.company = BCompany.fromJson(j["data"]);

          UserManager.saveString(UserManager.OUTLET_ID, outlet.id);
          UserManager.saveString(
              UserManager.OUTLET_OBJ, json.encode(outlet.saveObject()));
        });
  }

  Future getDevice() {
    return Logic(context).device(
        outletid: outlet.id,
        success: (json) {
          print(json);
          arrDevice.clear();
          for (var item in json["data"]) {
            // print(item);
            arrDevice.add(BDevice.fromJson(item));
          }
        });
  }
}
