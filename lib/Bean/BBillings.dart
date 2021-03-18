class BBillings {
  var free_max_daily_transactions;
  var paid_block_date;
  var trial_end_date;
  var paid_notification_date;
  var lockdown_date;
  var last_transaction_device_timestamp;
  var free_today_done_transactions;
  var tier;
  var free_max_monthly_transactions;
  var free_monthly_done_transactions;
  var transaction_history_period;
  var upgrade_link;
  var subscription_type;
  var paid_churn_date;
  
  BBillings.fromJson(Map json)
      : free_max_daily_transactions = json["free_max_daily_transactions"],
        paid_block_date = json["paid_block_date"],
        trial_end_date = json["trial_end_date"],
        paid_notification_date = json["paid_notification_date"],
        lockdown_date = json["lockdown_date"],
        last_transaction_device_timestamp =
            json["last_transaction_device_timestamp"],
        free_today_done_transactions = json["free_today_done_transactions"],
        tier = json["tier"],
        free_max_monthly_transactions = json["free_max_monthly_transactions"],
        free_monthly_done_transactions = json["free_monthly_done_transactions"],
        transaction_history_period = json["transaction_history_period"],
        upgrade_link = json["upgrade_link"],
        subscription_type = json["subscription_type"],
        paid_churn_date = json["paid_churn_date"];
}
