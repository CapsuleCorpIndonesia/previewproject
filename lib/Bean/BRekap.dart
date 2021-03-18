import 'dart:convert';

import 'package:pawoon/Bean/BPaymentCustom.dart';
import 'package:pawoon/Helper/Helper.dart';

import 'BOperator.dart';
import 'BRekapCashflow.dart';

class BRekap {
  var cashier_id = "";
  var device_id = "";
  var device_timestamp = "";
  var difference_amount = 0;
  var id = "";
  var total_installment_income = 0;
  var sales_amount = 0;
  var order_begin = "";
  var order_end = "";
  var outlet_id = "";
  var recon_code = "";
  var system_amount = 0;
  var totalActual = 0;
  var total_cash = 0;
  var total_non_cash = 0;
  var total_ongoing_installment_order = 0;
  var totalOrderAmount = 0;
  var total_pending_transaction = 0;
  var cash_in = 0;
  var cash_out = 0;
  var installment_period = 0;
  var installment_sales = 0;
  var void_transactions = 0;
  var actual_income = 0;
  var custom_payment;
  List<BPaymentCustom> custom_payment_json = List();
  List<BRekapCashflow> cashflow = List();
  List<dynamic> integrated_payments = List();
  BOperator op;
  /*
   ""custom_payments"": [
          {
            ""amount"": 500,
            ""company_payment_method_id"": ""3d5f2870-f098-11e9-b433-4d2e621f19f1"",
            ""method"": ""custom"",
            ""title"": ""custom""
          }
        ], 
   */
  /*
  ""integrated_payments"": [
          {
            ""amount"": 1002.0,
            ""method"": ""gopay""
          }
        ],
    */

  // value ini jangan dikirim ke server
  bool temp = false;

  BRekap();
  BRekap.fromJson(Map json)
      : id = json["id"],
        cashier_id = "${json["cashier_id"]}",
        device_id = "${json["device_id"]}",
        device_timestamp = json["device_timestamp"],
        outlet_id = "${json["outlet_id"]}",
        order_begin = json["order_begin"],
        order_end = json["order_end"],
        sales_amount = json["sales_amount"],
        total_cash = json["total_cash"],
        total_non_cash = json["total_non_cash"],
        // custom_payments = json["custom_payments"],
        // integrated_payments = json["integrated_payments"],
        cash_in = json["cash_in"],
        cash_out = json["cash_out"],
        total_pending_transaction = json["total_pending_transaction"],
        system_amount = json["system_amount"],
        difference_amount = json["difference_amount"],
        recon_code = json["recon_code"],
        installment_period = json["installment_period"],
        installment_sales = json["installment_sales"],
        void_transactions = json["void_transactions"],
        actual_income = json["actual_income"] {
    for (var item in json["custom_payments"]) {
      custom_payment_json.add(BPaymentCustom.fromJson2(item));
    }

    for (var item in json["integrated_payments"]) {
      integrated_payments.add(item);
    }
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    if (this.id != null) map["id"] = this.id;
    map["cashier_id"] = this.cashier_id;
    map["device_id"] = this.device_id;
    map["device_timestamp"] = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
    map["difference_amount"] = this.difference_amount;
    map["total_installment_income"] = this.total_installment_income;
    map["sales_amount"] = this.sales_amount;
    map["order_begin"] = this.order_begin;
    map["order_end"] = this.order_end;
    map["outlet_id"] = this.outlet_id;
    map["recon_code"] = this.recon_code;
    map["system_amount"] = this.system_amount;
    map["totalActual"] = this.totalActual;
    map["total_cash"] = this.total_cash;
    map["total_non_cash"] = this.total_non_cash;
    map["total_ongoing_installment_order"] =
        this.total_ongoing_installment_order;
    map["totalOrderAmount"] = this.totalOrderAmount;
    map["total_pending_transaction"] = this.total_pending_transaction;
    map["integrated_payments"] = json.encode(this.integrated_payments);

    List<Map> arrCashflow = List();
    if (cashflow != null) {
      for (BRekapCashflow cf in cashflow) {
        arrCashflow.add(cf.toMap());
      }
    }
    map["cashflow_data"] = json.encode(arrCashflow);
    if (op != null) map["operator"] = json.encode(op.saveObject());
    return map;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    if (this.id != null) map["id"] = this.id;
    map["cashier_id"] = this.cashier_id;
    map["device_id"] = this.device_id;
    map["device_timestamp"] = Helper.formatISOTime(Helper.toDate(
        parseToFormat: "yyyy-MM-dd'T'HH:mm:ss", datetime: DateTime.now()));
    map["difference_amount"] = this.difference_amount;
    map["total_installment_income"] = this.total_installment_income;
    map["sales_amount"] = this.sales_amount;
    map["order_begin"] = this.order_begin;
    map["order_end"] = this.order_end;
    map["outlet_id"] = this.outlet_id;
    map["recon_code"] = this.recon_code;
    map["system_amount"] = this.system_amount;
    map["totalActual"] = this.totalActual;
    map["total_cash"] = this.total_cash;
    map["total_non_cash"] = this.total_non_cash;
    map["total_ongoing_installment_order"] =
        this.total_ongoing_installment_order;
    map["totalOrderAmount"] = this.totalOrderAmount;
    map["total_pending_transaction"] = this.total_pending_transaction;
    map["integrated_payments"] = this.integrated_payments;

    map["custom_payments"] = this.custom_payment;

    return map;
  }

  BRekap.fromMap(Map map) {
    this.id = map["id"];
    this.cashier_id = map["cashier_id"];
    this.device_id = map["device_id"];
    this.difference_amount = map["difference_amount"];
    this.device_timestamp = map["device_timestamp"];
    this.total_installment_income = map["total_installment_income"];
    this.sales_amount = map["sales_amount"];
    this.order_begin = map["order_begin"];
    this.order_end = map["order_end"];
    this.outlet_id = map["outlet_id"];
    this.recon_code = map["recon_code"];
    this.system_amount = map["system_amount"];
    this.totalActual = map["totalActual"];
    this.total_cash = map["total_cash"];
    this.total_non_cash = map["total_non_cash"];
    this.total_ongoing_installment_order =
        map["total_ongoing_installment_order"];
    this.totalOrderAmount = map["totalOrderAmount"];
    this.total_pending_transaction = map["total_pending_transaction"];
    this.integrated_payments = json.decode(map["integrated_payments"]);
    if (map["operator"] != null)
      this.op = BOperator.fromMap(json.decode(map["operator"]));

    if (map["cashflow_data"] != null) {
      cashflow = List();
      for (var item in json.decode(map["cashflow_data"])) {
        cashflow.add(BRekapCashflow.fromMap(item));
      }
    }
  }
}
