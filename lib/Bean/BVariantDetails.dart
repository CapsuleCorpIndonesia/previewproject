import 'dart:convert';

import 'package:pawoon/Bean/BVariant.dart';
import 'package:pawoon/Bean/BVariantData.dart';

class BVariantDetails {
  var id;
  var name;
  var price;
  var tax;
  var type;
  var is_all_location_stock;
  var is_all_location_price;
  var is_sellable;
  var is_stock_tracked;
  var has_alertstock;
  var alert_stock_limit;
  var has_modifier;
  var has_variant;
  var use_outlet_tax;
  var parent_id;
  var amount;
  var updated_at;
  var stock;
  var barcode;
  List<BVariantData> variantdata = List();

  BVariantDetails.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        price = json["price"],
        tax = json["tax"],
        type = json["type"],
        is_all_location_stock = json["is_all_location_stock"],
        is_all_location_price = json["is_all_location_price"],
        is_sellable = json["is_sellable"],
        is_stock_tracked = json["is_stock_tracked"],
        has_alertstock = json["has_alertstock"],
        alert_stock_limit = json["alert_stock_limit"],
        has_modifier = json["has_modifier"],
        has_variant = json["has_variant"],
        use_outlet_tax = json["use_outlet_tax"],
        parent_id = json["parent_id"],
        amount = json["amount"],
        updated_at = json["updated_at"],
        stock = json["stock"],
        barcode = json["barcode"] {
    variantdata.clear();
    for (var item in json["variant_details"]["data"]) {
      variantdata.add(BVariantData.fromJson(item));
    }

    if (json["product_outlet"] != null){
      var po = json["product_outlet"]["data"];
      price = po["price"];
    }
  }

  BVariantDetails.clone(BVariantDetails variant) {
    this.id = variant.id;
    this.name = variant.name;
    this.price = variant.price;
    this.tax = variant.tax;
    this.type = variant.type;
    this.is_all_location_stock = variant.is_all_location_stock;
    this.is_all_location_price = variant.is_all_location_price;
    this.is_sellable = variant.is_sellable;
    this.is_stock_tracked = variant.is_stock_tracked;
    this.has_alertstock = variant.has_alertstock;
    this.alert_stock_limit = variant.alert_stock_limit;
    this.has_modifier = variant.has_modifier;
    this.has_variant = variant.has_variant;
    this.use_outlet_tax = variant.use_outlet_tax;
    this.parent_id = variant.parent_id;
    this.amount = variant.amount;
    this.updated_at = variant.updated_at;
    this.stock = variant.stock;
    this.barcode = variant.barcode;

    this.variantdata.clear();
    for (BVariantData data in variant.variantdata) {
      variantdata.add(BVariantData.clone(data));
    }
  }

  BVariantDetails.fromMap(Map map) {
    id = map["id"];
    name = map["name"];
    price = map["price"];
    tax = map["tax"];
    type = map["type"];
    alert_stock_limit = map["alert_stock_limit"];
    parent_id = map["parent_id"];
    amount = map["amount"];
    updated_at = map["updated_at"];
    stock = map["stock"];
    barcode = map["barcode"];

    is_all_location_stock = map["is_all_location_stock"] == 1 ? true : false;
    is_all_location_price = map["is_all_location_price"] == 1 ? true : false;
    is_sellable = map["is_sellable"] == 1 ? true : false;
    use_outlet_tax = map["use_outlet_tax"] == 1 ? true : false;
    is_stock_tracked = map["is_stock_tracked"] == 1 ? true : false;
    has_alertstock = map["has_alertstock"] == 1 ? true : false;
    has_modifier = map["has_modifier"] == 1 ? true : false;
    has_variant = map["has_variant"] == 1 ? true : false;

    if (map["matrixdata"] != null) {
      var arr = json.decode(map["matrixdata"]);
      for (Map data in arr) {
        variantdata.add(BVariantData.fromMap(data));
      }
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["tax"] = tax;
    map["type"] = type;
    map["alert_stock_limit"] = alert_stock_limit;
    map["parent_id"] = parent_id;
    map["amount"] = amount;
    map["updated_at"] = updated_at;
    map["stock"] = stock;
    map["barcode"] = barcode;

    map["is_all_location_stock"] = is_all_location_stock ? 1 : 0;
    map["is_all_location_price"] = is_all_location_price ? 1 : 0;
    map["is_sellable"] = is_sellable ? 1 : 0;
    map["use_outlet_tax"] = use_outlet_tax ? 1 : 0;
    map["is_stock_tracked"] = is_stock_tracked ? 1 : 0;
    map["has_alertstock"] = has_alertstock ? 1 : 0;
    map["has_modifier"] = has_modifier ? 1 : 0;
    map["has_variant"] = has_variant ? 1 : 0;

    List<Map> arr = List();
    if (variantdata != null)
      for (BVariantData data in variantdata) {
        arr.add(data.toMap());
      }
    map['matrixdata'] = json.encode(arr);
    return map;
  }
}
