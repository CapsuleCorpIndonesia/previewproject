class BLaporanSales {
  num sales_amount;
  num sales_average;
  num transaction_count;
  num tax_amount;
  num service_amount;
  num discount_amount;
  num product_discount_amount;
  
  BLaporanSales.fromJson(Map json)
      : sales_amount = json["sales_amount"],
        sales_average = json["sales_average"],
        transaction_count = json["transaction_count"],
        tax_amount = json["tax_amount"],
        service_amount = json["service_amount"],
        discount_amount = json["discount_amount"],
        product_discount_amount = json["product_discount_amount"];
}
