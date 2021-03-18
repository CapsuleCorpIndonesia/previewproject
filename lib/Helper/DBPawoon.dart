import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pawoon/Bean/BLogPesanan.dart';
import 'package:pawoon/Bean/BModifier.dart';
import 'package:pawoon/Bean/BModifierData.dart';
import 'package:pawoon/Bean/BModifierGroup.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Bean/BVariant.dart';
import 'package:pawoon/Bean/BVariantData.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'UserManager.dart';

class DBPawoon {
  static DBPawoon _DBPawoon;
  static Database _database;
  String DB_NAME = "pawoondb115";
  // Ini buat testing purpose aja
  static bool updateAllTime = true;
  static bool printAll = true;
  // Table names
  // static String DB_CATEGORY = "category";
  static String DB_CUSTOM_PRODUCT_POSITION = "custom_product_position";
  // static String DB_MODIFIER_GROUPS = "modifier_groups";
  static String DB_PRODUCT_FAVORITE = "product_favorite";
  // static String DB_PRODUCT_MODIFIER_GROUPS = "product_modifier_groups";
  // static String DB_PRODUCT_MODIFIERS = "product_modifiers";
  // static String DB_PRODUCT_POSITION = "product_position";
  // static String DB_PRODUCT_VARIANT_DETAILS = "product_variant_details";
  static String DB_PRODUCT_VARIANTS = "product_variants";
  static String DB_PRODUCTS = "products";
  // static String DB_PROMO = "promo";
  // static String DB_VARIANT_DETAILS = "variant_details";
  // static String DB_VARIANTS = "variants";
  // static String DB_BILLINGS = "billings";
  // static String DB_CASH_IN_OUT = "cash_in_out";
  // static String DB_COMPANIES = "companies";
  // static String DB_CUSTOM_PAYMENT_METHODS = "custom_payment_methods";
  static String DB_CUSTOMERS = "customers";
  // static String DB_INTEGRATIONS = "integrations";
  // static String DB_ITEMS = "items";
  // static String DB_LOG = "log";
  // static String DB_MODIFIERS = "modifiers";
  static String DB_ORDERS = "orders";
  static String DB_TRANSACTION = "transactions";
  // static String DB_PAYMENT_BNI_YAP = "payment_bni_yap";
  // static String DB_POINT = "point";
  // static String DB_PRINTERS = "printers";
  static String DB_RECONCILE = "reconcile";
  // static String DB_RECONCILIATION_INSTALLMENTS = "reconciliation_installments";
  // static String DB_RECONCILIATION_INTEGRATED_PAYMENTS =
  //     "reconciliation_integrated_payments";
  // static String DB_RECONCILIATION_PAYMENTS = "reconciliation_payments";
  // static String DB_RECONCILIATION_PONTA = "reconciliation_ponta";
  static String DB_SALES_TYPE = "sales_type";
  static String DB_TABLES = "tables";
  static String DB_TAX_SERVICES = "tax_services";
  static String DB_LOG_PESANAN = "log_pesanan";
  static String DB_RECONCILIATION_CASHFLOW = "reconciliation_cashflow";
  static String DB_OPERATOR = "operator";
  // static String DB_TRANSACTION_INSTALLMENTS = "transaction_installments";
  // static String DB_TRANSACTION_INTEGRATED_PAYMENTS =
  //     "transaction_integrated_payments";
  // static String DB_TRANSACTION_PAYMENTS = "transaction_payments";
  // static String DB_TRANSACTION_PONTA = "transaction_ponta";
  // static String DB_TRANSACTION_TAX_SERVICES = "transaction_tax_services";
  // static String DB_TRANSACTION_POINT = "transaction_point";
  static String DB_ORDER_ONLINE = "online_order";
  static String DB_PRINTERS = "printers";

  DBPawoon._createObject();

  factory DBPawoon() {
    if (_DBPawoon == null || updateAllTime) {
      _DBPawoon = DBPawoon._createObject();
    }
    return _DBPawoon;
  }
  Future<Database> initDb() async {
    //untuk menentukan nama database dan lokasi yg dibuat
    // Directory directory = await getApplicationDocumentsDirectory();
    // String path = directory.path + '$DB_NAME.db';
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, '$DB_NAME.db');

