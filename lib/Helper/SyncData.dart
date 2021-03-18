import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pawoon/Bean/BCompany.dart';
import 'package:pawoon/Bean/BCustomAmount.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BPelanggan.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Bean/BSalesType.dart';
import 'package:pawoon/Bean/BTax.dart';
import 'package:pawoon/Bean/BVariantDetails.dart';
import 'package:pawoon/Views/DrawerLeft.dart';
import 'package:pawoon/Views/Order.dart';
import 'package:sqflite/sqflite.dart';

import 'DBPawoon.dart';
import 'Helper.dart';
import 'Logic.dart';
import 'UserManager.dart';

class SyncData {
/* -------------------------------------------------------------------------- */
/*                                TRANSACTIONS                                */
/* -------------------------------------------------------------------------- */
  static int unsyncCount = 0;
  static bool printAll = true;
  static Future<List> getUnsyncData() async {
    Database db = await DBPawoon().getDB();
    return db.rawQuery(
        "select * from ${DBPawoon.DB_TRANSACTION} where server_id is null");
  }

  static updateUnsyncCount() async {
    List items = await getUnsyncData();
    SyncData.unsyncCount = items.length;
  }

  static Future<void> syncTransactions(context) async {
    bool connected = await Helper.hasInternet();
    if (!connected) return;

    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    List items = await getUnsyncData();
    // unsyncCount = items.length;
    await updateUnsyncCount();

    List<Map> arrData = List();
    List<Map> arrDataVoid = List();
    for (var item in items) {
      BOrderParent o = BOrderParent.fromMap(item);
      if (o.void_receipt_code == "") {
        o.status = "success";
        o.void_reason = "";
        arrData.add(o.objectToServer());
      } else
        arrDataVoid.add(o.objectToServer());
    }

    if (arrData.isNotEmpty) {
      List<Future> arrFut = List();
      // print(arrData);

      // Clipboard.setData(ClipboardData(text: "${json.encode(arrData)}"));
      await Logic(context).transactions(
          outletid: outletid,
          data: arrData,
          success: (json) {
            for (var item in json["data"]) {
              if (printAll) print("sync : ${item["id"]}");
              arrFut.add(DBPawoon().update(
                  tablename: DBPawoon.DB_TRANSACTION,
                  id: "receipt_code",
                  data: {
                    "receipt_code": item["receipt_code"],
                    "server_id": item["id"],
                  }));
            }
          });

      await Future.wait(arrFut);
    }

    if (arrDataVoid.isNotEmpty) {
      List<Future> arrFut = List();

      await Logic(context).transactions(
          outletid: outletid,
          data: arrDataVoid,
          success: (json) {
            for (var item in json["data"]) {
              if (printAll) print("sync : ${item["id"]}");
              arrFut.add(DBPawoon().update(
                  tablename: DBPawoon.DB_TRANSACTION,
                  id: "receipt_code",
                  data: {
                    "receipt_code": item["receipt_code"],
                    "server_id": item["id"],
                  }));
            }
          });

      await Future.wait(arrFut);
    }

    await updateUnsyncCount();
    try {
      stateUnsync.currentState.build(context);
    } catch (e) {}
  }

/* -------------------------------------------------------------------------- */
/*                                  SCHEDULER                                 */
/* -------------------------------------------------------------------------- */
  static StreamSubscription periodicTransactions;
  static void schedulerTransactionStart(context) {
    periodicTransactions =
        new Stream.periodic(const Duration(seconds: 90)).listen((_) {
      syncTransactions(context);
    });
  }

  static void schedulerTransactionStop() {
    periodicTransactions.cancel();
    periodicTransactions = null;
  }

  static StreamSubscription periodicMasterData;
  static void schedulerMasterDataStart(context) {
    periodicMasterData =
        new Stream.periodic(const Duration(minutes: 30)).listen((_) {
      syncMasterData(context, force: false);
      syncTransactions(context);
    });
  }

