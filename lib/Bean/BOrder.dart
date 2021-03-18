import 'dart:convert';

import 'package:pawoon/Bean/BCustomAmount.dart';
import 'package:pawoon/Bean/BVariantData.dart';
import 'package:pawoon/Bean/BModifierData.dart';

import 'BProduct.dart';

enum DiscType {
  nominal,
  percentage,
}

class BOrder {
  var id;
  var nameOrder;
  num qty = 0;
  num qtyTemp = 0;
  num priceTotal = 0;
  num disc = 0;
  DiscType discType;
  String notes = "";
  BProduct product;
  List<BModifierData> modifiers = List();
  List<BVariantData> variants = List();
  var idcustomamount= "";

  BOrder.clone(BOrder order, {multiplier = 1}) {
    this.id = order.id;
    this.nameOrder = order.nameOrder;
    this.qty = order.qty * multiplier;
    this.qtyTemp = order.qtyTemp;
    this.priceTotal = order.priceTotal * multiplier;
    this.disc = order.disc * multiplier;
    this.discType = order.discType;
    this.notes = order.notes;
    this.product = BProduct.clone(order.product, multiplier: multiplier);

    if (order.modifiers != null) {
      this.modifiers.clear();
      for (BModifierData data in order.modifiers) {
        this.modifiers.add(BModifierData.clone(data, multiplier: multiplier));
      }
    }

    if (order.variants != null) {
      this.variants.clear();
      for (BVariantData data in order.variants) {
        this.variants.add(BVariantData.clone(data));
      }
    }
  }

  BOrder(
      {qty = 0,
      BProduct product,
      List<BModifierData> modifiers,
      List<BVariantData> variants}) {
    this.qty = qty;
    this.product = product;
    this.modifiers = modifiers;
    this.variants = variants;

    var prodid = "";
    var modifiers_id = "";
    var variants_id = "";

    // priceTotal = product.price;
    // print(product.price);

    if (product != null) {
      prodid = product.id;
    }

    if (modifiers != null) {
      for (BModifierData data in modifiers) {
        modifiers_id += "${data.id}-${data.qty}";
      }
    }

    if (variants != null) {
      for (BVariantData data in variants) {
        variants_id += "${data.id}";
      }
    }
    id = "$prodid-$modifiers_id-$variants_id";
  }

/* -------------------------------------------------------------------------- */
/*                                     DB                                     */
/* -------------------------------------------------------------------------- */
  Map toMap() {
    Map map = Map();
    map["id"] = id ?? "";
    map["nameOrder"] = nameOrder;
    map["qty"] = qty;
    map["qtyTemp"] = qtyTemp;
    map["priceTotal"] = priceTotal;
    map["disc"] = disc;
    map["discType"] = discType;
    map["notes"] = notes;
    map["product"] = product.toMap();

    List<Map> arrVariants = List();
    if (variants != null)
      for (BVariantData data in variants) {
        arrVariants.add(data.toMap());
      }
    map["variants"] = arrVariants;

    List<Map> arrModifiers = List();
    if (modifiers != null)
      for (BModifierData data in modifiers) {
        arrModifiers.add(data.toMap());
      }
    map["modifiers"] = arrModifiers;

    return map;
  }

  BOrder.fromMap(Map<dynamic, dynamic> map) {
    id = map["id"];
    nameOrder = map["nameOrder"];
    qty = map["qty"];
    qtyTemp = map["qtyTemp"];
    priceTotal = map["priceTotal"];
    disc = map["disc"];
    discType = map["discType"];
    notes = map["notes"];

    if (map["product"] != null) product = BProduct.fromMap(map["product"]);

    if (map["variants"] != null)
      for (Map data in map["variants"]) {
        variants.add(BVariantData.fromMap(data));
      }

    if (map["modifiers"] != null)
      for (Map data in map["modifiers"]) {
        modifiers.add(BModifierData.fromMap(data));
      }
  }

  Map objectToServer() {
    Map map = Map();
    map["id"] = 0;

    map["cost"] = 0;
    map["discount_amount"] = 0;
    map["discount_percentage"] = 0;

    num modAmt = 0;
    num modCost = 0;
    List<Map> arrMods = List();
    if (modifiers != null) {
      for (BModifierData mod in modifiers) {
        modAmt += mod.price * mod.qty;
        modCost += mod.cost;
        arrMods.add(mod.objectToServer());
      }
      map["modifiers"] = arrMods;
      map["modifiers_amount"] = modAmt;
      map["modifiers_cost"] = modCost;
      map["modifiers_discount"] = 0;
    }

    if (product != null) {
      map["price"] = product.price;
      map["amount"] = product.price;
      map["product_id"] = product.id;
    } else {
      map["price"] = this.priceTotal;
      map["amount"] = this.priceTotal;
      map["product_id"] = this.idcustomamount;
    }
    map["notes"] = this.notes ?? "";
    map["qty"] = qty;
    map["subtotal"] = (priceTotal + modAmt);
    map["taxes_and_services"] = [];
    map["title"] = nameOrder;
    return map;
  }

  BOrder.customAmount({amount, notes, title, idcustom, multiplier = 1}) {
    this.qty = 1 * multiplier;
    this.notes = notes ?? "";
    this.priceTotal = amount * multiplier ?? 0;
    this.nameOrder = "$title";
    this.idcustomamount = idcustom;
  }
}
