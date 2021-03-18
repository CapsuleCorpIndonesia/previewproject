class BLaporanSummary {
  num sales_amount;
  num discount_amount;
  num voided_sales_amount;
  num net_sales_amount;
  num service_amount;
  num tax_amount;
  num rounding_amount;
  num point_amount;
  num total_transaction_amount;
  num installment_remaining_amount;
  num installment_paid_amount;
  num total_income_amount;

  BLaporanSummary.fromJson(Map json)
      : sales_amount = json["sales_amount"],
        discount_amount = json["discount_amount"],
        voided_sales_amount = json["voided_sales_amount"],
        net_sales_amount = json["net_sales_amount"],
        service_amount = json["service_amount"],
        tax_amount = json["tax_amount"],
        rounding_amount = json["rounding_amount"],
        point_amount = json["point_amount"],
        total_transaction_amount = json["total_transaction_amount"],
        installment_remaining_amount = json["installment_remaining_amount"],
        installment_paid_amount = json["installment_paid_amount"],
        total_income_amount = json["total_income_amount"];
}