  static void schedulerMasterDataStop() {
    periodicMasterData.cancel();
    periodicMasterData = null;
  }

/* -------------------------------------------------------------------------- */
/*                              SYNC DATA MASTER                              */
/* -------------------------------------------------------------------------- */
  static bool syncing = false;
  static bool newData = false;
  static Future<bool> masterDataKosong() async {
    bool stat1 =
        await UserManager.getString(UserManager.LAST_UPDATE_PRODUCT) != null;
    if (printAll) print("stat1 : $stat1");
    bool stat2 =
        await UserManager.getString(UserManager.LAST_UPDATE_VARIANT) != null;
    if (printAll) print("stat2 : $stat2");
    // bool stat3 =
    //     await UserManager.getString(UserManager.LAST_UPDATE_TAX) != null;
    // if (printAll) print("stat3 : $stat3");
    // bool stat4 =
    //     await UserManager.getString(UserManager.LAST_UPDATE_CUSTOMER) != null;
    // if (printAll) print("stat4 : $stat4");
    // bool stat5 =
    //     await UserManager.getString(UserManager.LAST_UPDATE_OPERATOR) != null;
    // if (printAll) print("stat5 : $stat5");
    return stat1 && stat2;
  }

  static syncMasterData(context, {force = false}) async {
    bool connected = await Helper.hasInternet();
    if (!connected) return;

    syncing = true;
    if (printAll) print("1");
    await syncProducts(context, force: force);
    if (printAll) print("2");
    await syncVariants(context, force: force);
    if (printAll) print("3");
    await syncTax(context, force: force);
    if (printAll) print("4");
    await syncCustomer(context, force: force);
    if (printAll) print("5");
    await syncOperator(context, force: force);
    if (printAll) print("6");
    await syncBilling(context);
    if (printAll) print("7");
    await getCompanyDetails(context);
    if (printAll) print("8");
    await getSalesType(context);
    if (printAll) print("9");
    await getCustomAmount(context);
    if (printAll) print("done");
    newData = true;
    syncing = false;

    await updateUnsyncCount();

    try {
      stateUnsync.currentState.build(context);
    } catch (e) {}
  }

/* --------------------------------- PRODUCT -------------------------------- */
  static Future<void> syncProducts(context, {force = false}) async {
    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    String lastupdateLocal =
        await UserManager.getString(UserManager.LAST_UPDATE_PRODUCT);
    if (lastupdateLocal == null || lastupdateLocal == "") {
      lastupdateLocal =
          Helper.toDate(datetime: DateTime(2000), parseToFormat: "yyyy-MM-dd");
    }
    String updateServer = "";
    await Logic(context).lastUpdatedProduct(success: (json) async {
      try {
        updateServer = json["data"]["last_updated"];
      } catch (e) {}
    });

    // Di save dulu
    await UserManager.saveString(UserManager.LAST_UPDATE_PRODUCT, updateServer);

    // Compare last update nya
    int tsLocal = 0;
    int tsServer = 0;
    try {
      tsLocal =
          Helper.parseDate(dateString: lastupdateLocal).millisecondsSinceEpoch;
    } catch (e) {}
    try {
      tsServer =
          Helper.parseDate(dateString: updateServer).millisecondsSinceEpoch;
    } catch (e) {}

    if (tsLocal < tsServer || force) {
      // Update data
      await getProducts(context, outletid: outletid, page: 1);
    }
  }

  static Future<void> getProducts(context, {outletid, page = 1}) async {
    var json;
    await Logic(context).products(
        outletid: outletid,
        page: page,
        success: (j) async {
          json = j;
        });

    for (var item in json["data"]) {
      BProduct prod = BProduct.fromJson(item);
      // if (prod.category == null) continue;

      await DBPawoon()
          .insertOrUpdate(tablename: DBPawoon.DB_PRODUCTS, data: prod.toDb());
    }
    if (json["meta"] != null) {
      var count = json["meta"]["count"];
      var per_page = json["meta"]["per_page"];

      if (count == per_page) {
        // page++;
        await getProducts(context, page: page + 1, outletid: outletid);
      }
    }
  }

/* --------------------------------- VARIANT -------------------------------- */
  static Future<void> syncVariants(context, {force = false}) async {
    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    String lastupdateLocal =
        await UserManager.getString(UserManager.LAST_UPDATE_VARIANT);
    if (lastupdateLocal == null || lastupdateLocal == "") {
      lastupdateLocal =
          Helper.toDate(datetime: DateTime(2000), parseToFormat: "yyyy-MM-dd");
    }
    String updateServer = "";
    await Logic(context).lastUpdatedVariants(success: (json) async {
      try {
        updateServer = json["data"]["last_updated"];
      } catch (e) {}
    });

    // Di save dulu
    await UserManager.saveString(UserManager.LAST_UPDATE_VARIANT, updateServer);

    // Compare last update nya
    int tsLocal = 0;
    int tsServer = 0;
    try {
      tsLocal =
          Helper.parseDate(dateString: lastupdateLocal).millisecondsSinceEpoch;
    } catch (e) {}
    try {
      tsServer =
          Helper.parseDate(dateString: updateServer).millisecondsSinceEpoch;
    } catch (e) {}

    if (tsLocal < tsServer || force) {
      // Update data
      await getVariants(context, outletid: outletid, page: 1);
    }
  }

