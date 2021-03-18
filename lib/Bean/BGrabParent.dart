import 'dart:convert';

import 'package:pawoon/Bean/BGrabModifier.dart';
import 'package:pawoon/Bean/BGrabOrder.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOutlet.dart';

import 'BDevice.dart';
import 'BOrder.dart';

class BGrabParent {
  var timestamp;
  var integration_order_id;
  var online_order_status;
  var created_at;
  var updated_at;
  var customer_id;
  var customer_email;
  var total_item_cost;
  var customer_phone;
  var customer_name;
  var note;
  var total_change;
  var id;
  var receipt_code;
  var outlet_id;
  var device_id;
  var cashier_id;
  var sales_type_id;
  var sales_type_name;
  var grab_order_id;
  var grab_short_order_number;
  var source;
  var subtotal;
  var total_tax;
  var total_service;
  var final_amount;
  var discount_title;
  var discount_amount;
  var transaction_id;
  var void_uuid;
  var done = 1;

  BOutlet outlet;
  BOperator op;
  BDevice device;

  List<BGrabOrder> items = List();
  List<BGrabTax> taxes_and_services = List();
  BGrabPayment payment;
  BGrabSalesType sales_type;

  BGrabParent.fromJson(Map json)
      : timestamp = json["device_timestamp"],
        integration_order_id = json["integration_order_id"],
        transaction_id = json["transaction_id"],
        void_uuid = json["void_uuid"],
        online_order_status = json["online_order_status"],
        created_at = json["created_at"],
        updated_at = json["updated_at"],
        customer_id = json["customer_id"],
        customer_email = json["customer_email"],
        total_item_cost = json["total_item_cost"],
        customer_phone = json["customer_phone"],
        customer_name = json["customer_name"],
        note = json["note"],
        total_change = json["total_change"],
        id = json["id"],
        receipt_code = json["receipt_code"],
        outlet_id = json["outlet_id"],
        device_id = json["device_id"],
        cashier_id = json["cashier_id"],
        sales_type_id = json["sales_type_id"],
        sales_type_name = json["sales_type_name"],
        grab_order_id = json["grab_order_id"],
        grab_short_order_number = json["grab_short_order_number"],
        source = json["source"],
        subtotal = json["subtotal"],
        total_tax = json["total_tax"],
        total_service = json["total_service"],
        final_amount = json["final_amount"],
        discount_title = json["discount_title"],
        discount_amount = json["discount_amount"] {
    if (json["items"] != null) {
      items.clear();
      for (var item in json["items"]) {
        BGrabOrder order = BGrabOrder.fromJson(item);
        items.add(order);
      }
    }

    if (json["payment"] != null) {
      payment = BGrabPayment.fromJson(json["payment"]);
    }

    if (json["sales_type"] != null) {
      sales_type = BGrabSalesType.fromJson(json["sales_type"]);
    }

    if (json["taxes_and_services"] != null) {
      taxes_and_services.clear();
      for (var item in json["taxes_and_services"]) {
        taxes_and_services.add(BGrabTax.fromJson(item));
      }
    }
  }

  Map toMap() {
    Map<String, dynamic> map = Map();
    map["device_timestamp"] = timestamp;
    map["integration_order_id"] = integration_order_id;
    map["transaction_id"] = transaction_id;
    map["void_uuid"] = void_uuid;
    map["online_order_status"] = online_order_status;
    map["created_at"] = created_at;
    map["updated_at"] = updated_at;
    map["customer_id"] = customer_id;
    map["customer_email"] = customer_email;
    map["total_item_cost"] = total_item_cost;
    map["customer_phone"] = customer_phone;
    map["customer_name"] = customer_name;
    map["note"] = note;
    map["total_change"] = total_change;
    map["id"] = id;
    map["receipt_code"] = receipt_code;
    map["outlet_id"] = outlet_id;
    map["device_id"] = device_id;
    map["cashier_id"] = cashier_id;
    map["sales_type_id"] = sales_type_id;
    map["sales_type_name"] = sales_type_name;
    map["grab_order_id"] = grab_order_id;
    map["grab_short_order_number"] = grab_short_order_number;
    map["source"] = source;
    map["subtotal"] = subtotal;
    map["total_tax"] = total_tax;
    map["total_service"] = total_service;
    map["final_amount"] = final_amount;
    map["discount_title"] = discount_title;
    map["discount_amount"] = discount_amount;

    map["payment"] = json.encode(payment.toMap());
    map["sales_type"] = json.encode(sales_type.toMap());

    List<Map> arrTax = List();
    for (var item in taxes_and_services) {
      arrTax.add(item.toMap());
    }
    map["taxes_and_services"] = json.encode(arrTax);

    List<Map> arrItems = List();
    for (var item in items) {
      arrItems.add(item.toMap());
    }
    map["items"] = json.encode(arrItems);

    if (this.op != null) map["operator"] = json.encode(this.op.saveObject());
    if (this.outlet != null)
      map["outlet"] = json.encode(this.outlet.saveObject());
    if (this.device != null)
      map["device"] = json.encode(this.device.saveObject());

    return map;
  }

