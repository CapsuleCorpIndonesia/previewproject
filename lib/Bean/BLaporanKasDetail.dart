class BLaporanKasDetail {
  var order_start_datetime;
  var order_end_datetime;
  var sales_amount;
  var voided_sales_amount;
  var total_installment_income;
  var cashflow_in_amount;
  var cashflow_out_amount;
  var system_income;
  var actual_income;
  var income_differences;
  var total_pending_transactions;
  var total_ongoing_installment_order;

  BLaporanKasDetail.fromJson(Map json)
      : order_start_datetime = json["order_start_datetime"],
        order_end_datetime = json["order_end_datetime"],
        sales_amount = json["sales_amount"],
        voided_sales_amount = json["voided_sales_amount"],
        total_installment_income = json["total_installment_income"],
        cashflow_in_amount = json["cashflow_in_amount"],
        cashflow_out_amount = json["cashflow_out_amount"],
        system_income = json["system_income"],
        actual_income = json["actual_income"],
        income_differences = json["income_differences"],
        total_pending_transactions = json["total_pending_transactions"],
        total_ongoing_installment_order =
            json["total_ongoing_installment_order"];
}
