import 'dart:convert';

import 'package:pawoon/Bean/BCategory.dart';
import 'package:pawoon/Bean/BVariant.dart';
import 'package:pawoon/Bean/BModifier.dart';

import 'BVariantDetails.dart';

class BProduct {
  var id;
  var name;
  var sku;
  var price;
  var barcode;
  var desc;
  var img;
  var tax;
  var stock_unit;
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
  var v1_id;
  var amount;
  var updated_at;
  var deleted_at;
  var stock;
  bool is_active = true;
  BCategory category;
  // var category_id;
  // var category_name;
  bool isFav = false;
  List<BModifier> modifiers = List();
  List<BVariant> variant = List();
  List<BVariantDetails> variantdetails = List();

  BProduct.clone(BProduct prod, {multiplier=1}) {
    this.id = prod.id;
    this.name = prod.name;
    this.sku = prod.sku;
    this.price = prod.price * multiplier;
    this.barcode = prod.barcode;
    this.desc = prod.desc;
    this.img = prod.img;
    this.tax = prod.tax;
    this.stock_unit = prod.stock_unit;
    this.type = prod.type;
    this.is_all_location_stock = prod.is_all_location_stock;
    this.is_all_location_price = prod.is_all_location_price;
    this.is_sellable = prod.is_sellable;
    this.is_stock_tracked = prod.is_stock_tracked;
    this.has_alertstock = prod.has_alertstock;
    this.alert_stock_limit = prod.alert_stock_limit;
    this.has_modifier = prod.has_modifier;
    this.has_variant = prod.has_variant;
    this.use_outlet_tax = prod.use_outlet_tax;
    this.parent_id = prod.parent_id;
    this.v1_id = prod.v1_id;
    this.amount = prod.amount;
    this.updated_at = prod.updated_at;
    this.deleted_at = prod.deleted_at;
    this.category = prod.category;
    this.stock = prod.stock;
    this.is_active = prod.is_active;
    // this.category_id = prod.category_id;
    // this.category_name = prod.category_name;

    this.modifiers.clear();
    for (BModifier mod in prod.modifiers) {
      this.modifiers.add(BModifier.clone(mod));
    }

    this.variant.clear();
    for (BVariant mat in prod.variant) {
      this.variant.add(BVariant.clone(mat));
    }

    this.variantdetails.clear();
    for (BVariantDetails det in prod.variantdetails) {
      this.variantdetails.add(BVariantDetails.clone(det));
    }
  }

  BProduct.fromJson(Map json)
      : id = json["id"],
        name = json["name"],
        sku = json["sku"],
        price = json["price"],
        barcode = json["barcode"],
        desc = json["desc"],
        img = json["img"],
        tax = json["tax"],
        stock_unit = json["stock_unit"],
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
        v1_id = json["v1_id"],
        amount = json["amount"],
        stock = json["stock"],
        updated_at = json["updated_at"],
        deleted_at = json["deleted_at"] {
    // do other things
    if (json["category"] != null) {
      // category_id = json["category"]["data"]["id"];
      // category_name = json["category"]["data"]["name"];
      category = BCategory.fromJson(json["category"]["data"]);
    } else {
      category = BCategory.kosongan();
    }

    if (json["modifier_groups"] != null &&
        json["modifier_groups"]["data"] != null) {
      modifiers.clear();
      for (var item in json["modifier_groups"]["data"]) {
        modifiers.add(BModifier.fromJson(item));
      }
    }

    if (json["matrix"] != null && json["matrix"]["data"] != null) {
      variant.clear();
      for (var item in json["matrix"]["data"]) {
        variant.add(BVariant.fromJson(item));
      }
    }
  }

/* -------------------------------------------------------------------------- */
/*                                     DB                                     */
/* -------------------------------------------------------------------------- */
  BProduct.fromMap(Map map) {
    id = map["id"];
    name = map["name"];
    sku = map["sku"];
    price = map["price"];
    barcode = map["barcode"];
    desc = map["desc"];
    img = map["img"];
    tax = map["tax"];
    stock_unit = map["stock_unit"];
    type = map["type"];
    is_all_location_stock = map["is_all_location_stock"];
    is_all_location_price = map["is_all_location_price"];
    is_sellable = map["is_sellable"];
    is_stock_tracked = map["is_stock_tracked"];
    has_alertstock = map["has_alertstock"];
    alert_stock_limit = map["alert_stock_limit"];
    has_modifier = map["has_modifier"];
    has_variant = map["has_variant"];
    use_outlet_tax = map["use_outlet_tax"];
    parent_id = map["parent_id"];
    v1_id = map["v1_id"];
    amount = map["amount"];
    stock = map["stock"];
    updated_at = map["updated_at"];
    deleted_at = map["deleted_at"];
    if (map["is_active"] == null)
      is_active = true;
    else
      is_active = map["is_active"] == 1 ? true : false;
    // category_id = map["category_id"];
    // category_name = map["category_name"];

    if (map["modifiers"] != null)
      for (Map data in map["modifiers"]) {
        modifiers.add(BModifier.fromMap(data));
      }

    if (map["variant"] != null)
      for (Map data in map["variant"]) {
        variant.add(BVariant.fromMap(data));
      }

    if (map["category"] != null) category = BCategory.fromMap(map["category"]);

    if (map["variantdetails"] != null) {
      variantdetails.clear();
      for (Map data in map["variantdetails"]) {
        variantdetails.add(BVariantDetails.fromMap(data));
      }
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["sku"] = sku;
    map["price"] = price;
    map["barcode"] = barcode;
    map["desc"] = desc;
    map["img"] = img;
    map["tax"] = tax;
    map["stock_unit"] = stock_unit;
    map["type"] = type;
    map["is_all_location_stock"] = is_all_location_stock;
    map["is_all_location_price"] = is_all_location_price;
    map["is_sellable"] = is_sellable;
    map["is_stock_tracked"] = is_stock_tracked;
    map["has_alertstock"] = has_alertstock;
    map["alert_stock_limit"] = alert_stock_limit;
    map["has_modifier"] = has_modifier;
    map["has_variant"] = has_variant;
    map["use_outlet_tax"] = use_outlet_tax;
    map["parent_id"] = parent_id;
    map["v1_id"] = v1_id;
    map["amount"] = amount;
    map["stock"] = stock;
    map["updated_at"] = updated_at;
    map["deleted_at"] = deleted_at;
    map["category"] = category.toMap();
    map["is_active"] = is_active ? 1 : 0;
    // print("${map["category"]}");
    // map["category_id"] = category_id;
    // map["category_name"] = category_name;

    List<Map> arrMatrix = List();
    if (variant != null)
      for (BVariant data in variant) {
        arrMatrix.add(data.toMap());
      }
    map["variant"] = arrMatrix;

    List<Map> arrModifiers = List();
    if (modifiers != null)
      for (BModifier data in modifiers) {
        arrModifiers.add(data.toMap());
      }
    map["modifiers"] = arrModifiers;

    List<Map> arrVariantDetails = List();
    if (variantdetails != null)
      for (BVariantDetails data in variantdetails) {
        arrVariantDetails.add(data.toMap());
      }
    map["variantdetails"] = arrVariantDetails;

    return map;
  }

  Map<String, dynamic> toDb() {
    Map<String, dynamic> map = Map();
    map["id"] = id;
    map["name"] = name;
    map["data_json"] = json.encode(this.toMap());

    return map;
  }
}