  BGrabParent.fromMap(Map map) {
    timestamp = map["device_timestamp"];
    integration_order_id = map["integration_order_id"];
    transaction_id = map["transaction_id"];
    void_uuid = map["void_uuid"];
    online_order_status = map["online_order_status"];
    created_at = map["created_at"];
    updated_at = map["updated_at"];
    customer_id = map["customer_id"];
    customer_email = map["customer_email"];
    total_item_cost = map["total_item_cost"];
    customer_phone = map["customer_phone"];
    customer_name = map["customer_name"];
    note = map["note"];
    total_change = map["total_change"];
    id = map["id"];
    receipt_code = map["receipt_code"];
    outlet_id = map["outlet_id"];
    device_id = map["device_id"];
    cashier_id = map["cashier_id"];
    sales_type_id = map["sales_type_id"];
    sales_type_name = map["sales_type_name"];
    grab_order_id = map["grab_order_id"];
    grab_short_order_number = map["grab_short_order_number"];
    source = map["source"];
    subtotal = map["subtotal"];
    total_tax = map["total_tax"];
    total_service = map["total_service"];
    final_amount = map["final_amount"];
    discount_title = map["discount_title"];
    discount_amount = map["discount_amount"];

    if (map["payment"] != null)
      payment = BGrabPayment.fromMap(json.decode(map["payment"]));

    if (map["sales_type"] != null)
      sales_type = BGrabSalesType.fromMap(json.decode(map["sales_type"]));

    if (map["items"] != null)
      for (var item in json.decode(map["items"])) {
        items.add(BGrabOrder.fromMap(item));
      }

    if (map["taxes_and_services"] != null)
      for (var item in json.decode(map["taxes_and_services"])) {
        taxes_and_services.add(BGrabTax.fromMap(item));
      }

    if (map["operator"] != null)
      this.op = BOperator.parseObject(json.decode(map["operator"]));
    if (map["outlet"] != null)
      this.outlet = BOutlet.parseObject(json.decode(map["outlet"]));
    if (map["device"] != null)
      this.device = BDevice.parseObject(json.decode(map["device"]));
  }
}

class BGrabPayment {
  var timestamp;
  var created_at;
  var updated_at;
  var deleted_at;
  var id;
  var title;
  var method;
  var transaction_id;
  var device_id;
  var cashier_id;
  var amount;
  BGrabPayment.fromJson(Map json)
      : timestamp = json["timestamp"],
        created_at = json["created_at"],
        updated_at = json["updated_at"],
        deleted_at = json["deleted_at"],
        id = json["id"],
        title = json["title"],
        method = json["method"],
        transaction_id = json["transaction_id"],
        device_id = json["device_id"],
        cashier_id = json["cashier_id"],
        amount = json["amount"];

  Map toMap() {
    Map<String, dynamic> map = Map();
    map["timestamp"] = timestamp;
    map["created_at"] = created_at;
    map["updated_at"] = updated_at;
    map["deleted_at"] = deleted_at;
    map["id"] = id;
    map["title"] = title;
    map["method"] = method;
    map["transaction_id"] = transaction_id;
    map["device_id"] = device_id;
    map["cashier_id"] = cashier_id;
    map["amount"] = amount;
    return map;
  }

  BGrabPayment.fromMap(Map map)
      : timestamp = map["timestamp"],
        created_at = map["created_at"],
        updated_at = map["updated_at"],
        deleted_at = map["deleted_at"],
        id = map["id"],
        title = map["title"],
        method = map["method"],
        transaction_id = map["transaction_id"],
        device_id = map["device_id"],
        cashier_id = map["cashier_id"],
        amount = map["amount"];
}

class BGrabTax {
  var title;
  var type;
  var percentage;
  var amount;
  var tax_and_service_id;
  var created_at;
  var updated_at;

  BGrabTax.fromJson(Map json)
      : title = json["title"],
        type = json["type"],
        percentage = json["percentage"],
        amount = json["amount"],
        tax_and_service_id = json["tax_and_service_id"],
        created_at = json["created_at"],
        updated_at = json["updated_at"];

  Map toMap() {
    Map<String, dynamic> map = Map();
    map["title"] = title;
    map["type"] = type;
    map["percentage"] = percentage;
    map["amount"] = amount;
    map["tax_and_service_id"] = tax_and_service_id;
    map["created_at"] = created_at;
    map["updated_at"] = updated_at;
    return map;
  }

  BGrabTax.fromMap(Map map)
      : title = map["title"],
        type = map["type"],
        percentage = map["percentage"],
        amount = map["amount"],
        tax_and_service_id = map["tax_and_service_id"],
        created_at = map["created_at"],
        updated_at = map["updated_at"];
}

class BGrabSalesType {
  var created_at;
  var updated_at;
  var uuid;
  var id;
  var name;
  var mode;
  BGrabSalesType.fromJson(Map json)
      : created_at = json["created_at"],
        updated_at = json["updated_at"],
        uuid = json["uuid"],
        id = json["id"],
        name = json["name"],
        mode = json["mode"];

  Map toMap() {
    Map<String, dynamic> map = Map();

    map["created_at"] = created_at;
    map["updated_at"] = updated_at;
    map["uuid"] = uuid;
    map["id"] = id;
    map["name"] = name;
    map["mode"] = mode;
    return map;
  }

  BGrabSalesType.fromMap(Map map)
      : created_at = map["created_at"],
        updated_at = map["updated_at"],
        uuid = map["uuid"],
        id = map["id"],
        name = map["name"],
        mode = map["mode"];
}