  static Future getVariants(context, {outletid, page = 1}) async {
    var json;
    await Logic(context).variants(
        outletid: outletid,
        page: page,
        success: (j) async {
          json = j;
        });

    for (var item in json["data"]) {
      BVariantDetails prod = BVariantDetails.fromJson(item);
      if (prod.name.toString().contains("Soda Water")) {}
      await DBPawoon().insertOrUpdate(
          tablename: DBPawoon.DB_PRODUCT_VARIANTS, data: prod.toMap());
    }

    if (json["meta"] != null) {
      var count = json["meta"]["count"];
      var per_page = json["meta"]["per_page"];
      if (count == per_page) {
        await getVariants(context, outletid: outletid, page: page + 1);
      }
    }
  }

/* ----------------------------------- TAX ---------------------------------- */
  static Future<void> syncTax(context, {force = false}) async {
    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    String lastupdateLocal =
        await UserManager.getString(UserManager.LAST_UPDATE_TAX);
    if (lastupdateLocal == null || lastupdateLocal == "") {
      lastupdateLocal =
          Helper.toDate(datetime: DateTime(2000), parseToFormat: "yyyy-MM-dd");
    }
    String updateServer = "";
    await Logic(context).lastUpdatedTax(success: (json) async {
      try {
        updateServer = json["data"]["last_updated"];
      } catch (e) {}
    });

    // Di save dulu
    await UserManager.saveString(UserManager.LAST_UPDATE_TAX, updateServer);

    // Compare last update nya
    int tsLocal = 0;
    int tsServer = 0;
    try {
      tsLocal =
          Helper.parseDate(dateString: lastupdateLocal).millisecondsSinceEpoch;
    } catch (e) {}
    try {
      tsServer =
          Helper.parseDate(dateString: updateServer).millisecondsSinceEpoch;
    } catch (e) {}

    if (tsLocal < tsServer || force) {
      // Update data
      await getTax(context, outletid: outletid);
    }
  }

  static Future getTax(context, {outletid}) async {
    var json;
    await Logic(context).tax(
        outlet: outletid,
        success: (j) async {
          json = j;
        });

    if (json["data"] != null &&
        json["data"]["taxes_and_services"] != null &&
        json["data"]["taxes_and_services"]["data"] != null) {
      for (var item in json["data"]["taxes_and_services"]["data"]) {
        BTax tax = BTax.fromJson(item);
        await DBPawoon().insertOrUpdate(
            tablename: DBPawoon.DB_TAX_SERVICES, data: tax.toMap());
      }
    }
  }

/* -------------------------------- CUSTOMER -------------------------------- */
  static Future<void> syncCustomer(context, {force = false}) async {
    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    String lastupdateLocal =
        await UserManager.getString(UserManager.LAST_UPDATE_CUSTOMER);
    if (lastupdateLocal == null || lastupdateLocal == "") {
      lastupdateLocal =
          Helper.toDate(datetime: DateTime(2000), parseToFormat: "yyyy-MM-dd");
    }
    String updateServer = "";
    await Logic(context).lastUpdatedCustomers(success: (json) async {
      try {
        updateServer = json["data"]["last_updated"];
      } catch (e) {}
    });

    // Di save dulu
    await UserManager.saveString(
        UserManager.LAST_UPDATE_CUSTOMER, updateServer);

    // Compare last update nya
    int tsLocal = 0;
    try {
      Helper.parseDate(dateString: lastupdateLocal).millisecondsSinceEpoch;
    } catch (e) {}
    int tsServer = 0;
    try {
      Helper.parseDate(dateString: updateServer).millisecondsSinceEpoch;
    } catch (e) {}
    if (tsLocal < tsServer || force) {
      // Update data
      await getCustomer(context, outletid: outletid);
    }
  }

