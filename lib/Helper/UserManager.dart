import 'package:shared_preferences/shared_preferences.dart';

import 'DBPawoon.dart';

class UserManager {
  static const IS_LOGGED_IN = "loggedin26";
  static const ACCESS_TOKEN = "accesstoken";
  static const ASSIGNMENT_TOKEN = "assignmenttoken";
  static const OUTLET_ID = "outletid";
  static const OUTLET_OBJ = "outletobj";
  static const DEVICE_OBJ = "deviceobj";
  static const OPERATOR_OBJ = "operatorobj";
  static const BILLING_OBJ = "billingobj";
  static const LOGIN_EMAIL = "loginemail";
  static const LOGIN_EMAIL_SIMPAN = "loginemailsimpan";
  static const CUSTOM_AMOUNT_OBJ = "customamountobj";
  static const SETTING_NOMOR_STRUK = "settingnomorstruk";
  static const SETTING_SALDO_REKAP = "settingsaldorekap";
  static const SETTING_STOK = "settingstok";
  static const SETTING_NOMOR_PERTAMA = "settingnomorpertama";
  static const SETTING_ONLINE_ORDER = "settingorderonline";
  static const SETTING_ONLINE_STRUK = "settingstrukonline";
  static const SETTING_TAMPILAN = "settingtampilan";
  static const DISPLAY_TUTORIAL = "displaytutorial";
  static const DISPLAY_TUTORIAL_BAYAR = "displaytutorial_bayar";
  static const DISPLAY_TUTORIAL_BAYAR_1 = "displaytutorial_bayar_1";
  static const LAST_UPDATE_PRODUCT = "lastupdateproduct";
  static const LAST_UPDATE_VARIANT = "lastupdatevariant";
  static const LAST_UPDATE_TAX = "lastupdatetax";
  static const LAST_UPDATE_CUSTOMER = "lastupdatecustomer";
  static const LAST_UPDATE_OPERATOR = "lastupdateoperator";
  static const SETTING_IP = "lastip";
  static const INVOICE = "invoice";

  static Future saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(key, value);
  }

  static Future saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool(key, value);
  }

  static Future saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt(key, value);
  }

  static Future<bool> getBool(key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  // ------- LOGIN --------
  static Future<String> getString(key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(ACCESS_TOKEN);
  }

  static Future clearData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  // Logout
  static Future clearDataLogin() async {
    List<Future> arrFut = List();
    arrFut.add(UserManager.saveBool(UserManager.IS_LOGGED_IN, false));

    await Future.wait(arrFut);
  }

  // Clear device & data
  static Future clearDataNewDevice() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await DBPawoon().clearDb();

    UserManager.saveBool(UserManager.IS_LOGGED_IN, true);
  }
}
