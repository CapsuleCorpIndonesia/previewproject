import 'dart:convert';

import 'package:pawoon/Bean/BOwner.dart';
import 'package:pawoon/Bean/BPaymentCustom.dart';

import 'BIntegration.dart';

class BCompany {
  var id;
  var name;
  var logo_image;
  var receipt_image;
  var receipt_note;
  var receipt_powered_by;
  var photo_image;
  var transaction_round;
  var show_unit_price;
  BOwner owner;
  List<BPaymentCustom> paymentmethods = List();
  List<BIntegration> integrations = List();

  BCompany.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        logo_image = json["logo_image"],
        receipt_image = json["receipt_image"],
        receipt_note = json["receipt_note"],
        receipt_powered_by = json["receipt_powered_by"],
        photo_image = json["photo_image"],
        transaction_round = json["transaction_round"],
        show_unit_price = json["show_unit_price"] {

    if (json["owner"] != null && json["owner"]["data"] != null) {
      owner = BOwner.fromJson(json["owner"]["data"]);
    }
    paymentmethods.clear();

    if (json["paymentmethods"] != null &&
        json["paymentmethods"]["data"] != null) {
      for (var item in json["paymentmethods"]["data"]) {
        paymentmethods.add(BPaymentCustom.fromJson(item));
      }
    }

    if (json["integrations"] != null && json["integrations"]["data"] != null) {
      for (var item in json["integrations"]["data"]) {
        integrations.add(BIntegration.fromJson(item));
      }
    }
  }

  Map<String, dynamic> saveObject() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["logo_image"] = logo_image;
    map["receipt_image"] = receipt_image;
    map["receipt_note"] = receipt_note;
    map["receipt_powered_by"] = receipt_powered_by;
    map["photo_image"] = photo_image;
    map["transaction_round"] = transaction_round;
    map["show_unit_price"] = show_unit_price;
    if (owner != null) map["owner"] = (owner.toMap());

    List<String> arrPayments = List();
    if (paymentmethods != null) {
      for (BPaymentCustom cus in paymentmethods) {
        arrPayments.add(json.encode(cus.toMap()));
      }
    }
    map["paymentmethods"] = (arrPayments);

    List<String> arrIntegrations = List();
    if (integrations != null) {
      for (BIntegration cus in integrations) {
        arrIntegrations.add(json.encode(cus.toMap()));
      }
    }
    map["integrations"] = arrIntegrations;

    return map;
  }

  BCompany.parseObject(Map map) {
    id = map["id"];
    name = map["name"];
    logo_image = map["logo_image"];
    receipt_image = map["receipt_image"];
    receipt_note = map["receipt_note"];
    receipt_powered_by = map["receipt_powered_by"];
    photo_image = map["photo_image"];
    transaction_round = map["transaction_round"];
    show_unit_price = map["show_unit_price"];

    if (map["owner"] != null && map["owner"].runtimeType == String) {
      owner = BOwner.fromMap(json.decode(map["owner"]));
    } else {
      owner = BOwner.fromMap((map["owner"]));
    }

    if (map["paymentmethods"] != null) {
      if (map["paymentmethods"].runtimeType == String)
        for (var item in json.decode(map["paymentmethods"])) {
          paymentmethods.add(BPaymentCustom.fromMap(json.decode(item)));
        }
      else
        for (var item in map["paymentmethods"]) {
          // print(item);
          paymentmethods.add(BPaymentCustom.fromMap(json.decode(item)));
        }
    }
    if (map["integrations"] != null) {
      if (map["integrations"].runtimeType == String)
        for (var item in json.decode(map["integrations"])) {
          BIntegration i = BIntegration.fromMap(json.decode(item));
          integrations.add(i);
        }
      else
        for (var item in (map["integrations"])) {
          // print(item);
          BIntegration i = BIntegration.fromMap(json.decode(item));
          integrations.add(i);
        }

      // print(integrations);
    }
  }
}
