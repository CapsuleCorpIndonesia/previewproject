import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:pawoon/Views/Base.dart';

import 'Api.dart';
import 'HTTPImb.dart';
import 'Helper.dart';
import 'UserManager.dart';

class Logic {
  var context;

  Logic(this.context);
  static String ACCESS_TOKEN = "";
  static String ASSIGNMENT_TOKEN = "";
  static String VERSION = "2.10.11";

  dynamic headerPawoon() {
    return {
      "version": VERSION,
    };
  }

  dynamic headerToken() {
    return {
      "version": VERSION,
      "Authorization": "Bearer ${Logic.ACCESS_TOKEN}",
      "Accept": "application/json",
    };
  }

  dynamic headerTokenDevice(
      {contentJson = false,
      acceptJson = true,
      typeForm = false,
      length = "-1"}) {
    // Clipboard.setData(ClipboardData(text: "${Logic.ACCESS_TOKEN}"));
    if (typeForm)
      return {
        "device-assignment-id": Logic.ASSIGNMENT_TOKEN,
        "version": VERSION,
        'Content-Type': 'application/x-www-form-urlencoded',
        "Accept": "application/json",
        // "Content-Type": "application/x-www-form-urlencoded",
        // "Cache-Control": "no-cache",
        'Content-Length': "$length",
        "Authorization": "Bearer ${Logic.ACCESS_TOKEN}",
        // "Content-Length": "-1"
      };
    if (contentJson)
      return {
        "device-assignment-id": Logic.ASSIGNMENT_TOKEN,
        "version": VERSION,
        if (acceptJson) "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer ${Logic.ACCESS_TOKEN}",
      };

    return {
      "device-assignment-id": Logic.ASSIGNMENT_TOKEN,
      "version": VERSION,
      if (acceptJson) "Accept": "application/json",
      "Authorization": "Bearer ${Logic.ACCESS_TOKEN}",
    };
  }

