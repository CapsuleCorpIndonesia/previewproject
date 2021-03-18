import 'dart:convert';
import 'dart:math';

import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BPelanggan.dart';
import 'package:pawoon/Bean/BSalesType.dart';
import 'package:pawoon/Helper/Helper.dart';

import 'BCustomAmount.dart';
import 'BDevice.dart';
import 'BMeja.dart';
import 'BOrder.dart';
import 'BOutlet.dart';
import 'BPayment.dart';
import 'BTax.dart';

class BOrderParent {
  Map<String, BOrder> mappingOrder = Map();
  BCustomAmount customAmount;

  var id;
  num subtotal = 0;
  double tax = 0;
  String taxStr = "";
  double taxAmount = 0;
  double service = 0;
  String serviceStr = "";
  double serviceAmount = 0;
  double grandTotal = 0;
  double pembulatan = 0;
  String pembulatanStr = "";
  int timestamp = 0;
  String notes = "";
  List<BPayment> payment = List();
  // String paymentMethod = "";
  // New
  int total_change = 0;
  int total_payment = 0;
  double latitude = 0.0;
  double longitude = 0.0;
  String app_version = "";
  String manufacturer = "";
  String model = "";
  String os_version = "";
  num total_discount = 0;
  num receipt_total_discount = 0;
  num discount_amount = 0;
  num discount_percentage = 0;
  String receipt_code;
  int done = 0;
  String server_id = "";
  bool update = false;
  // Objects new
  BSalesType salestype = BSalesType();
  BOutlet outlet;
  BOperator op;
  BDevice device;
  BPelanggan pelanggan;
  BMeja meja;
  Map<String, BTax> mappingTaxServices = Map();
  int revision = 0;

  bool enableService = true;
  bool enableTax = true;
  String void_reason = "";
  String void_receipt_code = "";
  String status = "success";
  String rekapid;

  BOrderParent.clone(BOrderParent order, {multiplier = 1}) {
    this.customAmount =
        BCustomAmount.clone(order.customAmount, multiplier: multiplier);

    this.id = order.id;
    this.subtotal = order.subtotal * multiplier;
    this.tax = order.tax;
    this.taxStr = order.taxStr;
    this.taxAmount = order.taxAmount;
    this.service = order.service;
    this.serviceStr = order.serviceStr;
    this.serviceAmount = order.serviceAmount;
    this.grandTotal = order.grandTotal * multiplier;
    this.pembulatan = order.pembulatan * multiplier;
    this.pembulatanStr = order.pembulatanStr;
    this.timestamp = order.timestamp;
    this.notes = order.notes;
    this.total_change = order.total_change;
    this.total_payment = order.total_payment;
    this.latitude = order.latitude;
    this.longitude = order.longitude;
    this.app_version = order.app_version;
    this.manufacturer = order.manufacturer;
    this.model = order.model;
    this.os_version = order.os_version;
    this.total_discount = order.total_discount;
    this.receipt_total_discount = order.receipt_total_discount;
    this.discount_amount = order.discount_amount;
    this.discount_percentage = order.discount_percentage;
    this.receipt_code = order.receipt_code;
    this.done = order.done;
    this.server_id = order.server_id;
    this.update = order.update;
    this.salestype = order.salestype;

    this.outlet = order.outlet;
    this.op = order.op;
    this.device = order.device;
    this.enableService = order.enableService;
    this.enableTax = order.enableTax;
    this.void_receipt_code = order.void_receipt_code;
    this.void_reason = order.void_reason;
    this.status = order.status;

    order.mappingTaxServices.forEach((key, value) {
      this.mappingTaxServices[key] = BTax.clone(value, multiplier: multiplier);
    });

    order.mappingOrder.forEach((key, value) {
      this.mappingOrder[key] = BOrder.clone(value, multiplier: multiplier);
    });

    for (var item in order.payment) {
      this.payment.add(BPayment.clone(item, multiplier: multiplier));
    }

    this.pelanggan = BPelanggan.clone(order.pelanggan);
    this.meja = BMeja.clone(order.meja);
    this.revision = order.revision;
    this.rekapid = order.rekapid;
  }

  // Constructor
  BOrderParent() {
    timestamp = DateTime.now().millisecondsSinceEpoch;
    receipt_code = Helper.generateRandomString();
  }

  Map toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = this.id;
    map['subtotal'] = this.subtotal;
    map['tax'] = this.tax;
    map['taxStr'] = this.taxStr;
    map['taxAmount'] = this.taxAmount;
    map['service'] = this.service;
    map['serviceStr'] = this.serviceStr;
    map['serviceAmount'] = this.serviceAmount;
    map['grandTotal'] = this.grandTotal;
    map['pembulatan'] = this.pembulatan;
    map['pembulatanStr'] = this.pembulatanStr;
    map['timestamp'] = this.timestamp;
    if (customAmount != null) {
      map['customAmount'] = json.encode(this.customAmount.toMap());
    }