    //open/create database at a given path
    var cardDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);

    var todoDatabase = openDatabase(path, version: 1, onCreate: _createDb);

    return todoDatabase;
  }

  //buat tabel baru dengan nama order
  void _createDb(Database db, int version) async {
    List<Future> arrFut = List();
    List<String> queryCreate = [
      // CREATE_CATEGORY,
      CREATE_LOG_PESANAN,
      CREATE_CUSTOM_PRODUCT_POSITION,
      // CREATE_MODIFIER_GROUPS,
      CREATE_PRODUCT_FAVORITE,
      // CREATE_PRODUCT_MODIFIER_GROUPS,
      // CREATE_PRODUCT_MODIFIERS,
      // CREATE_PRODUCT_POSITION,
      // CREATE_PRODUCT_VARIANT_DETAILS,
      CREATE_PRODUCT_VARIANTS,
      CREATE_PRODUCTS,
      CREATE_TRANSACTION,
      // CREATE_PROMO,
      // CREATE_VARIANT_DETAILS,
      // CREATE_VARIANTS,
      // CREATE_BILLINGS,
      // CREATE_CASH_IN_OUT,
      // CREATE_COMPANIES,
      // CREATE_CUSTOM_PAYMENT_METHODS,
      CREATE_CUSTOMERS,
      // CREATE_INTEGRATIONS,
      // CREATE_ITEMS,
      // CREATE_LOG,
      // CREATE_MODIFIERS,
      CREATE_ORDERS,
      CREATE_RECONCILIATION_CASHFLOW,
      // CREATE_PAYMENT_BNI_YAP,
      // CREATE_POINT,
      // CREATE_PRINTERS,
      CREATE_RECONCILE,
      // CREATE_RECONCILIATION_INSTALLMENTS,
      // CREATE_RECONCILIATION_INTEGRATED_PAYMENTS,
      // CREATE_RECONCILIATION_PAYMENTS,
      // CREATE_RECONCILIATION_PONTA,
      CREATE_SALES_TYPE,
      CREATE_TABLES,
      CREATE_TAX_SERVICES,
      // CREATE_TRANSACTION_INSTALLMENTS,
      // CREATE_TRANSACTION_INTEGRATED_PAYMENTS,
      // CREATE_TRANSACTION_PAYMENTS,
      // CREATE_TRANSACTION_PONTA,
      // CREATE_TRANSACTION_TAX_SERVICES,
      // CREATE_TRANSACTION_POINT
      CREATE_ONLINE_ORDER,
      CREATE_PRINTERS,
      CREATE_OPERATOR,
    ];
    for (String query in queryCreate) {
      arrFut.add(db.execute(query));
    }
    await Future.wait(arrFut);
  }

  Future<Database> get database async {
    if (_database == null || updateAllTime) {
      _database = await initDb();
    }
    return _database;
  }

