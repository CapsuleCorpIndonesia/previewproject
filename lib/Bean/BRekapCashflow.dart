import 'dart:convert';

import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/UserManager.dart';

import 'BDevice.dart';
import 'BOperator.dart';
import 'BOutlet.dart';

class BRekapCashflow {
  var id;
  double amount;
  var cashier_id = "";
  var device_id = "";
  var outlet_id = "";
  var serverId = "";
  var device_timestamp = "";
  var title = "";
  var type = "";
  var uploaded = false;
  var note = "";
  var recon_id = "";

  BRekapCashflow() {
    device_timestamp = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
    UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "")
        outlet_id = BOutlet.parseObject(json.decode(value)).id;
    });
    UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null && value != "")
        cashier_id = BOperator.parseObject(json.decode(value)).id;
    });
    UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
      if (value != null && value != "")
        device_id = BDevice.parseObject(json.decode(value)).id;
    });
  }

  BRekapCashflow.fromMap(Map map) {
    this.id = map["id"];
    this.recon_id = map["recon_id"];
    this.amount = map["amount"];
    this.cashier_id = map["cashier_id"];
    this.device_id = map["device_id"];
    this.outlet_id = map["outlet_id"];
    this.serverId = map["serverId"];
    this.device_timestamp = map["device_timestamp"];
    this.title = map["title"];
    this.type = map["type"];
    this.uploaded = map["uploaded"] == 1;
    this.note = map["note"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    if (this.id != null) map["id"] = this.id;
    map["recon_id"] = this.recon_id;
    map["amount"] = this.amount;
    map["cashier_id"] = this.cashier_id;
    map["device_id"] = this.device_id;
    map["outlet_id"] = this.outlet_id;
    map["serverId"] = this.serverId;
    map["device_timestamp"] = this.device_timestamp;
    map["title"] = this.title;
    map["type"] = this.type;
    map["uploaded"] = this.uploaded ? 1 : 0;
    map["note"] = this.note;
    return map;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map["amount"] = this.amount;
    map["cashier_id"] = this.cashier_id;
    map["device_id"] = this.device_id;
    map["local_id"] = this.id;
    map["outlet_id"] = this.outlet_id;
    map["reconciliation_id"] = 0;
    map["serverId"] = this.serverId;
    map["device_timestamp"] = this.device_timestamp;
    map["title"] = this.title;
    map["type"] = this.type;
    map["uploaded"] = this.uploaded ? 1 : 0;

    return map;
  }
}