    Map<String, Map> arrOrder = Map();
    if (mappingOrder != null) {
      mappingOrder.forEach((key, value) {
        arrOrder[key] = value.toMap();
      });
    }
    map["mappingOrder"] = json.encode(arrOrder);
    map["notes"] = this.notes;
    map["status_done"] = this.done;
    map["status_update"] = this.update;
    map["receipt_code"] = this.receipt_code;
    map["void_receipt_code"] = this.void_receipt_code;
    map["void_reason"] = this.void_reason;
    map["status"] = this.status;
    map["rekapid"] = this.rekapid;

    // New
    if (this.salestype != null)
      map["salestype"] = json.encode(this.salestype.toMap());
    if (this.op != null) map["operator"] = json.encode(this.op.saveObject());
    if (this.outlet != null)
      map["outlet"] = json.encode(this.outlet.saveObject());
    if (this.device != null)
      map["device"] = json.encode(this.device.saveObject());
    if (this.pelanggan != null)
      map["pelanggan"] = json.encode(this.pelanggan.toMap());

    if (this.mappingTaxServices != null) {
      List<Map> arrTax = List();
      this.mappingTaxServices.forEach((key, value) {
        arrTax.add(value.toMap());
      });
      map["tax_services"] = json.encode(arrTax);
    }

    if (this.payment != null) {
      List<Map> arrpayments = List();
      for (BPayment p in this.payment) {
        arrpayments.add(p.toMap());
      }

      map["payment"] = json.encode(arrpayments);
    } else {
      map["payment"] = "";
    }
    map["enableService"] = this.enableService ? 1 : 0;
    map["enableTax"] = this.enableTax ? 1 : 0;
    map["revision"] = revision;