/* -------------------------------------------------------------------------- */
/*                                SQL COMMANDS                                */
/* -------------------------------------------------------------------------- */
  Future<int> insertOrUpdate(
      {String tablename, Map<String, dynamic> data, id = "id"}) async {
    if (tablename == null || tablename == "" || data == null) return 0;
    var result = await select(
        tablename: tablename,
        col: [id],
        whereKey: id,
        whereArgs: ["${data[id]}"]);
    int count = result.length;
    if (printAll) print("$id=${data[id]}");
    if (printAll) print("insertupdate $tablename : $count");
    if (count == 0) {
      return insert(tablename: tablename, data: data, id: id);
    } else {
      return update(tablename: tablename, data: data, id: id);
    }
  }

  Future<int> insert(
      {String tablename, Map<String, dynamic> data, id = "id"}) async {
    if (tablename == null || tablename == "" || data == null) return 0;
    Database db = await this.database;
    int count = await db.insert('$tablename', data);
    if (printAll) print("insert $tablename : $count");
    return count;
  }

  Future<int> update(
      {String tablename, Map<String, dynamic> data, id = "id"}) async {
    if (tablename == null ||
        tablename == "" ||
        data == null ||
        data["$id"] == null ||
        data["$id"] == "") return 0;

    Database db = await this.database;
    String isiId = data["$id"].toString();
    int count =
        await db.update('$tablename', data, where: '$id=?', whereArgs: [isiId]);
    if (printAll) print("update $tablename : $count");
    if (printAll) print("${data}");
    return count;
  }

  Future<int> delete({String tablename, Map data, id = "id"}) async {
    if (tablename == null ||
        tablename == "" ||
        data == null ||
        data["$id"] == null ||
        data["$id"] == "") return 0;
    Database db = await this.database;
    String isiid = data["$id"].toString();
    int count =
        await db.delete('$tablename', where: '$id=?', whereArgs: [isiid]);
    if (printAll) print("delete : $count");
    return count;
  }

  Future<int> deleteAll({String tablename}) async {
    if (tablename == null || tablename == "") return 0;

    Database db = await this.database;
    int count = await db.delete('$tablename');
    if (printAll) print("delete : $count");
    return count;
  }

  Future<Database> getDB() {
    return this.database;
  }

  Future<List<Map<String, dynamic>>> select(
      {String tablename,
      List<String> col,
      String orderby,
      whereKey,
      List<String> whereArgs}) async {
    if (tablename == null || tablename == "") return List();
    if (col == null) col = ["*"];

    Database db = await this.database;
    var mapList = await db.query('$tablename',
        orderBy: orderby,
        columns: col,
        where: whereKey != null ? "$whereKey = ?" : whereKey,
        whereArgs: whereArgs != null ? whereArgs : null);
    return mapList;
  }

  Future<int> getCount({String tablename}) async {
    if (tablename == null || tablename == "") return 0;

    var orderMapList = await select(tablename: tablename, col: ["*"]);
    int count = orderMapList.length;
    if (printAll) print(count);

    return count;
  }

  Future clearDb() async {
    List<String> listName = [
      DB_CUSTOM_PRODUCT_POSITION,
      DB_PRODUCT_FAVORITE,
      DB_PRODUCT_VARIANTS,
      DB_PRODUCTS,
      DB_CUSTOMERS,
      DB_ORDERS,
      DB_TRANSACTION,
      DB_RECONCILE,
      DB_SALES_TYPE,
      DB_TABLES,
      DB_TAX_SERVICES,
      DB_LOG_PESANAN,
      DB_RECONCILIATION_CASHFLOW,
      DB_ORDER_ONLINE,
      DB_PRINTERS,
      DB_OPERATOR
    ];
    List<Future> arrFut = List();
    for (String name in listName) {
      arrFut.add(deleteAll(tablename: name));
    }

    return Future.wait(arrFut);
  }

/* -------------------------------------------------------------------------- */
/*                               PRODUCT                                      */
/* -------------------------------------------------------------------------- */
  Future insertProduct(Map<String, List<BProduct>> map) {
    List<Future> arrFut = List();

    map.forEach((key, value) {
      // Cukup simpan dari yang all categories aja, sudah mencakup semua.
      if (key == "all") {
        for (BProduct prod in value) {
          arrFut.add(insert(tablename: DB_PRODUCTS, data: prod.toDb()));
        }
      }
    });

    return Future.wait(arrFut);
  }

  Future updateProduct(Map<String, List<BProduct>> map) {
    List<Future> arrFut = List();
    map.forEach((key, value) {
      // Cukup simpan dari yang all categories aja, sudah mencakup semua.
      if (key == "all") {
        for (BProduct prod in value) {
          arrFut.add(update(tablename: DB_PRODUCTS, data: prod.toDb()));
        }
      }
    });

    return Future.wait(arrFut);
  }

/* -------------------------------------------------------------------------- */
/*                           LOG PESANAN (LOCAL_ID)                           */
/* -------------------------------------------------------------------------- */
  Future<int> getLocalID() async {
    String orderPertama =
        await UserManager.getString(UserManager.SETTING_NOMOR_PERTAMA);
    if (orderPertama == "" || orderPertama == null) orderPertama = "1";
    int numOrder = int.parse(orderPertama);

    List arr =
        await select(tablename: DB_LOG_PESANAN, orderby: "local_id desc");
    if (arr != null && arr.isNotEmpty) {
      num val = arr[0]["local_id"] + 1;
      if (val < numOrder) val = val + numOrder;
      return val;
    }

    return numOrder;
  }

  Future incrementLocalId({id}) {
    return insertOrUpdate(
        tablename: DB_LOG_PESANAN,
        data: {
          "local_id": id,
          "timestamp": DateTime.now().millisecondsSinceEpoch
        },
        id: "local_id");
  }

