import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static DBHelper _dbHelper;
  static Database _database;
  String DB_NAME = "pawoondb1";
  String DB_ORDER = "orderdb4";
  String DB_PRODUCT = "productdb1";
  static bool updateAllTime = true;

  DBHelper._createObject();

  factory DBHelper() {
    if (_dbHelper == null || updateAllTime) {
      _dbHelper = DBHelper._createObject();
    }
    return _dbHelper;
  }
  Future<Database> initDb() async {
    //untuk menentukan nama database dan lokasi yg dibuat
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '$DB_NAME.db';

    var todoDatabase = openDatabase(path, version: 1, onCreate: _createDb);

    return todoDatabase;
  }

  //buat tabel baru dengan nama order
  void _createDb(Database db, int version) async {
    List<Future> arrFut = List();
    arrFut.add(db.execute(
        "CREATE TABLE $DB_ORDER (id INTEGER PRIMARY KEY AUTOINCREMENT, subtotal DOUBLE, tax DOUBLE, taxStr TEXT, taxAmount DOUBLE, service DOUBLE, serviceStr TEXT, serviceAmount DOUBLE, grandTotal DOUBLE, mappingOrder LONGTEXT, customAmount LONGTEXT, timestamp INT)"));
    arrFut.add(db
        .execute("CREATE TABLE $DB_PRODUCT (id TEXT PRIMARY KEY, data TEXT)"));
  }

  Future<Database> get database async {
    if (_database == null || updateAllTime) {
      _database = await initDb();
    }
    return _database;
  }

/* -------------------------------------------------------------------------- */
/*                                    ORDER                                   */
/* -------------------------------------------------------------------------- */
  Future<List<Map<String, dynamic>>> selectOrder({List<String> col}) async {
    if (col == null) col = ["*"];
    Database db = await this.database;
    var mapList = await db.query('$DB_ORDER', orderBy: 'id desc', columns: col);
    return mapList;
  }

  //create databases
  Future<int> insertOrder(BOrderParent object) async {
    // Otomatis update kalau id sudah exists
    if (object.id != null && object.id != "" && object.id != 0) {
      return updateOrder(object);
    } else {
      Database db = await this.database;
      int count = await db.insert('$DB_ORDER', object.toMap());
      return count;
    }
  }

//update databases
  Future<int> updateOrder(BOrderParent object) async {
    Database db = await this.database;
    int count = await db.update('$DB_ORDER', object.toMap(),
        where: 'id=?', whereArgs: [object.id]);
    return count;
  }

//delete databases
  Future<int> deleteOrder(int id) async {
    Database db = await this.database;
    int count = await db.delete('$DB_ORDER', where: 'id=?', whereArgs: [id]);
    return count;
  }

  Future<List<BOrderParent>> getOrderList() async {
    var orderMapList = await selectOrder();
    int count = orderMapList.length;
    // print(count);
    List<BOrderParent> orderList = List<BOrderParent>();
    for (int i = 0; i < count; i++) {
      orderList.add(BOrderParent.fromMap(orderMapList[i]));
    }
    return orderList;
  }

  Future<int> getOrderCount() async {
    var orderMapList = await selectOrder(col: ["id"]);
    int count = orderMapList.length;

    return count;
  }

/* -------------------------------------------------------------------------- */
/*                                   PRODUCT                                  */
/* -------------------------------------------------------------------------- */
  Future<List<Map<String, dynamic>>> selectProduct({List<String> col}) async {
    if (col == null) col = ["*"];
    Database db = await this.database;
    var mapList =
        await db.query('$DB_PRODUCT', columns: col);
    return mapList;
  }

  //create databases
  Future<int> insertProduct(BProduct object) async {
    // Otomatis update kalau id sudah exists
    if (object.id != null && object.id != "" && object.id != 0) {
      return updateProduct(object);
    } else {
      Database db = await this.database;
      int count = await db.insert('$DB_PRODUCT', object.toMap());
      return count;
    }
  }

  //update databases
  Future<int> updateProduct(BProduct object) async {
    Database db = await this.database;
    int count = await db.update('$DB_PRODUCT', object.toMap(),
        where: 'id=?', whereArgs: [object.id]);
    return count;
  }

  //delete databases
  Future<int> deleteProduct(int id) async {
    Database db = await this.database;
    int count = await db.delete('$DB_PRODUCT', where: 'id=?', whereArgs: [id]);
    return count;
  }

  Future<List<BProduct>> getProductList() async {
    var orderMapList = await selectOrder();
    int count = orderMapList.length;
    // print(count);
    List<BProduct> orderList = List<BProduct>();
    for (int i = 0; i < count; i++) {
      orderList.add(BProduct.fromMap(orderMapList[i]));
    }
    return orderList;
  }

  Future<int> getProductCount() async {
    var orderMapList = await selectOrder(col: ["id"]);
    int count = orderMapList.length;

    return count;
  }
}