    return map;
  }

  BOrderParent.fromMap(Map<dynamic, dynamic> map) {
    this.id = map['id'];
    this.subtotal = map['subtotal'];
    this.tax = map['tax'];
    this.taxStr = map['taxStr'];
    this.taxAmount = map['taxAmount'];
    this.service = map['service'];
    this.serviceStr = map['serviceStr'];
    this.serviceAmount = map['serviceAmount'];
    this.grandTotal = map['grandTotal'];
    this.timestamp = map['timestamp'];
    this.pembulatan = map['pembulatan'];
    this.pembulatanStr = map['pembulatanStr'];
    this.revision = map["revision"];
    this.enableService = map["enableService"] == 1;
    this.enableTax = map["enableTax"] == 1;
    this.void_receipt_code = map["void_receipt_code"];
    this.void_reason = map["void_reason"];
    this.status = map["status"];
    this.rekapid = map["rekapid"];
    if (map['customAmount'] != null)
      this.customAmount =
          BCustomAmount.fromMap(json.decode(map['customAmount']));

    if (map['mappingOrder'] != null) {
      Map mapOrder = json.decode(map["mappingOrder"]);
      mapOrder.forEach((key, value) {
        mappingOrder[key] = BOrder.fromMap(value);
      });
    }

    this.notes = map["notes"];
    this.done = map["status_done"];
    this.update = map["status_update"] == 1 ? true : false;
    this.receipt_code = map["receipt_code"];

    // New
    if (map["salestype"] != null)
      this.salestype = BSalesType.fromMap(json.decode(map["salestype"]));
    if (map["operator"] != null)
      this.op = BOperator.parseObject(json.decode(map["operator"]));
    if (map["outlet"] != null)
      this.outlet = BOutlet.parseObject(json.decode(map["outlet"]));
    if (map["device"] != null)
      this.device = BDevice.parseObject(json.decode(map["device"]));
    if (map["pelanggan"] != null)
      this.pelanggan = BPelanggan.fromMap(json.decode(map["pelanggan"]));

    if (map["tax_services"] != null) {
      this.mappingTaxServices.clear();
      for (var item in json.decode(map["tax_services"])) {
        BTax tax = BTax.fromMap(item);
        this.mappingTaxServices[tax.type] = tax;
      }
    }

    if (map["payment"] != null) {
      this.payment.clear();
      for (var item in json.decode(map["payment"])) {
        BPayment p = BPayment.fromMap(item);
        this.payment.add(p);
      }
    }
  }

  Map objectToServer({reason = ""}) {
    Map map = Map();
    map["local_id"] = this.id;

    // Operator
    map["cashier_id"] = this.op.id;

    // Device
    map["device_id"] = this.device.id;
    map["device_timestamp"] = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", timestamp: this.timestamp));
    map["timestamp"] = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", timestamp: this.timestamp));

    // Pelanggan
    map["customer_email"] = this.pelanggan.email;
    map["customer_name"] = this.pelanggan.name;
    map["customer_phone"] = this.pelanggan.phone;

    // Note
    map["note"] = this.notes;

    // Outlet
    map["outlet_id"] = this.outlet.id;

    // Status
    // if (multiplier == -1) {
    // map["status"] = "void";
    map["void_receipt_code"] = this.void_receipt_code;
    // map["receipt_code"] = Helper.generateRandomString();
    map["void_reason"] = this.void_reason;
    // } else {
    map["status"] = this.status;
    map["receipt_code"] = this.receipt_code;
    // }
    map["done"] = this.done;
    map["update"] = this.update;

    // map["total_payment"] = this.grandTotal.toDouble();
    map["installment"] = 0;
    map["installment_period"] = 0;

    // Amount
    map["subtotal"] = subtotal.toDouble();
    map["total_discount"] = (0).toDouble() * -1; // TODO
    map["receipt_total_discount"] = (0).toDouble() * -1; // TODO
    map["discount_amount"] = (0).toDouble() * -1; // TODO
    map["discount_percentage"] = (0).toDouble() * -1; // TODO
    map["round_amount"] = pembulatan.toDouble() * -1;
    map["final_amount"] = grandTotal.toDouble();

    // coordinate
    map["coordinate"] = {
      "lat": this.latitude,
      "long": this.longitude,
    };

    // device_details
    map["device_details"] = {
      "app_version": this.app_version,
      "manufacturer": this.manufacturer,
      "model": this.model,
      "os_version": this.os_version,
    };

    // items
    map["items"] = List();
    num total_item_amount = 0;
    num total_item_cost = 0;
    num total_item_discount = 0;
    mappingOrder.forEach((key, value) {
      total_item_amount += value.product.price;
      total_item_cost += 0;
      total_item_discount += value.disc;
      map["items"].add(value.objectToServer());
    });

    if (customAmount != null && customAmount.total > 0) {
      map["items"].add(BOrder.customAmount(
              amount: customAmount.total,
              notes: customAmount.notes,
              title: customAmount.name,
              idcustom: customAmount.id)
          .objectToServer());
    }

    map["total_item_amount"] = total_item_amount.toDouble();
    map["total_item_cost"] = total_item_cost.toDouble();
    map["total_item_discount"] = total_item_discount.toDouble();

    /*
    [
      map["id"];
      map["amount"];
      map["cost"];
      map["discount_amount"];
      map["discount_percentage"];
      map["modifiers_amount"];
      map["modifiers_cost"];
      map["modifiers_discount"];
      map["price"];
      map["product_id"];
      map["qty"];
      map["subtotal"];
      map["taxes_and_services"];
      map["title"];
    ]
    */

    // payments
    List<Map> arrPayments = List();
    total_payment = 0;
    total_change = 0;
    for (BPayment p in payment) {
      // if (p.amount == 0) p.amount = this.total_payment * multiplier;
      // if (p.change == 0) p.change = this.total_change.toDouble() * multiplier;
      this.total_payment += (p.amount).toInt();
      this.total_change += (p.change).toInt();
      arrPayments.add(p.toObjectServer());
    }
    map["payments"] = arrPayments;
    /*
    [
      map["id"];
      map["amount"];
      map["change"];
      map["method"];
      map["company_payment_method_id"];
      map["timestamp"];
      map["title"];
    ]
    */

    // taxes_and_services
    map["taxes_and_services"] = List();

    taxAmount = 0;
    serviceAmount = 0;
    mappingTaxServices.forEach((key, value) {
      Map mapTax = value.objectToServer();
      if (mapTax["type"] == "tax") taxAmount += mapTax["amount"];
      if (mapTax["type"] == "service") serviceAmount += mapTax["amount"];
      map["taxes_and_services"].add(mapTax);
    });

    // promos
    // map["promos"]
    /*
        map["amount"];
        map["discount"];
        map["get_qty"];
        map["min_purchase"];
        map["min_qty"];
        map["promo_id"];
        map["promo_type"];
        map["qty"];
        map["title"];
        map["type"]; 
       */

    // voucher

    // Pembayaran
    map["total_change"] = this.total_change.toDouble();
    map["total_payment"] = this.total_payment.toDouble();
    map["total_tax"] = taxAmount.toDouble();
    map["total_service"] = serviceAmount.toDouble();

    return map;
  }
}