/* -------------------------------------------------------------------------- */
/*                                CREATE QUERY                                */
/* -------------------------------------------------------------------------- */
  // String CREATE_CATEGORY =
  //     "CREATE TABLE category (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT, name TEXT )";
  String CREATE_CUSTOM_PRODUCT_POSITION =
      "CREATE TABLE custom_product_position (category_custom_product TEXT, product_order TEXT, sortby VARCHAR, tampilan VARCHAR)";
  // String CREATE_MODIFIER_GROUPS =
  //     "CREATE TABLE modifier_groups (uuid TEXT, name TEXT, is_one_option BOOLEAN)";
  String CREATE_PRODUCT_FAVORITE =
      "CREATE TABLE product_favorite (favorite_id INTEGER PRIMARY KEY AUTOINCREMENT, favorite_product_id VARCHAR NOT NULL)";
  // String CREATE_PRODUCT_MODIFIER_GROUPS =
  //     "CREATE TABLE product_modifier_groups (id INTEGER PRIMARY KEY AUTOINCREMENT, product_uuid INTEGER , modifier_group_uuid VARCHAR)";
  // String CREATE_PRODUCT_MODIFIERS =
  //     "CREATE TABLE product_modifiers (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid VARCHAR,server_id INTEGER, product_id INTEGER, name VARCHAR, display_name VARCHAR, price BIGINT NOT NULL,mod_group_uuid TEXT)";
  // String CREATE_PRODUCT_POSITION =
  //     "CREATE TABLE product_position (product_id INTEGER PRIMARY KEY AUTOINCREMENT, category_product TEXT, order_by TEXT NOT NULL, asc_dsc TEXT, is_custom INTEGER NOT NULL DEFAULT 0)";
  // String CREATE_PRODUCT_VARIANT_DETAILS =
  //     "CREATE TABLE product_variant_details (id INTEGER PRIMARY KEY AUTOINCREMENT, variant_detail_uuid TEXT , product_id TEXT)";
  String CREATE_PRODUCT_VARIANTS =
      "CREATE TABLE product_variants (id VARCHAR PRIMARY KEY, name VARCHAR, price DOUBLE, tax DOUBLE, type VARCHAR, is_all_location_stock INTEGER, is_all_location_price INTEGER, is_sellable INTEGER, is_stock_tracked INTEGER, has_alertstock INTEGER, alert_stock_limit VARCHAR, has_modifier INTEGER, has_variant INTEGER, use_outlet_tax INTEGER, parent_id VARCHAR, amount DOUBLE, updated_at DOUBLE, stock DOUBLE, matrixdata LONGTEXT, barcode VARCHAR)";
  String CREATE_PRODUCTS =
      "CREATE TABLE products (id VARCHAR PRIMARY KEY, name VARCHAR NOT NULL, data_json LONGTEXT)";
  // String CREATE_PROMO =
  //     "CREATE TABLE promo (id VARCHAR PRIMARY KEY , type TEXT NOT NULL, start_date NUMERIC NOT NULL, end_date NUMERIC NOT NULL, start_time TEXT NOT NULL, end_time TEXT NOT NULL, title TEXT NOT NULL, product_id VARCHAR, discount DOUBLE, discount_type TEXT, min_purchase INTEGER, purchase_type TEXT, get_free INTEGER, free_product_id TEXT, is_multiple NUMERIC, day_list TEXT, uuid TEXT,min_qty INT, get_qty INT, buy_at VARCHAR, active INTEGER, category_uuid TEXT)";
  // String CREATE_VARIANT_DETAILS =
  //     "CREATE TABLE variant_details (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT , variant_uuid TEXT, name TEXT)";
  // String CREATE_VARIANTS = "CREATE TABLE variants (uuid TEXT, name TEXT)";
  // String CREATE_BILLINGS =
  //     "CREATE TABLE billings (subscription_type TEXT NOT NULL, trial_end_date TEXT, free_daily_orders INTEGER, free_current_orders INTEGER, paid_login_block_date TEXT, paid_notification_date TEXT, paid_churn_date TEXT, max_monthly_transactions INTEGER, monthly_done_transactions INTEGER, tier TEXT, transaction_history_period INTEGER, upgrade_link TEXT, last_transaction_device_timestamp TEXT)";
  // String CREATE_CASH_IN_OUT =
  //     "CREATE TABLE cash_in_out (id INTEGER PRIMARY KEY AUTOINCREMENT, operator VARCHAR NOT NULL, timestamp DATETIME NOT NULL, type VARCHAR(3) NOT NULL, amount BIGINT NOT NULL, notes VARCHAR, reconcile_id INTEGER, uploaded BOOLEAN, server_id TEXT)";
  // String CREATE_COMPANIES =
  //     "CREATE TABLE companies (name TEXT, address TEXT, theme_color TEXT, logo_image TEXT, receipt_image TEXT, company_id TEXT, note TEXT, json_socmed TEXT, integrations TEXT, receipt_powered_by TEXT, summery_json TEXT)";
  // String CREATE_CUSTOM_PAYMENT_METHODS =
  //     "CREATE TABLE custom_payment_methods (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT, name TEXT )";
  String CREATE_CUSTOMERS =
      "CREATE TABLE customers ( id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, member_id VARCHAR, gender VARCHAR, birth_date VARCHAR, email VARCHAR, phone VARCHAR, address VARCHAR, postal_code VARCHAR, note VARCHAR, order_amount INTEGER, order_count INTEGER, first_order VARCHAR, loyalty_user_id VARCHAR, point INTEGER, cityName VARCHAR, genderType VARCHAR, isActive INTEGER, registeredTimestamp VARCHAR, serverId VARCHAR, userId VARCHAR)";
  // String CREATE_INTEGRATIONS =
  //     "CREATE TABLE integrations (id INTEGER PRIMARY KEY AUTOINCREMENT, method TEXT, type TEXT, configuration TEXT )";
  // String CREATE_ITEMS =
  //     "CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL, type TEXT NOT NULL, title VARCHAR NOT NULL, price BIGINT NOT NULL, tax SMALLINT NOT NULL, qty REAL NOT NULL, product_id VARCHAR NOT NULL, promo_id VARCHAR, discount DOUBLE, discount_unit VARCHAR, revision INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL, note TEXT,json_promo TEXT, product_uuid TEXT, use_outlet_tax BOOLEAN, category_uuid TEXT, prev_qty REAL, data_status SMALLINT(2) DEFAULT 0, data_json TEXT )";
  // String CREATE_LOG =
  //     "CREATE TABLE log (body TEXT, exp BIGINT, is_sent INTEGER, error TEXT, url TEXT, name TEXT )";
  // String CREATE_MODIFIERS =
  //     "CREATE TABLE modifiers ( id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER, title VARCHAR, price BIGINT, tax SMALLINT, product_id INTEGER , discount DOUBLE, discount_unit VARCHAR, server_id INTEGER , prev_qty INTEGER , is_deleted BOOLEAN , saved_in_order BOOLEAN , product_modifier_uuid VARCHAR, qty REAL)";
  String CREATE_ORDERS =
      "CREATE TABLE $DB_ORDERS (id INTEGER PRIMARY KEY, subtotal DOUBLE, tax DOUBLE, taxStr TEXT, taxAmount DOUBLE, service DOUBLE, serviceStr TEXT, serviceAmount DOUBLE, grandTotal DOUBLE, pembulatan DOUBLE, pembulatanStr VARCHAR, mappingOrder LONGTEXT, customAmount LONGTEXT, timestamp INT, notes TEXT, salestype LONGTEXT, operator LONGTEXT, nama TEXT, outlet LONGTEXT, device LONGTEXT, pelanggan LONGTEXT, tax_services LONGTEXT, status_done INTEGER, status_update BOOLEAN, receipt_code VARCHAR, payment LONGTEXT, revision INTEGER, enableService INTEGER, enableTax INTEGER, void_reason VARCHAR, void_receipt_code VARCHAR, status VARCHAR, rekapid VARCHAR)";
  String CREATE_TRANSACTION =
      "CREATE TABLE $DB_TRANSACTION (id INTEGER PRIMARY KEY, subtotal DOUBLE, tax DOUBLE, taxStr TEXT, taxAmount DOUBLE, service DOUBLE, serviceStr TEXT, serviceAmount DOUBLE, grandTotal DOUBLE, pembulatan DOUBLE, pembulatanStr VARCHAR, mappingOrder LONGTEXT, customAmount LONGTEXT, timestamp INT, notes TEXT, salestype LONGTEXT, operator LONGTEXT, nama TEXT, outlet LONGTEXT, device LONGTEXT, pelanggan LONGTEXT, tax_services LONGTEXT, status_done INTEGER, status_update BOOLEAN, receipt_code VARCHAR, payment LONGTEXT, server_id VARCHAR, revision INTEGER, enableService INTEGER, enableTax INTEGER, void_reason VARCHAR, void_receipt_code VARCHAR, status VARCHAR, rekapid VARCHAR)";
  String CREATE_RECONCILIATION_CASHFLOW =
      "CREATE TABLE reconciliation_cashflow (id INTEGER PRIMARY KEY AUTOINCREMENT, amount DOUBLE,  cashier_id VARCHAR,  device_id VARCHAR,  outlet_id VARCHAR,  serverId VARCHAR,  device_timestamp INTEGER,  title VARCHAR,  type VARCHAR,  uploaded BOOLEAN,  note TEXT, recon_id VARCHAR, operator LONGTEXT)";
  // String CREATE_PAYMENT_BNI_YAP =
  //     "CREATE TABLE payment_bni_yap (id INTEGER PRIMARY KEY AUTOINCREMENT, mid TEXT, tid TEXT, amount BIGINT, status TEXT, app_accounts_payment_id TEXT, mvisa_transaction_id TEXT, account_id TEXT, merchant_pan TEXT, merchant_pan_raw TEXT, merchant_name TEXT, payment_amount BIGINT, payment_amount_fee BIGINT, transaction_date DATETIME, consumer_name TEXT, consumer_pan TEXT, consumer_pan_raw TEXT, created_date DATETIME NOT NULL, updated_date DATETIME, terminal_id TEXT)";
  // String CREATE_POINT =
  //     "CREATE TABLE point (id INTEGER PRIMARY KEY AUTOINCREMENT, customer_id TEXT, order_id INTEGER, trasanction_id TEXT NOT NULL, issued_point INTEGER, redeemed_point INTEGER, total_point INTEGER )";
  // String CREATE_PRINTERS =
  //     "CREATE TABLE printers (id INTEGER PRIMARY KEY AUTOINCREMENT, printer_name TEXT, manufacturer TEXT NOT NULL, model TEXT, port TEXT, address TEXT, printer_type INTEGER, is_receipt INTEGER NOT NULL DEFAULT 1, copy_of_receipt INTEGER NOT NULL DEFAULT 1, is_kitchen INTEGER NOT NULL DEFAULT 1, copy_of_kitchen INTEGER NOT NULL DEFAULT 1, title_and_not_print_category TEXT, is_label INTEGER NOT NULL DEFAULT 1, copy_of__label INTEGER NOT NULL DEFAULT 1, not_print_category TEXT,paper_size INTEGER NOT NULL DEFAULT 0 )";
  String CREATE_RECONCILE =
      "CREATE TABLE reconcile (cashier_id VARCHAR, device_id VARCHAR, device_timestamp VARCHAR, difference_amount INTEGER, id VARCHAR, total_installment_income INTEGER, sales_amount INTEGER, order_begin VARCHAR, order_end VARCHAR, outlet_id VARCHAR, recon_code VARCHAR, system_amount INTEGER, totalActual INTEGER, total_cash INTEGER, total_non_cash INTEGER, total_ongoing_installment_order INTEGER, totalOrderAmount INTEGER, total_pending_transaction INTEGER, cash_in INTEGER, cash_out INTEGER, installment_period INTEGER, installment_sales INTEGER, void_transactions INTEGER, actual_income INTEGER, cashflow_data LONGTEXT, integrated_payments LONGTEXT, operator LONGTEXT)";
  // String CREATE_RECONCILIATION_INSTALLMENTS =
  //     "CREATE TABLE reconciliation_installments (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT, recon_server_id VARCHAR, recon_id INTEGER )";
  // String CREATE_RECONCILIATION_INTEGRATED_PAYMENTS =
  //     "CREATE TABLE reconciliation_integrated_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, reconciliation_id BIGINT, method TEXT, title TEXT, amount TEXT )";
  // String CREATE_RECONCILIATION_PAYMENTS =
  //     "CREATE TABLE reconciliation_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, reconciliation_id BIGINT, payment_method_uuid TEXT, method TEXT, title TEXT, amount TEXT )";
  // String CREATE_RECONCILIATION_PONTA =
  //     "CREATE TABLE reconciliation_ponta (id INTEGER PRIMARY KEY AUTOINCREMENT, reconciliation_id INTEGER NOT NULL, redeem_amount INTEGER NOT NULL)";
  String CREATE_SALES_TYPE =
      "CREATE TABLE sales_type (id VARCHAR PRIMARY KEY, name VARCHAR NOT NULL, deleted BOOL, company_id VARCHAR, mode VARCHAR)";
  String CREATE_TABLES =
      "CREATE TABLE tables (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT, name TEXT NOT NULL)";
  String CREATE_TAX_SERVICES =
      "CREATE TABLE tax_services (id VARCHAR PRIMARY KEY, outlet_id VARCHAR, percentage DOUBLE ,type VARCHAR, name VARCHAR, amount DOUBLE)";
  static String CREATE_LOG_PESANAN =
      "CREATE TABLE log_pesanan (local_id INTEGER PRIMARY KEY, timestamp INTEGER)";
  // String CREATE_TRANSACTION_INSTALLMENTS =
  //     "CREATE TABLE transaction_installments (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT, order_id INTEGER, server_id VARCHAR, is_paid BOOLEAN, amount DOUBLE, installment_period INTEGER, down_payment_amount DOUBLE, due_date BIGINT, is_reconciled BOOLEAN, notes TEXT, next_due_date BIGINT, next_paid_amount DOUBLE, paid_date DATETIME, cashier TEXT, payment_method_name TEXT, payment_method TEXT, payment_method_uuid TEXT, payment_method_type TEXT, is_integration BIGINT, reconcile_id BOOLEAN DEFAULT 0, change DOUBLE )";
  // String CREATE_TRANSACTION_INTEGRATED_PAYMENTS =
  //     "CREATE TABLE transaction_integrated_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, method TEXT, title TEXT, amount TEXT, change TEXT, data_json TEXT, data_status SMALLINT(2) DEFAULT 0, data_key TEXT )";
  // String CREATE_TRANSACTION_PAYMENTS =
  //     "CREATE TABLE transaction_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id BIGINT, custom_payment_method_uuid TEXT, method TEXT, title TEXT, amount TEXT, change TEXT )";
  // String CREATE_TRANSACTION_PONTA =
  //     "CREATE TABLE transaction_ponta (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL, member_id TEXT NOT NULL, member_name TEXT, transaction_amount_exclude_tax INTEGER NOT NULL, transaction_amount_include_tax INTEGER NOT NULL, issue_point INTEGER NOT NULL, issue_fee INTEGER NOT NULL, issue_tax INTEGER NOT NULL, issue_total INTEGER NOT NULL, redeem_point INTEGER NOT NULL, redeem_fee INTEGER NOT NULL, redeem_tax INTEGER NOT NULL, redeem_total INTEGER NOT NULL, balance_point INTEGER)";
  // String CREATE_TRANSACTION_TAX_SERVICES =
  //     "CREATE TABLE transaction_tax_services (id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER, tax_service_uuid VARCHAR, name VARCHAR, type VARCHAR, amount DOUBLE, percentage DOUBLE )";
  // String CREATE_TRANSACTION_POINT =
  //     "CREATE TABLE transaction_point (id INTEGER PRIMARY KEY AUTOINCREMENT, point_id VARCHAR)";

  String CREATE_ONLINE_ORDER =
      "CREATE TABLE online_order (device_timestamp TEXT, integration_order_id TEXT, transaction_id TEXT, void_uuid TEXT, online_order_status TEXT, created_at TEXT, updated_at TEXT, customer_id TEXT, customer_email TEXT, total_item_cost TEXT, customer_phone TEXT, customer_name TEXT, note TEXT, total_change TEXT, id TEXT, receipt_code TEXT, outlet_id TEXT, device_id TEXT, cashier_id TEXT, sales_type_id TEXT, sales_type_name TEXT, grab_order_id TEXT, grab_short_order_number TEXT, source TEXT, subtotal TEXT, total_tax TEXT, total_service TEXT, final_amount TEXT, discount_title TEXT, discount_amount TEXT, items LONGTEXT, payment LONGTEXT, sales_type LONGTEXT, taxes_and_services LONGTEXT, operator LONGTEXT, outlet LONGTEXT, device LONGTEXT)";
  String CREATE_PRINTERS =
      "CREATE TABLE printers (name TEXT, address TEXT, enableCetakStruk INTEGER, cetakStruk INTEGER, enableCetakLabel INTEGER, cetakLabel INTEGER, enableCetakDapur INTEGER, cetakDapur INTEGER, lebar TEXT,selectionDapur LONGTEXT, selectionCategory LONGTEXT)";
  String CREATE_OPERATOR =
      "CREATE TABLE operator (id VARCHAR, name VARCHAR, img VARCHAR, email VARCHAR, phone VARCHAR, status VARCHAR, pin VARCHAR, type VARCHAR, v1_user_id VARCHAR, permissions_str VARCHAR)";
}