  /* -------------------------------------------------------------------------- */
  /*                                    LOGIN                                   */
  /* -------------------------------------------------------------------------- */
  Future login(
      {email, password, ListenerSuccess success, ListenerError error}) {
    return HTTPImb(
      context,
      url: Api.LOGIN,
      header: headerPawoon(),
      printAll: false,
      postParams: {
        "client_id": "3",
        "client_secret": "iBAhimye9KtrTP9tYsGHXW6XyTMczDhGDmaraudy",
        "grant_type": "password",
        "password": password,
        "username": email,
      },
      listenerSuccess: success,
      listenerError: error,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   SIGNUP                                   */
  /* -------------------------------------------------------------------------- */
  Future checkEmail({email, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.CHECK_EMAIL + email,
      header: headerPawoon(),
      listenerSuccess: success,
    ).execute();
  }

  Future getBisnis({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.GET_BISNIS,
      header: headerPawoon(),
      listenerSuccess: success,
    ).execute();
  }

  Future getCity({key, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.CITIES + key,
      header: headerPawoon(),
      listenerSuccess: success,
    ).execute();
  }

  Future signup({data, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.SIGNUP,
      header: headerPawoon(),
      postParams: data,
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   OUTLET                                   */
  /* -------------------------------------------------------------------------- */
  Future outlet({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.OUTLET,
      header: headerToken(),
      listenerSuccess: success,
      printAll: true,
    ).execute();
  }

  Future tax({outlet, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.TAX_SERVICES.replaceFirst("_id_", outlet),
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: false,
    ).execute();
  }

  Future companyDetails({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.COMPANY_DETAILS + "&outlet_id=$outletid",
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: false,
      // printAll: true,
    ).execute();
  }

  Future customAmount({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      closeLoader: false,
      url: Api.CUSTOM_AMOUNT.replaceFirst("_outletid_", outletid),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future billing({ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.BILLING,
      closeLoader: false,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                              DEVICE MANGEMENT                              */
  /* -------------------------------------------------------------------------- */
  Future device({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.DEVICE + "?outlet_id=$outletid",
      header: headerToken(),
      listenerSuccess: success,
    ).execute();
  }

  Future deviceAssignment({deviceid, outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.DEVICE_ASSIGNMENT.replaceFirst("_id_", deviceid),
      header: headerToken(),
      postParams: {"outlet_id": outletid},
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                  OPERATOR                                  */
  /* -------------------------------------------------------------------------- */
  Future operator({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: true,
      closeLoader: false,
      url: Api.OPERATOR.replaceFirst("_id_", outletid),
      header: headerToken(),
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   PRODUCT                                  */
  /* -------------------------------------------------------------------------- */
  Future products({outletid, page, ListenerSuccess success}) {
    // print("page : $page");
    return HTTPImb(
      context,
      url: Api.PRODUCTS.replaceFirst("_id_", outletid) + "&page=$page",
      header: headerTokenDevice(),
      closeLoader: false,
      printAll: false,
      listenerSuccess: success,
    ).execute();
  }

  Future variants({outletid, page, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.VARIANTS.replaceFirst("_id_", outletid) + "&page=$page",
      header: headerTokenDevice(),
      printAll: false,
      closeLoader: false,
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   CUSTOMER                                 */
  /* -------------------------------------------------------------------------- */
  Future customer({page, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.CUSTOMER + "&page=$page",
      closeLoader: false,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future customerLastUpdate({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.CUSTOMER_LAST_UDPATE,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future customerPoint({userid, outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.CUSTOMER_POINT
          .replaceFirst("_userid_", "$userid")
          .replaceFirst("_outletid_", outletid),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future customerAdd({data, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.CUSTOMER_ADD,
      header: headerTokenDevice(),
      postParams: data,
      printAll: false,
      listenerSuccess: success,
    ).execute();
  }

  Future customerUpdate({serverid, data, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.CUSTOMER_ADD + "/$serverid",
      header: headerTokenDevice(),
      postParams: data,
      printAll: false,
      listenerSuccess: success,
    ).execute();
  }

  Future logout({deviceid, assignid, ListenerSuccess success}) {
    // Clipboard.setData(ClipboardData(text: "${headerTokenDevice()}"));
    return HTTPImb(
      context,
      printAll: false,
      url: Api.LOGOUT
          .replaceFirst("_deviceid_", deviceid)
          .replaceFirst("_assignid_", assignid),
      header: headerTokenDevice(contentJson: true),
      // postParams: {"method":"post"},
      listenerSuccess: success,
    ).executeDelete();
  }

  Future forgot({email, ListenerSuccess success, ListenerError err}) {
    // Clipboard.setData(ClipboardData(text: "${headerTokenDevice()}"));
    return HTTPImb(
      context,
      printAll: true,
      url: Api.FORGOT_PASSWORD,
      header: headerTokenDevice(),
      postParams: {"email": "$email"},
      listenerSuccess: success,
      listenerError: err,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                  API SYNC                                  */
  /* -------------------------------------------------------------------------- */
  Future tables({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.TABLES.replaceFirst("_id_", outletid),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future tablesEdit({data, outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.MEJA_POST.replaceFirst("_id_", outletid),
      header: headerTokenDevice(contentJson: true),
      // postParams: data,
      postData: data,
      listenerSuccess: success,
    ).execute();
  }

  Future salesType({companyid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.SALES_TYPE + "?company_id=$companyid",
      header: headerTokenDevice(),
      listenerSuccess: success,
      printAll: false,
    ).execute();
  }

  Future tierOutlet({ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.TIER_OUTLET,
      header: headerTokenDevice(acceptJson: true),
      listenerSuccess: success,
    ).execute();
  }

  Future companyPermission({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.COMPANIES_ME_PERMISSION,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future transactions({data, outletid, ListenerSuccess success}) {
    // var body =
    //     utf8.encode("data" + '=' + Uri.encodeQueryComponent(json.encode(data)));
    // HTTPImb(context).test(data: data, url: );
    return HTTPImb(
      context,
      popupCheckInternet: true,
      closeLoader: false,
      url: Api.UPLOAD_TRANSACTIONS.replaceFirst("_id_", outletid),
      // header: headerTokenDevice(typeForm: true, length: body.length.toString()),
      header: headerTokenDevice(),
      // postData: body,
      postParams: {"data": json.encode(data)},
      listenerSuccess: success,
      printAll: true,
    ).execute();
  }

/* -------------------------------------------------------------------------- */
/*                                    REKAP                                   */
/* -------------------------------------------------------------------------- */
  Future rekapCashflow({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.RECONCILIATION_CASH_FLOWS,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future rekapCashCards({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.RECONCILIATION_CASH_AND_CARDS,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future rekapCustomPayments({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.RECONCILIATION_CUSTOM_PAYMENTS,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future rekapIntegratedPayments({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.RECONCILIATION_INTEGRATED_PAYMENTS,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future rekapGet({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.RECONCILIATIONS_GET + outletid,
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future rekapSync({data, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.SYNC_CASH_FLOWS,
      header: headerTokenDevice(),
      postParams: data,
      listenerSuccess: success,
    ).execute();
  }

  Future rekapUpload({data, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.RECONCILIATIONS_POST,
      header: headerTokenDevice(contentJson: true),
      // postParams: data,
      postData: data,
      printAll: false,
      listenerSuccess: success,
    ).execute();
    // return HTTPImb(
    //   context,
    //   url: Api.RECONCILIATIONS_POST,
    //   header: headerTokenDevice(),
    //   printAll: false,
    // ).apiRequest().then((value) => print(value));
  }

  /* -------------------------------------------------------------------------- */
  /*                                  LAPORAN                                   */
  /* -------------------------------------------------------------------------- */
  Future laporanSummary({start, end, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_SUMMARY
          .replaceFirst("_start_", start)
          .replaceFirst("_end_", end),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future laporanSales({start, end, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_SALES
          .replaceFirst("_start_", start)
          .replaceFirst("_end_", end),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future laporanSalesPayment({start, end, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_SALES_PAYMENT
          .replaceFirst("_start_", start)
          .replaceFirst("_end_", end),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future laporanSalesProduct({start, end, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_SALES_PRODUCT
          .replaceFirst("_start_", start)
          .replaceFirst("_end_", end),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future laporanKas({start, end, limit, page, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_KAS
          .replaceFirst("_start_", start)
          .replaceFirst("_end_", end),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future laporanKasDetail({laporanid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_KAS_DETAIL + laporanid,
      header: headerTokenDevice(),
      printAll: false,
      listenerSuccess: success,
    ).execute();
  }

  Future laporanKasIn({id, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_KAS_KAS_IN.replaceFirst("_id_", id),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future laporanKasOut({id, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_KAS_KAS_OUT.replaceFirst("_id_", id),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future laporanKasActual({id, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAPORAN_KAS_KAS_ACTUAL.replaceFirst("_id_", id),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   MEJA                                     */
  /* -------------------------------------------------------------------------- */
  Future meja({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.MEJA.replaceFirst("_id_", outletid),
      header: headerTokenDevice(),
      printAll: false,
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   PAYMENT                                  */
  /* -------------------------------------------------------------------------- */
  Future paymentIntegration({data, outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.PAYMENT_INTEGRATION.replaceFirst("_outletid_", outletid),
      postParams: data,
      header: headerTokenDevice(),
      printAll: true,
      listenerSuccess: success,
    ).execute();
  }

  Future paymentIntegrationCheck(
      {transactionid, outletid, data, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.PAYMENT_INTEGRATION_CHECK
          .replaceFirst("_outletid_", outletid)
          .replaceFirst("_transactionid_", transactionid),
      header: headerTokenDevice(),
      printAll: false,
      postParams: data,
      listenerSuccess: success,
    ).execute();
  }

  /* -------------------------------------------------------------------------- */
  /*                                    GRAB                                    */
  /* -------------------------------------------------------------------------- */
  Future grabGet(
      {outletid, page, perpage, timestamp, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: true,
      url: Api.GRAB_GET
          .replaceFirst("_outletid_", outletid)
          .replaceFirst("_page_", "$page")
          .replaceFirst("_perpage_", "$perpage")
          .replaceFirst("_timestamp_", "$timestamp"),
      header: headerTokenDevice(),
      listenerError: (_) {},
      listenerSuccess: success,
    ).execute();
  }

  Future grabIsActive({outletid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      popupCheckInternet: false,
      url: Api.GRAB_ACTIVATE.replaceFirst("_outletid_", outletid),
      header: headerTokenDevice(),
      listenerSuccess: success,
    ).execute();
  }

  Future grabActivate(
      {cashierid, outletid, activate, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.GRAB_ACTIVATE.replaceFirst("_outletid_", outletid),
      postParams: {
        "active": activate ? "true" : "false",
        "cashier_id": cashierid,
      },
      methodPut: true,
      header: headerTokenDevice(contentJson: false),
      listenerSuccess: success,
    ).execute();
  }

  Future grabConfirmServer(
      {orderid, outletid, state, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: true,
      url: Api.GRAB_CONFIRM
          .replaceFirst("_outletid_", outletid)
          .replaceFirst("_orderid_", outletid),
      postParams: {"state": "$state"},
      methodPut: true,
      listenerError: (_) {},
      header: headerTokenDevice(contentJson: false),
      listenerSuccess: success,
    ).execute();
  }

  Future grabRejectOrder(
      {orderid, outletid, integrationid, type, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: true,
      url: Api.GRAB_ACTION
          .replaceFirst("_outletid_", outletid)
          .replaceFirst("_orderid_", orderid),
      methodPut: true,
      postParams: {
        "server_order_id": orderid,
        "order_integration_id": integrationid,
        "type": type,
        "accepted": "false",
      },
      header: headerTokenDevice(contentJson: false),
      listenerSuccess: success,
    ).execute();
  }

  Future grabAcceptOrder(
      {orderid, outletid, integrationid, type, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.GRAB_ACTION
          .replaceFirst("_outletid_", outletid)
          .replaceFirst("_orderid_", orderid),
      methodPut: true,
      postParams: {
        "server_order_id": orderid,
        "order_integration_id": integrationid,
        "type": type,
        "accepted": "true",
      },
      header: headerTokenDevice(contentJson: false),
      listenerSuccess: success,
    ).execute();
  }

  Future grabOff({cashierid, outletid, activate, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.GRAB_ACTIVATE.replaceFirst("_outletid_", outletid),
      postParams: {
        "active": activate ? "true" : "false",
        "cashier_id": cashierid,
      },
      // methodPut: true,
      header: headerTokenDevice(contentJson: false),
      listenerSuccess: success,
    ).executeDelete();
  }

  Future grabGetStatus({outletid, orderid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.GRAB_GET_STATUS
          .replaceFirst("_outletid_", outletid)
          .replaceFirst("_orderid_", orderid),
      header: headerTokenDevice(acceptJson: true, contentJson: true),
      listenerSuccess: success,
    ).execute();
  }

  Future subscribeToken({deviceid, assignid, token, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      popupCheckInternet: false,
      url: Api.SUBSCRIBE_PUSH
          .replaceFirst("_deviceid_", deviceid)
          .replaceFirst("_assignid_", assignid),
      postParams: {"fcm_token": token},
      header: headerTokenDevice(),
      listenerSuccess: success,
      listenerError: (err) async {
        await UserManager.saveBool(UserManager.IS_LOGGED_IN, false);

        Helper.closePage(context);
        Helper.openPageNoNav(context, Base());
      },
      methodPut: true,
    ).execute();
  }

  Future grabGetDetails({outletid, orderid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      printAll: false,
      url: Api.GRAB_GET_DETAILS
          .replaceFirst("_outletid_", outletid)
          .replaceFirst("_orderid_", orderid),
      header: headerTokenDevice(),
      listenerSuccess: success,
      listenerError: (_) {},
    ).execute();
  }

/* -------------------------------------------------------------------------- */
/*                                LAST UPDATED                                */
/* -------------------------------------------------------------------------- */
  Future lastUpdatedProduct({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAST_UPDATE_PRODUCT,
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: false,
    ).execute();
  }

  Future lastUpdatedVariants({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAST_UPDATE_VARIANTS,
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: false,
    ).execute();
  }

  Future lastUpdatedCustomers({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAST_UPDATE_CUSTOMERS,
      header: headerTokenDevice(),
      closeLoader: false,
      listenerSuccess: success,
    ).execute();
  }

  Future lastUpdatedTax({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAST_UPDATE_TAXES,
      header: headerTokenDevice(),
      closeLoader: false,
      listenerSuccess: success,
    ).execute();
  }

  Future lastUpdatedOperator({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.LAST_UPDATE_OPERATORS,
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: false,
    ).execute();
  }

/* -------------------------------------------------------------------------- */
/*                                  BILLINGS                                  */
/* -------------------------------------------------------------------------- */
  Future billingPrice(
      {billingType = "",
      cycleType = "",
      totalDevice = "",
      code = "",
      ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.BILLING_PRICE
          .replaceFirst("_billingtype_", billingType)
          .replaceFirst("_cycletype_", cycleType)
          .replaceFirst("_maindevice_", totalDevice)
          .replaceFirst("_code_", code),
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: true,
    ).execute();
  }

  Future billingPaymentMethod({ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.BILLING_PAYMENT_METHOD,
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: true,
    ).execute();
  }

  Future billingCheckout(
      {billingType,
      cycleType,
      paymentMethod,
      totalDevice,
      ListenerSuccess success}) {
    return HTTPImb(
      context,
      url: Api.BILLING_CHECKOUT,
      header: headerTokenDevice(),
      postParams: {
        "billing_type_id": "1",
        "cycle_type": "1",
        "payment_method": "bca-va",
        "total_main_device": "1",
      },
      listenerSuccess: success,
      closeLoader: true,
    ).execute();
  }

  Future billingCheck({invoiceid, ListenerSuccess success}) {
    return HTTPImb(
      context,
      url:
          Api.BILLING_CHECK_STATUS_ORDER.replaceFirst("_invoiceid_", invoiceid),
      header: headerTokenDevice(),
      listenerSuccess: success,
      closeLoader: true,
    ).execute();
  }
}