  static Future getCustomer(context, {outletid}) async {
    var json;
    await Logic(context).customer(success: (j) {
      json = j;
    });
    for (var data in json["data"]) {
      BPelanggan customer = BPelanggan.fromJson(data);
      await DBPawoon().insertOrUpdate(
          tablename: DBPawoon.DB_CUSTOMERS, data: customer.toMap());
    }
  }

/* -------------------------------- OPERATOR -------------------------------- */
  static Future<void> syncOperator(context, {force = false}) async {
    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    String lastupdateLocal =
        await UserManager.getString(UserManager.LAST_UPDATE_OPERATOR);
    if (lastupdateLocal == null || lastupdateLocal == "") {
      lastupdateLocal =
          Helper.toDate(datetime: DateTime(2000), parseToFormat: "yyyy-MM-dd");
    }
    String updateServer = "";
    await Logic(context).lastUpdatedOperator(success: (json) async {
      try {
        updateServer = json["data"]["last_updated"];
      } catch (e) {}
    });

    // Di save dulu
    await UserManager.saveString(
        UserManager.LAST_UPDATE_OPERATOR, updateServer);

    // Compare last update nya
    int tsLocal = 0;
    int tsServer = 0;
    try {
      tsLocal =
          Helper.parseDate(dateString: lastupdateLocal).millisecondsSinceEpoch;
    } catch (e) {}
    try {
      tsServer =
          Helper.parseDate(dateString: updateServer).millisecondsSinceEpoch;
    } catch (e) {}

    if (tsLocal < tsServer || force) {
      // Update data
      await getOperator(context, outletid: outletid);
    }
  }

  static Future getOperator(context, {outletid}) async {
    String opObj = await UserManager.getString(UserManager.OPERATOR_OBJ);
    BOperator operat;
    if (opObj != null) operat = BOperator.parseObject(json.decode(opObj));

    var js;
    await Logic(context).operator(
        outletid: outletid,
        success: (j) async {
          js = j;
        });
    // if (js["data"] != null) print("operator: $json");
    for (var item in js["data"]) {
      BOperator op = BOperator.fromJson(item);
      if (operat != null && op.id == operat.id) {
        await UserManager.saveString(
            UserManager.OPERATOR_OBJ, json.encode(op.saveObject()));
        // await UserManager.saveString(
        //     UserManager.OPERATOR_OBJ, json.encode(op.saveObject()));
      }
      await DBPawoon().insertOrUpdate(
          tablename: DBPawoon.DB_OPERATOR, data: op.saveObjectDB());
    }
  }

/* --------------------------------- OTHERS --------------------------------- */
  static Future syncBilling(context) async {
    var js;
    await Logic(context).billing(success: (j) async {
      js = j;
    });

    if (js["billing"]["data"] != null) {
      await UserManager.saveString(
          UserManager.BILLING_OBJ, json.encode(js["billing"]["data"]));
    }
  }

  static Future getCompanyDetails(context) async {
    String outletobj = await UserManager.getString(UserManager.OUTLET_OBJ);
    BOutlet outlet = BOutlet.parseObject(json.decode(outletobj));
    var j;
    await Logic(context).companyDetails(
        outletid: outlet.id,
        success: (js) {
          // print("company : $json");
          // Clipboard.setData(ClipboardData(text: "${json.encode(js)}"));

          j = js;
        });
    BCompany company = BCompany.fromJson(j["data"]);
    outlet.company = company;
    await UserManager.saveString(
        UserManager.OUTLET_OBJ, json.encode(outlet.saveObject()));
  }

  static Future getSalesType(context) async {
    var outletstr = await UserManager.getString(UserManager.OUTLET_OBJ);
    BOutlet o;
    if (outletstr != null && outletstr != "")
      o = BOutlet.parseObject(json.decode(outletstr));
    String companyid;
    if (o != null && o.company != null) companyid = o.company.id;

    var j;
    await Logic(context).salesType(
        companyid: companyid ?? "",
        success: (json) async {
          j = json;
        });

    for (var item in j["data"]) {
      BSalesType type = BSalesType.fromJson(item);
      await DBPawoon().insertOrUpdate(
          tablename: DBPawoon.DB_SALES_TYPE, data: type.toMap());
    }
  }

  static Future getCustomAmount(context) async {
    String outletid = await UserManager.getString(UserManager.OUTLET_ID);
    var j;
    await Logic(context).customAmount(
        outletid: outletid,
        success: (json) async {
          j = json;
        });

    if (j["data"] != null) {
      for (var item in j["data"]) {
        BCustomAmount amt = BCustomAmount.fromJson(item);
        await UserManager.saveString(
            UserManager.CUSTOM_AMOUNT_OBJ, json.encode(amt.toObjectLocal()));
        // String textCustomAmount =
        //     await UserManager.getString(UserManager.CUSTOM_AMOUNT_OBJ);
        // if (textCustomAmount != null && textCustomAmount != "")
        //   orderParent.customAmount =
        //       BCustomAmount.fromJson(json.decode(textCustomAmount));
      }
    }
  }
}
