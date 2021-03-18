import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawoon/Bean/BBillings.dart';
import 'package:pawoon/Bean/BCompany.dart';
import 'package:pawoon/Bean/BCustomAmount.dart';
import 'package:pawoon/Bean/BDevice.dart';
import 'package:pawoon/Bean/BMeja.dart';
import 'package:pawoon/Bean/BPayment.dart';
import 'package:pawoon/Bean/BPelanggan.dart';
import 'package:pawoon/Bean/BSalesType.dart';
import 'package:pawoon/Bean/BTax.dart';
import 'package:pawoon/Bean/BVariant.dart';
import 'package:pawoon/Bean/BVariantData.dart';
import 'package:pawoon/Bean/BModifierData.dart';
import 'package:pawoon/Bean/BOperator.dart';
import 'package:pawoon/Bean/BOrder.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Bean/BVariantDetails.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBHelper.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Enums.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/SyncData.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/DrawerLeft.dart';
import 'package:pawoon/Views/OrderPopups.dart';
import 'package:pawoon/Views/RekapPopup.dart';

import '../main.dart';
import 'BGrabStatus.dart';
import 'CameraScanner.dart';
import 'DrawerRight.dart';

class Order extends StatefulWidget {
  static bool displayStock = false;
  static List<dynamic> permissions = List();
  static WidgetUnsync widgetUnsync;
  static bool shouldRefreshOrderid = false;

  Order({Key key}) : super(key: key);
  static List<BGrabStatus> arrStatus = [
    BGrabStatus.all(),
    BGrabStatus.SUBMITTED(),
    BGrabStatus.ACCEPTED(),
    BGrabStatus.BOOKING(),
    BGrabStatus.DRIVER_ALLOCATED(),
    BGrabStatus.DRIVER_ARRIVED(),
    BGrabStatus.COLLECTED(),
    BGrabStatus.DELIVERED(),
    BGrabStatus.CANCELLED(),
    BGrabStatus.FAILED(),
    BGrabStatus.READY_FOR_PICKUP(),
    BGrabStatus.OUT_FOR_PICKUP(),
    BGrabStatus.OUT_FOR_DELIVERY(),
    BGrabStatus.DELIVERY_CANCELLED(),
    BGrabStatus.DELIVERY_REJECTED(),
    BGrabStatus.NO_DRIVER(),
    BGrabStatus.ON_HOLD(),
    BGrabStatus.IN_RETURN(),
    BGrabStatus.RETURNED(),
    BGrabStatus.ORDER_NEED_CONFIRMATION(),
    BGrabStatus.STACK_ORDER_NEED_CONFIRMATION(),
  ];

  static Map<String, String> mapStatusDd = {};
  static Map<String, BGrabStatus> mapStatus = {};

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  // Widgets
  PullToRefresh pullToRefresh = PullToRefresh();
  Loader2 loader = Loader2(isLoading: true);
  DrawerLeft drawer;
  DrawerRight drawerRight;
  CustomInput inputSearch;
  TextEditingController contSearch = TextEditingController();
  // Data
  Map<String, List<BProduct>> mapProducts = Map();
  Map<String, List<BProduct>> mapProductsFiltered = Map();
  Map<String, String> mapCategory = Map();
  // Tampilan ada "kotak","daftar"
  List<BSalesType> arrSalesType = List();
  List<BPelanggan> arrPelanggan = List();
  // Variables
  String outletid;
  String categoryActive = "all";
  BOrderParent orderParent;
  CameraScanner cameraScanner;
  BBillings billings;
  String tampilan = "kotak";
  bool doLoadPertama = true;
  bool checkTutorial = true;

  var page = 1;
  var pageVariant = 1;
  @override
  void initState() {
    super.initState();
    activateScheduler();
    doGetAngkaTersimpan();
    initWidgets();
    drawer = DrawerLeft(
        listenerUpdateData: () => doUpdateData(),
        listenerOpenSetting: () => doOpenSetting(),
        listenerUpgrade: () => doUpgrade(),
        listenerOpenRekap: () => doOpenRekap());
    drawerRight = DrawerRight(
        listenerClick: (tag) => doClickDrawerRight(tag),
        orderParent: orderParent);
    cameraScanner = CameraScanner(listener: (data) {
      onScanned(data);
    });
    doResetOrder();
    SyncData.updateUnsyncCount();

    for (var item in Order.arrStatus) {
      if (item.title != "") Order.mapStatusDd[item.id] = item.title;
      Order.mapStatus[item.id] = item;
    }
  }

  Future<void> loadData({overrideCustomAmount = true}) async {
    List<Future> arrFut = List();
    arrFut.add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "")
        orderParent.outlet = BOutlet.parseObject(json.decode(value));
    }));
    arrFut.add(UserManager.getString(UserManager.OPERATOR_OBJ).then((value) {
      if (value != null && value != "") {
        orderParent.op = BOperator.parseObject(json.decode(value));
        Order.permissions.clear();
        Order.permissions.addAll(orderParent.op.permission);
        // print(Order.permissions);
      }
    }));
    arrFut.add(UserManager.getString(UserManager.DEVICE_OBJ).then((value) {
      if (value != null && value != "")
        orderParent.device = BDevice.parseObject(json.decode(value));
    }));
    arrFut.add(UserManager.getString(UserManager.OUTLET_ID).then((value) {
      outletid = value;
    }));
    arrFut.add(UserManager.getString(UserManager.BILLING_OBJ).then((value) {
      if (value != null && value != "") {
        billings = BBillings.fromJson(json.decode(value));
        checkBillingExpired();
      }
    }));
    if (overrideCustomAmount) {
      arrFut.add(UserManager.getString(UserManager.CUSTOM_AMOUNT_OBJ)
          .then((textCustomAmount) {
        if (textCustomAmount != null && textCustomAmount != "")
          orderParent.customAmount =
              BCustomAmount.fromJson(json.decode(textCustomAmount));
      }));
    }
    arrFut
        .add(UserManager.getString(UserManager.SETTING_TAMPILAN).then((value) {
      if (value != null && value != "") tampilan = value;
    }));

    await Future.wait(arrFut);
    await getIP();
    return doRefresh();

    // setState(() {});
  }

  Future getIP() async {
    if (await Helper.hasInternet()) {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          String ip = "${addr.address}";
          await UserManager.saveString(UserManager.SETTING_IP, ip);
        }
      }
    }
  }

  void initWidgets() {
    contSearch.addListener(() {
      doSearch();
    });

    inputSearch = CustomInput(
        hint: "Nama Produk atau SKU",
        displayUnderline: false,
        bordered: false,
        controller: contSearch);
  }

  void doSearch() {
    if (mapProducts[categoryActive] == null) return;
    mapProductsFiltered[categoryActive] = List();
    String substr = contSearch.text;

    for (BProduct prod in mapProducts[categoryActive]) {
      if (prod.name.toString().toLowerCase().contains(substr.toLowerCase()) ||
          prod.barcode
              .toString()
              .toLowerCase()
              .contains(substr.toLowerCase())) {
        mapProductsFiltered[categoryActive].add(prod);
      } else {
        for (var item in prod.variantdetails) {
          if (item.barcode
              .toString()
              .toLowerCase()
              .contains(substr.toLowerCase())) {
            mapProductsFiltered[categoryActive].add(prod);
            break;
          }
        }
      }
    }
    setState(() {});
  }

/* -------------------------------------------------------------------------- */
/*                                  UI Order                                  */
/* -------------------------------------------------------------------------- */
  var contextDrawer;

  void resetKalauOrderKosong() {
    if (!Order.shouldRefreshOrderid) return;
    Order.shouldRefreshOrderid = false;

    if (orderParent.mappingOrder.isEmpty &&
        (orderParent.customAmount == null ||
            orderParent.customAmount.amount == 0)) {
      // print("ORDER KOSONG");
      doResetOrder();
    } else {
      // print("ORDER ADA ISI");
    }
  }

  Future<void> reloadHalaman() async {
    await loadData();
    doResetDrawer();
    // keyDrawer.currentState.build(keyDrawer.currentContext);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (outletid == null) {}
    // resetKalauOrderKosong();
    if (doLoadPertama) {
      doLoadPertama = false;
      Helper.subscribeToFirebase(context);
    }
    SyncData.updateUnsyncCount();

    if (checkTutorial) {
      checkTutorial = false;
      displayHighlightTutorialBayar();
    }

    return Wgt.base(context,
        appbar: Wgt.appbar(context,
            displayPawoonLogo: true,
            name: orderParent != null &&
                    orderParent.outlet != null &&
                    orderParent.outlet.name != null
                ? orderParent.outlet.name
                : "",
            displayRight: true,
            arrIconButtons: rightIcons()), body: Builder(builder: (context) {
      if (context != null) contextDrawer = context;
      return Container(
          child: loader != null && loader.isLoading ? loader : body());
    }),
        // pullToRefresh.generate(
        // onRefresh: () => doRefresh(),

        drawer: drawer,
        rightDrawer: drawerRight,
        background: Container(
          color: Color(0xFFF1F1F1),
        ));
  }

  List<Widget> rightIcons() {
    bool orderOnline = false;
    if (orderParent != null &&
        orderParent.outlet != null &&
        orderParent.outlet.company != null &&
        orderParent.outlet.company.integrations != null) {
      for (var item in orderParent.outlet.company.integrations) {
        if (item.method == "online-order") orderOnline = true;
      }
    }
    return <Widget>[
      if (orderOnline)
        InkWell(
            onTap: () => navOrderOnline(),
            child: Row(children: [
              Wgt.spaceLeft(10),
              Stack(children: [
                Center(
                    child: Container(
                        padding: EdgeInsets.only(left: 7, right: 7),
                        child: Image.asset("assets/ic_order_online.png",
                            height: 25))),
              ]),
              Wgt.textSecondary(context, "ORDER",
                  color: Colors.white, weight: FontWeight.bold),
              Wgt.spaceLeft(10),
            ])),
      InkWell(
          onTap: () => navTersimpan(),
          child: Row(children: [
            Wgt.spaceLeft(10),
            Stack(children: [
              Center(
                  child: Container(
                      padding: EdgeInsets.only(left: 7, right: 7),
                      child: Icon(Icons.shopping_cart, color: Colors.white))),
              angkaTersimpan(),
            ]),
            Wgt.textSecondary(context, "TERSIMPAN",
                color: Colors.white, weight: FontWeight.bold),
            Wgt.spaceLeft(10),
          ])),
      InkWell(
          onTap: () => doToggleRightDrawer(),
          child: Container(
              padding: EdgeInsets.all(10), child: Icon(Icons.more_vert))),
      Wgt.spaceLeft(10),
    ];
  }

  num countTersimpan = 0;
  Future doGetAngkaTersimpan() async {
    int count = await DBPawoon().getCount(tablename: DBPawoon.DB_ORDERS);
    // print("tersimpan : $count");
    countTersimpan = count;
    setState(() {});
  }

  void doToggleRightDrawer() {
    Scaffold.of(contextDrawer).openEndDrawer();
  }

  Widget angkaTersimpan() {
    if (countTersimpan == null || countTersimpan <= 0) return Container();

    return Positioned(
      left: 0,
      child: Container(
          margin: EdgeInsets.only(top: 10),
          height: 20,
          width: 20,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Cons.COLOR_ACCENT,
              borderRadius: BorderRadius.circular(50)),
          child: FittedBox(
              child: Wgt.textSecondarySmall(context, "$countTersimpan",
                  color: Colors.white, weight: FontWeight.w600))),
    );
  }

  Future<void> navTersimpan() async {
    var payload = await Helper.openPage(context, Main.SAVED);
    doGetAngkaTersimpan();
    if (payload != null) {
      orderParent = payload;

      await doLengkapiParentOrder(overrideCustomAmount: false);
      doResetDrawer();
      setState(() {});

      if (orderParent.payment.isNotEmpty &&
          orderParent.payment[0].responseRaw != null &&
          orderParent.payment[0].responseRaw != "") {
        doBayar();
      }
    }
  }

  void navOrderOnline() {
    Helper.openPage(context, Main.ORDER_ONLINE);
  }

  Widget body() {
    return Container(
        color: Color(0xFFF1F1F1),
        child: Stack(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Panel kiri
              Container(
                  width: MediaQuery.of(context).size.width / 5,
                  child: Column(children: [
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(10),
                      child: panelCategory(),
                    )),
                    Container(
                        padding:
                            EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        child: panelTools())
                  ])),

              // Panel tengah
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(children: [
                        activeSearch ? panelSearch() : Container(),
                        Expanded(child: panelActive()),
                      ]))),

              // Panel kanan
              Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  padding: EdgeInsets.all(10),
                  child: Column(children: [
                    panelMeja(),
                    panelOrder(),
                  ]))
            ]),
            panelOrderDetails()
          ],
        ));
  }

/* -------------------------------------------------------------------------- */
/*                                   CATEGORY                                 */
/* -------------------------------------------------------------------------- */
  Widget panelCategory() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(5)),
        child: SingleChildScrollView(
            child: Column(children: [
          cellFavoriteTablet("fav"),
          cellCategoryTablet("all"),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: mapCategory.length,
              itemBuilder: (context, index) {
                var id = mapCategory.keys.toList()[index];
                return cellCategoryTablet(id);
              })
        ])));
  }

  Widget cellCategoryTablet(id) {
    var name = "Semua";
    if (id != "all") name = mapCategory[id];
    bool isactive = id == categoryActive;
    return InkWell(
        onTap: () => doCategoryClick(id),
        child: Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
            color: isactive ? Cons.COLOR_PRIMARY : Colors.transparent,
            child: Row(children: [
              Expanded(
                  child: Wgt.textSecondary(context, "$name",
                      color: isactive ? Colors.white : Colors.black)),
            ])));
  }

  Widget cellFavoriteTablet(id) {
    bool isactive = id == categoryActive;
    return InkWell(
        onTap: () => doCategoryClick(id),
        child: Container(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
            color: isactive ? Cons.COLOR_PRIMARY : Colors.transparent,
            child: Row(children: [
              Icon(Icons.star, color: Colors.amber),
              Expanded(
                  child: Wgt.textSecondary(context, "Favorit",
                      color: isactive ? Colors.white : Colors.black)),
            ])));
  }

  void doCategoryClick(id) {
    categoryActive = id;
    contSearch.text = "";
    doSearch();
    setState(() {});
  }

/* -------------------------------------------------------------------------- */
/*                           PANEL TOOLS                                      */
/* -------------------------------------------------------------------------- */
/**
 * Panel kiri bawah
 */
  bool activeSearch = false;
  bool activeScan = false;

  Widget panelTools() {
    return Container(
        // padding: EdgeInsets.only(top: 15, bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(children: [
          Expanded(child: Container()),
          InkWell(
              onTap: () => doActivateSearch(),
              child: Container(
                padding: EdgeInsets.all(15),
                child: Icon(Icons.search,
                    size: 25,
                    color: activeSearch ? Cons.COLOR_PRIMARY : Colors.grey),
              )),
          Expanded(child: Container()),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => doActivateScanner(),
                  child: Container(
                      padding: EdgeInsets.all(15),
                      child: Image.asset("assets/ic_barcode.png",
                          height: 18,
                          color:
                              activeScan ? Cons.COLOR_PRIMARY : Colors.grey)))),
          Expanded(child: Container()),
        ]));
  }

  Widget panelSearch() {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.only(top: 5, bottom: 0, left: 10, right: 10),
        child: Row(children: [
          Wgt.spaceLeft(10),
          Icon(Icons.search, color: Colors.grey),
          Wgt.spaceLeft(10),
          Expanded(
              child: CustomInput(
                  hint: "Nama Produk atau SKU",
                  controller: contSearch,
                  polosan: true)),
        ]));
  }

  void doActivateSearch() {
    activeSearch = !activeSearch;
    if (activeSearch && activeScan) {
      activeScan = false;
    }
    setState(() {});
  }

  void doActivateScanner() {
    activeScan = !activeScan;
    if (activeSearch && activeScan) {
      activeSearch = false;
    }
    setState(() {});
  }

  // bool isScanned = false;
  bool scanAvailable = true;
  void onScanned(data) {
    // Jagain coding ini biar nggak double scan
    if (!scanAvailable) return;
    scanAvailable = false;
    doActivateScanner();
    playSound();

    String text = data.code.toString().toLowerCase();
    BOrder selected;
    for (var item in mapProductsFiltered["all"]) {
      if (item.barcode.toString().toLowerCase().contains(text)) {
        if (selected != null) break;
        selected = BOrder(product: BProduct.clone(item), qty: 1);
      } else {
        for (var variant in item.variantdetails) {
          if (variant.barcode.toString().toLowerCase().contains(text)) {
            selected = BOrder(
                product: BProduct.clone(item),
                qty: 1,
                variants: variant.variantdata);
          }
        }
      }
    }

    if (selected == null) {
      Helper.confirm(context, "Perhatian",
          "Produk ${data.code} tidak ada di dalam basis data", () {
        activeScan = true;
        setState(() {});
      }, () {}, textCancel: "");
    } else {
      if (orderParent.mappingOrder[selected.id] == null)
        orderParent.mappingOrder[selected.id] = selected;
      else {
        orderParent.mappingOrder[selected.id].qty++;
        if (orderParent.mappingOrder[selected.id].modifiers != null)
          for (BModifierData mod
              in orderParent.mappingOrder[selected.id].modifiers) {
            for (BModifierData dataBaru in selected.modifiers) {
              if (mod.id == dataBaru.id) {
                mod.qty += dataBaru.qty;
              }
            }
          }
      }
    }

    scanAvailable = true;
  }

  Future<void> playSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("beep.mp3");
  }

/* -------------------------------------------------------------------------- */
/*                                PANEL ACTIVE                                */
/* -------------------------------------------------------------------------- */
/**
 * Panel yang di tengah
 */
  Widget panelActive() {
    // mapProducts["all"]
    if (mapProducts.isEmpty) return panelProductKosong();

    Widget activePanel = Container();
    // if (categoryActive == "fav")
    //   activePanel = panelFavorite();
    // else
    activePanel = panelProducts(categoryActive);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(5),
      ),
      child: activePanel,
    );
  }

  Widget panelProductKosong() {
    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset("assets/ic_product_empty.png", height: 200),
      Wgt.spaceTop(20),
      Wgt.text(context, "Anda belum memiliki produk untuk dijual",
          size: Wgt.FONT_SIZE_NORMAL_2),
    ]));
  }

  /* -------------------------------------------------------------------------- */
  /*                                 PANEL KIRI                                 */
  /* -------------------------------------------------------------------------- */
  Widget panelFavorite() {
    num width = MediaQuery.of(context).size.width / 5;
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Column(children: [
          Row(),
          Expanded(child: Container()),
          Container(
              width: width,
              height: width,
              child: Image.asset("assets/ic_empty_state_product_favorite.png")),
          Wgt.text(context, "Anda belum memilih produk favorit"),
          Wgt.spaceTop(15),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => doOpenSetting(),
                  child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          border: Border.all(color: Cons.COLOR_PRIMARY),
                          borderRadius: BorderRadius.circular(5)),
                      child: Wgt.text(context, "TAMBAH FAVORIT",
                          weight: FontWeight.bold,
                          color: Cons.COLOR_PRIMARY)))),
          Expanded(child: Container()),
        ]));
  }

  Future<void> doOpenSetting() async {
    await Helper.openPage(context, Main.SETTING, arg: {
      "mapProducts": mapProducts,
      "mapCategory": mapCategory,
      "listenerUpdateData": () => doUpdateData()
    });
    await loadData();
    print('sini');
    resetKalauOrderKosong();
    // await loadFromDB();
    // doSearch();
    setState(() {});
  }

  Future<void> doOpenRekap() async {
    await Helper.openPage(context, Main.REKAP);
    resetKalauOrderKosong();
  }

  Future<void> doUpgrade() async {
    await Helper.openPage(context, Main.BILLING);
    // await Helper.openPage(context, Main.BILLING_MIDTRANS);

    // reloadHalaman();
  }

  Widget panelProducts(id) {
    if (id == "fav" &&
        (mapProductsFiltered[id] == null || mapProductsFiltered[id].isEmpty))
      return panelFavorite();

    if (mapProductsFiltered[id] == null) mapProductsFiltered[id] = List();

    var col = 4;
    var ratio = 0.74;
    if (Order.displayStock == null) Order.displayStock = false;
    if (Order.displayStock) {
      ratio = 0.65;
    }
    if (tampilan != null && tampilan == "daftar") {
      col = 1;
      ratio = 7.0;
    }

    if (activeScan) {
      return cameraScanner;
    }

    return loader.isLoading
        ? loader
        : GridView.count(
            padding: EdgeInsets.only(left: 0, right: 0, bottom: 0),
            crossAxisCount: col,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: ratio,
            children: List.generate(mapProductsFiltered[id].length, (index) {
              return cellProduct(mapProductsFiltered[id][index], index: index);
            }));
  }

  String doGetInitials(name) {
    var nameParts = name.split(" ").map((elem) {
      return elem[0];
    });

    if (nameParts.length == 0) {
      return "";
    }

    int numberOfParts = min(2, nameParts.length);
    return nameParts.join().substring(0, numberOfParts);
  }

  Widget cellProduct(BProduct prod, {index}) {
    // Display listview instead
    if (tampilan != null && tampilan == "daftar") return cellProductList(prod);
    // print("imgurl:${prod.img}");
    bool active = prod.is_active;
    return Container(
        key: index == 0 ? Helper.fabKey : null,
        color: Colors.white,
        child: Material(
            // Di wrap biar ada ripple nya
            color: Colors.transparent,
            child: InkWell(
                onLongPress: () => doPopupStock(prod),
                onTap: () => doClickProduct(prod),
                child: Column(children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                          child: Stack(children: [
                            Positioned.fill(
                                child: (prod.img == null || prod.img == "")
                                    ? FittedBox(
                                        child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Wgt.textLarge(
                                                context,
                                                doGetInitials(prod.name)
                                                    .toUpperCase(),
                                                color: Colors.white)),
                                      )
                                    : Wgt.image(url: prod.img)),
                            if (!active)
                              Positioned.fill(
                                  child: Container(
                                      color: Color(0xBBFFFFFF),
                                      child: FittedBox(
                                          child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Icon(
                                            Icons.highlight_remove_outlined,
                                            color: Colors.red[800]),
                                      ))))
                          ]))),
                  Row(children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                // color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5),
                                    bottomRight: Radius.circular(5))),
                            padding: EdgeInsets.only(
                                top: 10, bottom: 10, left: 10, right: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wgt.textSecondary(context, prod.name,
                                      align: TextAlign.left,
                                      maxlines: 1,
                                      color:
                                          active ? Colors.black : Colors.grey),
                                  if (Order.displayStock)
                                    Container(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Wgt.textSecondary(context,
                                            "${prod.stock <= 0 ? "Kosonga" : prod.stock}${prod.stock <= 0 ? "" : prod.stock_unit ?? ""}",
                                            color: active
                                                ? Cons.COLOR_PRIMARY
                                                : Colors.grey,
                                            weight: FontWeight.w500)),
                                ])))
                  ]),
                ]))));
  }

  Widget cellProductList(BProduct prod) {
    bool active = prod.is_active;
    num rangePrice1, rangePrice2;
    for (BVariantDetails varData in prod.variantdetails) {
      if (rangePrice1 == null) rangePrice1 = varData.price;
      if (rangePrice2 == null) rangePrice2 = varData.price;

      rangePrice1 = min(rangePrice1, varData.price);
      rangePrice2 = max(rangePrice2, varData.price);
    }

    String hargaStr = "";
    if (rangePrice1 != null && rangePrice2 != null) {
      if (rangePrice1 != rangePrice2)
        hargaStr =
            "${Helper.formatRupiahInt(rangePrice1)} - ${Helper.formatRupiahInt(rangePrice2)}";
      else
        hargaStr = "${Helper.formatRupiahInt(rangePrice1)}";
    } else {
      hargaStr = "${Helper.formatRupiahInt(prod.price)}";
    }

    return Container(
        color: Colors.white,
        child: Material(
            // Di wrap biar ada ripple nya
            color: Colors.transparent,
            child: InkWell(
                onLongPress: () => doPopupStock(prod),
                onTap: () => doClickProduct(prod),
                child: Row(children: [
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      height: 60,
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(0)),
                              child: Stack(children: [
                                Positioned.fill(
                                    child: (prod.img == null || prod.img == "")
                                        ? FittedBox(
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Wgt.textLarge(
                                                    context,
                                                    doGetInitials(prod.name)
                                                        .toUpperCase(),
                                                    color: Colors.white)))
                                        : Wgt.image(url: prod.img)),
                                if (!active)
                                  Positioned.fill(
                                      child: Container(
                                          color: Color(0xBBFFFFFF),
                                          child: FittedBox(
                                              child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Icon(
                                                      Icons
                                                          .highlight_remove_outlined,
                                                      color:
                                                          Colors.red[800])))))
                              ])))),
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Container()),
                                Wgt.text(context, prod.name,
                                    align: TextAlign.left,
                                    maxlines: 1,
                                    color: active ? Colors.black : Colors.grey),
                                Wgt.spaceTop(5),
                                Wgt.textSecondary(context, "$hargaStr",
                                    align: TextAlign.left,
                                    maxlines: 1,
                                    color: active
                                        ? Colors.grey[800]
                                        : Colors.grey),
                                Expanded(child: Container()),
                              ]))),
                  if (Order.displayStock)
                    Container(
                        padding: EdgeInsets.only(top: 10, right: 10),
                        child: Column(children: [
                          Expanded(
                              child: Wgt.textSecondary(context,
                                  "${prod.stock == 0 ? "Kosong" : prod.stock}${prod.stock <= 0 ? "" : prod.stock_unit}",
                                  color:
                                      active ? Cons.COLOR_PRIMARY : Colors.grey,
                                  weight: FontWeight.w500)),
                        ])),
                ]))));
  }

  Future doClickProduct(BProduct prod) async {
    if (!prod.is_active) {
      Helper.confirm(context, "Produk Tidak Tersedia",
          "Pastikan produk ini dalam kondisi tersedia untuk dijual. Apakah anda ingin melanjutkan pesanan?",
          () {
        doOpenClickProduct(prod);
      }, () {
        return;
      });
    } else
      doOpenClickProduct(prod);
  }

  Future<void> doOpenClickProduct(BProduct prod) async {
    BOrder hasilOrder = await showDialog(
        context: context, builder: (_) => OrderPopProduct(product: prod));
    if (hasilOrder == null) {
      // Do nothing
    } else {
      if (orderParent.mappingOrder[hasilOrder.id] == null)
        orderParent.mappingOrder[hasilOrder.id] = hasilOrder;
      else {
        orderParent.mappingOrder[hasilOrder.id].qty++;
        if (orderParent.mappingOrder[hasilOrder.id].modifiers != null)
          for (BModifierData mod
              in orderParent.mappingOrder[hasilOrder.id].modifiers) {
            for (BModifierData dataBaru in hasilOrder.modifiers) {
              if (mod.id == dataBaru.id) {
                mod.qty += dataBaru.qty;
              }
            }
          }
      }
    }
    setState(() {});
  }

  Future<void> doPopupStock(BProduct prod) async {
    // if (!Order.displayStock) {
    //   return;
    // }

    await showDialog(context: context, builder: (_) => PopupStock(prod: prod));
    setState(() {});
  }

  /* -------------------------------------------------------------------------- */
  /*                                 PANEL MEJA                                 */
  /* -------------------------------------------------------------------------- */
  /**
   * Panel kanan atas
   */
  Widget panelMeja() {
    String customAmtStr = "Custom Amount";
    if (orderParent.customAmount != null &&
        orderParent.customAmount.total > 0) {
      customAmtStr = Helper.formatRupiahInt(orderParent.customAmount.total);
    }

    String strName = "Pelanggan";
    bool haveName = false;
    if (orderParent.pelanggan.name != null &&
        orderParent.pelanggan.name != "") {
      strName = orderParent.pelanggan.name;
      haveName = true;
    }

    String strMeja = "Meja";
    bool haveMeja = false;
    if (orderParent.meja != null) {
      strMeja = orderParent.meja.name;
      haveMeja = true;
    }
    return Container(
        padding: EdgeInsets.only(left: 0, right: 0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5)),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Expanded(
            //     child: Material(
            //         color: Colors.transparent,
            //         child: InkWell(
            //             onTap: () => doMeja(),
            //             child: Container(
            //                 padding: EdgeInsets.only(
            //                     left: 5, right: 5, top: 15, bottom: 15),
            //                 child: Row(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Expanded(
            //                           child: Column(children: [
            //                         Image.asset("assets/combined_shape.png",
            //                             height: 20),
            //                         Wgt.spaceTop(10),
            //                         Wgt.textSecondarySmall(context, "$strMeja",
            //                             color: Colors.black,
            //                             maxlines: 1,
            //                             weight: FontWeight.bold),
            //                       ])),
            //                       if (haveMeja)
            //                         InkWell(
            //                             onTap: () => doClearMeja(),
            //                             child: Icon(Icons.clear,
            //                                 color: Colors.red))
            //                     ]))))),
            Expanded(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () => doCustomAMount(),
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(children: [
                              Image.asset("assets/calculator.png", height: 20),
                              Wgt.spaceTop(10),
                              Wgt.textSecondarySmall(context, "$customAmtStr",
                                  color: Colors.black,
                                  maxlines: 1,
                                  weight: FontWeight.bold),
                            ]))))),
            // Expanded(
            //     child: Material(
            //         color: Colors.transparent,
            //         child: InkWell(
            //             onTap: () => doPelanggan(),
            //             child: Container(
            //                 padding: EdgeInsets.only(
            //                     left: 5, bottom: 15, top: 15, right: 5),
            //                 child: Row(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Expanded(
            //                           child: Column(children: [
            //                         Image.asset(
            //                             "assets/ic_account_box_24_px.png",
            //                             height: 20),
            //                         Wgt.spaceTop(10),
            //                         Wgt.textSecondarySmall(context, "$strName",
            //                             color: Colors.black,
            //                             maxlines: 1,
            //                             weight: FontWeight.bold),
            //                       ])),
            //                       if (haveName)
            //                         InkWell(
            //                             onTap: () => doClearNama(),
            //                             child: Icon(Icons.clear,
            //                                 color: Colors.red))
            //                     ]))))),
          ]),
          if (orderParent.salestype.name != "")
            Row(key: Helper.fabKey2, children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                      child: Wgt.btn(context, "${orderParent.salestype.name}",
                          onClick: () => doSalesType(),
                          transparent: true,
                          textcolor: Cons.COLOR_PRIMARY,
                          borderColor: Cons.COLOR_PRIMARY,
                          fontSize: 15,
                          weight: FontWeight.normal)))
            ])
        ]));
  }

  void doClearNama() {
    orderParent.pelanggan.name = "";
    setState(() {});
  }

  void doClearMeja() {
    orderParent.meja = null;
    setState(() {});
  }

  Future<void> doSalesType() async {
    var tipePenjualan = await showDialog(
        context: context,
        builder: (_) => PopupTipePenjualan(
            type: orderParent.salestype, arrSalesType: arrSalesType));
    if (tipePenjualan != null) {
      orderParent.salestype = tipePenjualan["salestype"];
      setState(() {});
    }
  }

  Future<void> doMeja() async {
    await Helper.openPage(context, Main.MEJA,
        arg: {"orderParent": orderParent});
    setState(() {});
  }

  Future<void> doCustomAMount() async {
    if (!await Helper.validateInternet(context)) return;
    BCustomAmount custom = await showDialog(
        context: context,
        builder: (_) =>
            OrderCustomAmount(customAmount: orderParent.customAmount));
    if (custom != null) {
      this.orderParent.customAmount = custom;
      setState(() {});
    }
  }

  Future<void> doNotesCustomAmount() async {
    BCustomAmount notes = await showDialog(
        context: context,
        builder: (_) =>
            CustomAmountNotes(customAmount: orderParent.customAmount));
    if (notes != null) {
      orderParent.customAmount = notes;
      setState(() {});
    }
  }

  Future<void> doPelanggan() async {
    await Helper.openPage(context, Main.PELANGGAN,
        arg: {"pelanggan": arrPelanggan, "orderParent": orderParent});
    setState(() {});
  }

  /* -------------------------------------------------------------------------- */
  /*                                 PANEL ORDER                                */
  /* -------------------------------------------------------------------------- */

  Widget panelOrder() {
    if (orderParent.mappingOrder.isEmpty &&
        (orderParent.customAmount == null ||
            orderParent.customAmount.total <= 0)) return panelOrderKosong();

    return Container(
        // padding: EdgeInsets.only(top: 10),
        child: Expanded(
            child: Column(children: [
      Wgt.spaceTop(10),
      Expanded(child: panelOrderData()),
      Wgt.spaceTop(10),
      panelOrderSummary(),
    ])));
  }

  Widget panelOrderData() {
    orderParent.mappingOrder.forEach((key, value) {
      doHitungTotal(value);
    });

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
            child: SingleChildScrollView(
          child: Column(children: [
            ListView.builder(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderParent.mappingOrder.length,
                itemBuilder: (context, index) {
                  var key = orderParent.mappingOrder.keys.toList()[index];
                  return cellOrderData(orderParent.mappingOrder[key]);
                }),
            cellCustomAmount(),
          ]),
        )));
  }

  Widget cellCustomAmount() {
    if (orderParent.customAmount.total <= 0) return Container();

    return InkWell(
      onTap: () {
        doCustomAMount();
      },
      child: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 50, right: 20),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: Wgt.textSecondary(context, "Custom Amount",
                      color: Colors.black, weight: FontWeight.bold)),
              Wgt.textSecondary(context,
                  "${Helper.formatRupiahInt(orderParent.customAmount.total)}",
                  color: Colors.black),
            ]),
            Wgt.spaceTop(10),
            InkWell(
                onTap: () => doNotesCustomAmount(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Wgt.textSecondary(context, "Catatan",
                            color: Colors.black, weight: FontWeight.bold),
                        Wgt.spaceLeft(5),
                        Icon(Icons.edit, color: Cons.COLOR_PRIMARY),
                      ]),
                      Container(
                          padding: EdgeInsets.only(left: 0, top: 3),
                          child: Wgt.textSecondary(
                              context, "${orderParent.customAmount.notes}",
                              color: Colors.black)),
                    ])),
          ])),
    );
  }

  Widget cellOrderData(BOrder order) {
    // if (order.priceTotal == 0 || order.nameOrder == null) {
    // order = doHitungTotal(order);
    // }
    num totalMod = 0;
    if (order.modifiers != null)
      for (BModifierData data in order.modifiers) {
        totalMod += data.qty * data.price * order.qty;
      }
    var price = Helper.formatRupiah((order.priceTotal + totalMod).toString());
    var name = order.nameOrder;

    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () => clickOrderDetails(order),
            child: Container(
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                child: Column(children: [
                  Row(children: [
                    Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            color: Cons.COLOR_ACCENT,
                            borderRadius: BorderRadius.circular(30)),
                        child: FittedBox(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wgt.textLarge(context, "${order.qty}",
                              color: Colors.white, weight: FontWeight.bold),
                        ))),
                    Wgt.spaceLeft(10),
                    Expanded(
                        child: Wgt.textSecondary(context, "$name",
                            color: Colors.black, weight: FontWeight.bold)),
                    Wgt.spaceLeft(10),
                    Wgt.textSecondary(context, "$price", color: Colors.black)
                  ]),
                  orderDataModifier(order),
                  if (order.notes != null && order.notes != "")
                    Container(
                        margin: EdgeInsets.only(top: 10, left: 50),
                        child: Row(children: [
                          Wgt.textSecondary(context, "Catatan : ",
                              color: Colors.black),
                          Wgt.textSecondary(context, "${order.notes}",
                              color: Cons.COLOR_PRIMARY),
                        ])),
                ]))));
  }

  Widget orderDataModifier(BOrder order, {double marginLeft = 50}) {
    if (order.modifiers == null) return Container();

    return ListView.builder(
        padding: EdgeInsets.only(left: marginLeft),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: order.modifiers.length,
        itemBuilder: (context, index) {
          var name = order.modifiers[index].name;
          var qty = order.modifiers[index].qty;
          var price = order.modifiers[index].price;
          // var total = qty * price * order.qty;
          var total = qty * price;
          var totalStr = Helper.formatRupiah(total.toString());
          return Container(
              child: Wgt.textSecondary(context,
                  "+ $name x $qty (${Helper.formatRupiahDouble(total)})",
                  color: Colors.black));
        });
  }

  Widget orderDataModifier2(BOrder order, {double marginLeft = 50}) {
    if (order.modifiers == null) return Container();

    return ListView.builder(
        padding: EdgeInsets.only(left: marginLeft),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: order.modifiers.length,
        itemBuilder: (context, index) {
          var name = order.modifiers[index].name;
          var qty = order.modifiers[index].qty;
          var price = order.modifiers[index].price;
          // var total = qty * price * order.qty;
          var total = qty * price;
          var totalStr = Helper.formatRupiah(total.toString());
          return Container(
              child: Wgt.textSecondary(context,
                  "+ $name @ ${Helper.formatRupiahDouble(price)} x $qty",
                  color: Colors.black));
        });
  }

  void hitungSummary() {
    orderParent.subtotal = 0;
    orderParent.mappingOrder.forEach((key, value) {
      num totalMod = 0;
      if (value.modifiers != null)
        for (BModifierData data in value.modifiers) {
          totalMod += data.qty * data.price * value.qty;
        }

      orderParent.subtotal += value.priceTotal + totalMod;
      // orderParent.subtotal += value.priceTotal;
    });
    if (orderParent.customAmount != null &&
        orderParent.customAmount.total != null) {
      orderParent.subtotal += orderParent.customAmount.total;
    }
    if (orderParent.mappingTaxServices["service"] != null) {
      if (orderParent.enableService)
        orderParent.service =
            num.parse("${orderParent.mappingTaxServices["service"].percentage}")
                    .round()
                    .toDouble() ??
                0.0;
      else
        orderParent.service = 0.0;
    } else {
      orderParent.service = 0;
    }
    orderParent.serviceStr = orderParent.service % 1 == 0
        ? orderParent.service.toStringAsFixed(0)
        : orderParent.service.toString();
    orderParent.serviceAmount =
        (orderParent.service * orderParent.subtotal / 100).round().toDouble();
    // Simpan ke object nya, buat dikirim ke server
    if (orderParent.mappingTaxServices["service"] != null)
      orderParent.mappingTaxServices["service"].amount =
          orderParent.serviceAmount;
    if (orderParent.mappingTaxServices["tax"] != null) {
      orderParent.tax =
          num.parse("${orderParent.mappingTaxServices["tax"].percentage}") ??
              0.0;
    } else {
      orderParent.tax = 0;
    }
    orderParent.taxStr = orderParent.tax % 1 == 0
        ? orderParent.tax.toStringAsFixed(0)
        : orderParent.tax.toString();
    orderParent.taxAmount = (orderParent.tax *
            (orderParent.subtotal + orderParent.serviceAmount) /
            100)
        .round()
        .toDouble();
    // Simpan ke object nya, buat dikirim ke server
    if (orderParent.mappingTaxServices["tax"] != null)
      orderParent.mappingTaxServices["tax"].amount = orderParent.taxAmount;

    orderParent.grandTotal = orderParent.subtotal +
        orderParent.taxAmount +
        orderParent.serviceAmount;

    num pembulatan =
        (orderParent.grandTotal - (orderParent.grandTotal ~/ 100 * 100));
    orderParent.grandTotal = orderParent.grandTotal - pembulatan;
    orderParent.pembulatan = pembulatan.toDouble();
    orderParent.pembulatanStr =
        Helper.formatRupiahDouble(orderParent.pembulatan);
  }

  Widget panelOrderSummary() {
    hitungSummary();
    return Container(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: InkWell(
            onTap: () => doClickServiceCharge(),
            child: Column(children: [
              cellOrderSummary(
                  title: "Subtotal",
                  price:
                      "${Helper.formatRupiah(orderParent.subtotal.toString())}"),
              orderParent.serviceAmount > 0
                  ? cellOrderSummary(
                      title: "Service Charge (${orderParent.serviceStr}%)",
                      price:
                          "${Helper.formatRupiah(orderParent.serviceAmount.toString())}")
                  : Container(),
              orderParent.taxAmount > 0
                  ? cellOrderSummary(
                      title: "PPN (${orderParent.taxStr}%)",
                      price:
                          "${Helper.formatRupiah(orderParent.taxAmount.toString())}")
                  : Container(),
              orderParent.pembulatan > 0
                  ? cellOrderSummary(
                      title: "Pembulatan",
                      price: "-${orderParent.pembulatanStr}")
                  : Container(),
              Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Row(children: [
                    Expanded(
                        child: Wgt.text(context, "TOTAL",
                            weight: FontWeight.bold)),
                    Expanded(
                        child: Wgt.text(context,
                            "${Helper.formatRupiah(orderParent.grandTotal.toString())}",
                            align: TextAlign.end, weight: FontWeight.bold)),
                  ])),
              Container(
                  padding: EdgeInsets.only(left: 0, right: 0, top: 10),
                  child: Row(children: [
                    Wgt.btn(context, "SIMPAN",
                        color: Cons.COLOR_ACCENT,
                        fontSize: 15,
                        weight: FontWeight.bold,
                        onClick: () => doSimpan()),
                    Wgt.spaceLeft(10),
                    Expanded(
                        key: Helper.fabBayar,
                        child: Wgt.btn(context, "BAYAR",
                            fontSize: 15,
                            weight: FontWeight.bold,
                            onClick: () => doBayar())),
                  ]))
            ])));
  }

  void doClickServiceCharge() {
    Helper.confirm(context, "Service charge",
        "${orderParent.enableService ? "Nonaktifkan service charge?" : "Aktifkan service charge?"} Lanjutkan?",
        () {
      orderParent.enableService = !orderParent.enableService;
      setState(() {});
    }, () {});
  }

  Widget cellOrderSummary({title, price}) {
    return Container(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(children: [
          Expanded(
              child: Wgt.textSecondary(context, "$title", color: Colors.black)),
          Container(
              child: Wgt.textSecondary(context, "$price",
                  align: TextAlign.end, color: Colors.black)),
        ]));
  }

  Widget panelOrderKosong() {
    return Expanded(
        child: Container(
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(child: Container()),
                Icon(Icons.arrow_back),
                Wgt.spaceLeft(10),
                Wgt.text(context, "Pilih Pesanan"),
                Expanded(child: Container()),
              ],
            )));
  }

  Future<void> doBayar() async {
    var sudahBayar = await Helper.openPage(context, Main.BAYAR, arg: {
      "total": orderParent.grandTotal.toInt(),
      "order": BOrderParent.clone(orderParent)
    });
    if (sudahBayar != null) {
      doResetOrder();
    }
  }

  Future<void> doSimpan() async {
    // var hasil = await DBHelper().insertOrder(orderParent);
    orderParent.revision++;

    var hasil = await DBPawoon().insertOrUpdate(
        tablename: DBPawoon.DB_ORDERS, data: orderParent.toMap());
    if (hasil != null && hasil >= 1) {
      if (orderParent.revision >= 1) {
        Helper.printReceipt(context, orderParent,
            reprint: false, showSelection: false);
      }

      await DBPawoon().incrementLocalId(id: orderParent.id);
      await doResetOrder();
      doGetAngkaTersimpan();
      setState(() {});
    } else {
      Helper.toastError(context, "Data gagal tersimpan");
    }
  }

  /* ---------------------------- LOGIC PANEL ORDER --------------------------- */
  /**
   * Hitung total per order nya
   * dan generate nama + variants, biar gampang tinggal display aja
   */
  BOrder doHitungTotal(BOrder order) {
    var price = order.product.price;
    var qty = order.qty;
    num totalMod = 0;
    if (order.modifiers != null)
      for (BModifierData data in order.modifiers) {
        totalMod += data.qty * data.price * order.qty;
      }

    var nameTemp = "${order.product.name}";
    if (order.variants != null)
      for (BVariantData data in order.variants) {
        nameTemp += " - ${data.name}";
      }

    // order.priceTotal = (price * qty) + totalMod;
    order.priceTotal = (price * qty);
    order.nameOrder = nameTemp;
    return order;
  }

  void clickOrderDetails(BOrder order) {
    this.popupOrder = BOrder.clone(order);

    setState(() {});
  }

  /* -------------------------------------------------------------------------- */
  /*                             POPUP ORDER DETAILS                            */
  /* -------------------------------------------------------------------------- */
  BOrder popupOrder;

  /* ---------------------------- POPUP PANEL KIRI ---------------------------- */
  Widget panelOrderDetails() {
    if (popupOrder == null) return Container();
    // Hitung ulang lagi total harganya, supaya up to date
    popupOrder = doHitungTotal(popupOrder);

    return InkWell(
        onTap: () {
          // Do nothing, biar ga bisa klik item di bawahnya
        },
        child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.85)),
            child: Row(children: [
              Expanded(flex: 2, child: panelOrderDetailsLeft()),
              Expanded(flex: 1, child: panelOrderDetailsRight()),
            ])));
  }

  Widget panelOrderDetailsLeft() {
    bool punyaModifiersVariants = ((popupOrder.product.modifiers != null &&
            popupOrder.product.modifiers.isNotEmpty) ||
        (popupOrder.product.variant != null &&
            popupOrder.product.variant.isNotEmpty));
    return Stack(children: [
      Column(children: [
        Expanded(
            child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Wgt.textLarge(
                                        context, "${popupOrder.nameOrder}",
                                        weight: FontWeight.bold)),
                                Wgt.spaceLeft(10),
                                btnOutline(
                                    text: "Hapus Pesanan",
                                    color: Colors.red,
                                    listener: () => doHapusOrder(popupOrder)),
                              ]),
                              Container(
                                  child: orderDataModifier2(popupOrder,
                                      marginLeft: 20)),
                              Wgt.spaceTop(20),
                              punyaModifiersVariants
                                  ? btnOutline(
                                      text: "Varian / Opsi Tambahan",
                                      paddingX: 25,
                                      listener: () => openVarian(popupOrder))
                                  : Container(),
                              Wgt.spaceTop(40),
                              Row(children: [
                                Expanded(
                                    flex: 3,
                                    child: Column(children: [
                                      Row(children: [
                                        Wgt.text(context, "Harga"),
                                        Wgt.spaceLeft(20),
                                        Expanded(
                                            child: InkWell(
                                                onTap: () =>
                                                    doUbahHarga(popupOrder),
                                                child: Wgt.textLarge(context,
                                                    "${Helper.formatRupiahInt(popupOrder.product.price, currency: "")}",
                                                    align: TextAlign.end)))
                                      ]),
                                      Wgt.separator(
                                          color: Colors.grey[400], margintop: 5)
                                    ])),
                                Wgt.spaceLeft(20),
                                Expanded(
                                    flex: 1,
                                    child: btnOutline(
                                        text: "Ubah Harga",
                                        listener: () =>
                                            doUbahHarga(popupOrder)))
                              ]),
                              Wgt.spaceTop(40),
                              Row(children: [
                                Expanded(
                                    flex: 3,
                                    child: Column(children: [
                                      Row(children: [
                                        Wgt.text(context, "Jumlah"),
                                        Wgt.spaceLeft(20),
                                        Expanded(
                                            child: InkWell(
                                                onTap: () =>
                                                    doUbahJumlah(popupOrder),
                                                child: Wgt.textLarge(context,
                                                    "${popupOrder.qty}",
                                                    align: TextAlign.end))),
                                      ]),
                                      Wgt.separator(
                                          color: Colors.grey[400], margintop: 5)
                                    ])),
                                Wgt.spaceLeft(20),
                                Expanded(
                                    flex: 1,
                                    child: Row(children: [
                                      Expanded(
                                          child: btnOutline(
                                              text: "-",
                                              radius: 0,
                                              paddingX: 25,
                                              listener: () => doChangeQty(
                                                  order: popupOrder, qty: -1))),
                                      Wgt.spaceLeft(5),
                                      Expanded(
                                          child: btnOutline(
                                              text: "+",
                                              radius: 0,
                                              paddingX: 25,
                                              listener: () => doChangeQty(
                                                  order: popupOrder, qty: 1)))
                                    ])),
                              ]),
                              // Wgt.spaceTop(40),
                              // Row(children: [
                              //   Expanded(
                              //       flex: 3,
                              //       child: Column(children: [
                              //         Row(children: [
                              //           Wgt.text(context, "Diskon"),
                              //           Wgt.spaceLeft(20),
                              //           Expanded(
                              //               child: Wgt.textLarge(
                              //                   context, "${popupOrder.disc}",
                              //                   align: TextAlign.end)),
                              //         ]),
                              //         Wgt.separator(
                              //             color: Colors.grey[400],
                              //             margintop: 5),
                              //       ])),
                              //   Wgt.spaceLeft(20),
                              //   Expanded(
                              //     flex: 1,
                              //     child: btnOutline(
                              //         text: "Tambah Diskon",
                              //         radius: 0,
                              //         listener: () => doUbahDiskon(popupOrder)),
                              //   )
                              // ]),
                              Wgt.spaceTop(40),
                              Row(children: [
                                Expanded(
                                    flex: 3,
                                    child: Column(children: [
                                      Row(children: [
                                        Wgt.text(context, "Catatan"),
                                        Wgt.spaceLeft(20),
                                        Expanded(
                                            child: Wgt.text(
                                                context, "${popupOrder.notes}",
                                                align: TextAlign.end)),
                                      ]),
                                      Wgt.separator(
                                          color: Colors.grey[400],
                                          margintop: 5),
                                    ])),
                                Wgt.spaceLeft(20),
                                Expanded(
                                    flex: 1,
                                    child: btnOutline(
                                        text: popupOrder.notes == ""
                                            ? "Tambah Catatan"
                                            : "Ubah Catatan",
                                        radius: 0,
                                        listener: () =>
                                            doUbahCatatan(popupOrder)))
                              ])
                            ]))))),
        Container(
            color: Colors.white,
            padding: EdgeInsets.all(15),
            child: Row(children: [
              Wgt.btn(context, "KEMBALI", onClick: () => doClosePopupOrder()),
              Wgt.spaceLeft(15),
              Expanded(
                  child: Wgt.btn(context, "SIMPAN",
                      color: Cons.COLOR_ACCENT,
                      onClick: () => doSimpanPopupOrder(popupOrder)))
            ]))
      ]),
      showPopupConfirmHapus
          ? Container(child: popupConfirmHapus(popupOrder))
          : Container(),
      showPopupDiskon ? Expanded(child: popupDiskon()) : Container(),
    ]);
  }

  Widget btnOutline(
      {text, color, listener, double paddingX = 15, double radius = 3}) {
    if (color == null) color = Cons.COLOR_PRIMARY;
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: listener,
            child: Container(
                padding: EdgeInsets.only(
                    left: paddingX, right: paddingX, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(radius)),
                child: Wgt.text(context, "$text",
                    maxlines: 2, color: color, align: TextAlign.center))));
  }

  /* ------------------------------- POPUP HAPUS ------------------------------ */
  bool showPopupConfirmHapus = false;
  Widget popupConfirmHapus(BOrder order) {
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.85)),
        child: Center(
          child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width / 3,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    padding: EdgeInsets.all(15),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                          onTap: () => doClosePopupRemoveOrder(),
                          child: Icon(Icons.clear, color: Colors.grey)),
                      Wgt.spaceLeft(10),
                      Wgt.text(context, "Hapus Pesanan",
                          weight: FontWeight.bold),
                      Expanded(child: Container()),
                    ])),
                Wgt.separator(),
                Container(
                    padding: EdgeInsets.all(15),
                    child: Column(children: [
                      Wgt.text(context,
                          "Hapus ${order.nameOrder} dari daftar pesanan?",
                          maxlines: 100, align: TextAlign.center),
                      Wgt.spaceTop(20),
                      Row(children: [
                        Expanded(
                            child: Wgt.btn(context, "HAPUS",
                                color: Colors.red,
                                onClick: () => doHapusOrderLakukan(order))),
                      ])
                    ]))
              ])),
        ));
  }

  /* ------------------------------ POPUP DISKON ------------------------------ */
  bool showPopupDiskon = false;
  TextEditingController edtPopupDisc = TextEditingController();
  BOrder tempOrderDisc;

  Widget popupDiskon() {
    BOrder order = tempOrderDisc; // redundant, cuma biar pendek nulisnya
    if (order == null) return Container();

    DiscType discType =
        order.discType == null ? DiscType.percentage : order.discType;
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.85)),
        child: Center(
          child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    padding: EdgeInsets.all(15),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                          onTap: () => doUbahDiskon(order),
                          child: Icon(Icons.clear, color: Colors.grey)),
                      Wgt.spaceLeft(10),
                      Wgt.text(context, "Diskon Transaksi",
                          weight: FontWeight.bold),
                      Expanded(child: Container()),
                    ])),
                Wgt.separator(),
                Container(
                    padding: EdgeInsets.all(25),
                    child: Column(children: [
                      Row(children: [
                        Wgt.text(context, "Diskon Custom"),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          padding: EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300])),
                          child: Wgt.edittext(context,
                              hint: "",
                              displayLeftHint: false,
                              displayTopHint: false,
                              type: TextInputType.number,
                              displayUnderline: false,
                              controller: edtPopupDisc),
                          // CustomInput(controller: TextEditingController()),
                        )),
                        // Container(
                        //     child: CustomInput(
                        //   bordered: false,
                        //   borderColor: Colors.grey,
                        // )),
                        selectionType(discType: discType, order: order),
                      ]),
                      Wgt.spaceTop(20),
                      Row(children: [
                        Expanded(
                            child: Wgt.btn(context, "SIMPAN",
                                color: Cons.COLOR_ACCENT,
                                onClick: () => doSaveDiskon(order: order))),
                      ])
                    ])),
              ])),
        ));
  }

  Widget selectionType({BOrder order, discType}) {
    return Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      InkWell(
          onTap: () {
            order.discType = DiscType.percentage;
            setState(() {});
          },
          child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Cons.COLOR_PRIMARY),
                  color: discType == DiscType.percentage
                      ? Cons.COLOR_PRIMARY
                      : Colors.transparent),
              height: 40,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: FittedBox(
                      child: Wgt.text(context, "%",
                          weight: FontWeight.bold,
                          color: discType == DiscType.percentage
                              ? Colors.white
                              : Cons.COLOR_PRIMARY))))),
      InkWell(
          onTap: () {
            order.discType = DiscType.nominal;
            setState(() {});
          },
          child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Cons.COLOR_PRIMARY),
                  color: discType == DiscType.nominal
                      ? Cons.COLOR_PRIMARY
                      : Colors.transparent),
              height: 40,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: FittedBox(
                      child: Wgt.text(context, "Rp.",
                          weight: FontWeight.bold,
                          color: discType == DiscType.nominal
                              ? Colors.white
                              : Cons.COLOR_PRIMARY))))),
    ]));
  }

  void doSaveDiskon({BOrder order}) {
    popupOrder.discType = order.discType;
    popupOrder.disc = num.parse(edtPopupDisc.text);

    // Tutup popup
    doUbahDiskon(order);
  }

  /* ---------------------------- PANEL POPUP KANAN --------------------------- */
  Widget panelOrderDetailsRight() {
    return Container(
        child: Column(children: [
      Expanded(child: Container()),
      Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: cellOrderDetailsRight(popupOrder)),
      Expanded(child: Container()),
    ]));
  }

  Widget cellOrderDetailsRight(BOrder order) {
    // if (order.priceTotal == 0 || order.nameOrder == null) {
    // order = doHitungTotal(order);
    // }
    var price = Helper.formatRupiah(order.product.price.toString());
    var name = order.nameOrder;

    return InkWell(
        onTap: () => clickOrderDetails(order),
        child: Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: Column(children: [
              Row(children: [
                Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        color: Cons.COLOR_ACCENT,
                        borderRadius: BorderRadius.circular(30)),
                    child: FittedBox(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wgt.textLarge(context, "${order.qty}",
                          color: Colors.white, weight: FontWeight.bold),
                    ))),
                Wgt.spaceLeft(10),
                Expanded(
                    child: Wgt.textSecondary(context, "$name",
                        color: Colors.black, weight: FontWeight.bold)),
                Wgt.spaceLeft(10),
                Wgt.textSecondary(context, "$price", color: Colors.black)
              ]),
              orderDetailsRightModifier(order),
              cellOrderDetailsRightNotes(order),
              cellOrderDetailsRightDisc(order),
            ])));
  }

  Widget cellOrderDetailsRightDisc(BOrder order) {
    if (order.disc == null) return Container();
    String disc = order.disc.toString();
    num nominal = order.disc;

    if (nominal == 0) return Container();

    if (order.discType == DiscType.nominal) {
      disc = "";
      nominal = order.disc;
    } else {
      disc = "${order.disc.toString()}%";
      nominal = order.priceTotal - (order.disc * order.priceTotal / 100);
    }

    return Container(
        margin: EdgeInsets.only(left: 50, top: 15),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.textSecondary(context, "Diskon", color: Colors.black),
          Wgt.spaceLeft(5),
          Wgt.textSecondary(context, "$disc", color: Colors.black),
          Expanded(child: Container()),
          Wgt.textSecondary(context, "${Helper.formatRupiahDouble(nominal)}",
              color: Colors.black),
        ]));
  }

  Widget cellOrderDetailsRightNotes(BOrder order) {
    if (order.notes == null || order.notes == "") return Container();
    return Container(
        margin: EdgeInsets.only(left: 50, top: 15),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.textSecondary(context, "Catatan : ", color: Colors.black),
          Wgt.spaceLeft(5),
          Wgt.textSecondary(context, "${order.notes}",
              color: Cons.COLOR_PRIMARY),
        ]));
  }

  Widget orderDetailsRightModifier(BOrder order, {double marginLeft = 50}) {
    if (order.modifiers == null) return Container();

    return ListView.builder(
        padding: EdgeInsets.only(left: marginLeft),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: order.modifiers.length,
        itemBuilder: (context, index) {
          var name = order.modifiers[index].name;
          var qty = order.modifiers[index].qty;
          var price = order.modifiers[index].price;
          var total = qty * price;
          var totalStr = Helper.formatRupiah(price.toString());
          return Container(
              child: Wgt.textSecondary(context, "+ $name @ $totalStr x $qty ",
                  color: Colors.black));
        });
  }

  /* ------------------------------- LOGIC POPUP ------------------------------ */
  void doSimpanPopupOrder(BOrder order) {
    if (order.qty <= 0) {
      doHapusOrder(order);
      return;
    }
    popupOrder = null;
    orderParent.mappingOrder[order.id] = order;
    setState(() {});
  }

  Future<void> openVarian(BOrder order) async {
    BOrder hasilOrder = await showDialog(
        context: context,
        builder: (_) => OrderPopProduct(product: order.product, order: order));

    if (hasilOrder == null) {
      // Do nothing
    } else {
      popupOrder.modifiers = hasilOrder.modifiers;
      popupOrder.variants = hasilOrder.variants;
      popupOrder.product = hasilOrder.product;
      popupOrder = doHitungTotal(popupOrder);
      // popupOrder = hasilOrder;
      setState(() {});
    }
  }

  void doHapusOrder(BOrder order) {
    showPopupConfirmHapus = !showPopupConfirmHapus;
    setState(() {});
  }

  void doHapusOrderLakukan(BOrder order) {
    popupOrder = null;
    orderParent.mappingOrder.remove(order.id);
    showPopupConfirmHapus = false;

    setState(() {});
  }

  void doChangeQty({BOrder order, qty}) {
    if (order.qty + qty <= 0) {
      doHapusOrder(order);
    } else {
      order.qty += qty;
      setState(() {});
    }
  }

  Future<void> doUbahHarga(BOrder order) async {
    if (!Order.permissions.contains("edit_product_price")) {
      Helper.toastError(
          context, "Anda tidak memiliki akses untuk merubah harga");
      return;
    }
    num priceBaru = await showDialog(
        context: context,
        builder: (_) => PopupHarga(harga: order.product.price));
    if (priceBaru != null && priceBaru >= 0) {
      order.product.price = priceBaru;
      setState(() {});
    }
  }

  Future<void> doUbahJumlah(BOrder order) async {
    num qtyBaru = await showDialog(
        context: context, builder: (_) => PopupHarga(jumlah: order.qty));
    if (qtyBaru != null && qtyBaru >= 0) {
      order.qty = qtyBaru;
      setState(() {});
    }
  }

  void doClosePopupRemoveOrder() {
    showPopupConfirmHapus = !showPopupConfirmHapus;
    setState(() {});
  }

  void doClosePopupOrder() {
    popupOrder = null;
    setState(() {});
  }

  void doUbahDiskon(BOrder order) {
    showPopupDiskon = !showPopupDiskon;
    if (showPopupDiskon) {
      tempOrderDisc = BOrder.clone(order);
      edtPopupDisc.text = order.disc.toString();
    } else {
      tempOrderDisc = null;
    }
    setState(() {});
  }

  Future doUbahCatatan(BOrder order) async {
    String notes = await showDialog(
        context: context, builder: (_) => PopupNotes(text: order.notes));
    if (notes != null) {
      order.notes = notes;
      setState(() {});
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                GENERAL LOGIC                               */
  /* -------------------------------------------------------------------------- */
  Future<void> doRefresh() async {
    mapCategory.clear();
    mapProducts.clear();
    arrSalesType.clear();
    arrPelanggan.clear();
    subscribeToken();
    // getMeja();
    // Cek dulu apakah sudah punya data di local
    bool adaisi = await SyncData.masterDataKosong();
    if (adaisi) {
      loadFromDB();
    } else {
      Helper.showProgress(context);
      await SyncData.syncMasterData(context);
      await loadFromDB();
      Helper.hideProgress(context);
    }
    // DBPawoon().getCount(tablename: DBPawoon.DB_PRODUCTS).then((value) async {
    //   if (value > 0) {
    //     // Load dari db
    //   } else {
    //     loadFromWebservice();
    //   }
    // });
  }

  loadFromDB() async {
    mapCategory.clear();
    mapProducts.clear();
    List<Future> arrFut = List();
    var valPosition;
    var valProducts;
    var valFavorite;
    var valTax;
    var valSalesType;
    var valCustomer;
    var valVariants;
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_PRODUCTS)
        .then((value) => valProducts = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_PRODUCT_FAVORITE)
        .then((value) => valFavorite = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_CUSTOM_PRODUCT_POSITION)
        .then((value) => valPosition = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_TAX_SERVICES)
        .then((value) => valTax = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_SALES_TYPE)
        .then((value) => valSalesType = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_CUSTOMERS)
        .then((value) => valCustomer = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_PRODUCT_VARIANTS)
        .then((value) => valVariants = value));

    await Future.wait(arrFut);
    // getCustomer();
    doProcessFromDB(
        valProducts: valProducts,
        valFavorite: valFavorite,
        valPosition: valPosition,
        valTax: valTax,
        valSalesType: valSalesType,
        valCustomer: valCustomer,
        valVariants: valVariants);

    doStopRefresh();
    pasangDefaultValues();
  }

  void doProcessFromDB(
      {valProducts,
      valFavorite,
      valPosition,
      valTax,
      valSalesType,
      valCustomer,
      valVariants}) {
    List<String> arrIdFav = List();
    // Load favourites
    if (valFavorite != null) {
      for (Map val in valFavorite) {
        arrIdFav.add(val["favorite_product_id"]);
      }
    }

    // Load products
    for (Map mapProd in valProducts) {
      BProduct prod = BProduct.fromMap(json.decode(mapProd["data_json"]));
      prod.isFav = arrIdFav.contains(prod.id);

      if (mapProducts["all"] == null) mapProducts["all"] = List();
      mapProducts["all"].add(prod);

      if (prod.category != null) {
        var category = prod.category.id;
        if (mapProducts["$category"] == null) mapProducts["$category"] = List();

        mapProducts["$category"].add(prod);
        mapCategory["$category"] = prod.category.name;
      }

      var sortedKeys = mapCategory.keys.toList(growable: false)
        ..sort((k1, k2) => mapCategory[k1].compareTo(mapCategory[k2]));
      LinkedHashMap<String, String> sortedMap = new LinkedHashMap.fromIterable(
          sortedKeys,
          key: (k) => k,
          value: (k) => mapCategory[k]);
      mapCategory = sortedMap;

      if (prod.isFav) {
        if (mapProducts == null) mapProducts = Map();
        if (mapProducts["fav"] == null) mapProducts["fav"] = List();
        mapProducts["fav"].add(prod);
      }
    }

    // Sort product custom
    for (var pos in valPosition) {
      String cat = pos["category_custom_product"];
      // print("cat : $cat");

      // Ambil type tampilan
      // mapTampilan[cat] = pos["tampilan"];

      String urutanStr = pos["product_order"];
      // print("urutan : $urutanStr");
      List<String> urutan = urutanStr.split(",");

      List<BProduct> arrProdBaru = List();

      if (cat == "all" && urutanStr == "") arrProdBaru.addAll(mapProducts[cat]);

      for (String prodid in urutan) {
        for (BProduct prod in mapProducts[cat]) {
          if (cat != prod.category.id && cat != "all" && cat != "fav") continue;
          if (prod.id == prodid) {
            arrProdBaru.add(prod);
            break;
          }
        }
      }

      if (arrProdBaru.isNotEmpty) mapProducts[cat] = arrProdBaru;
      // else if (arrProdBaru.isEmpty && cat == "all")
    }

    // Tax & services
    for (var taxRaw in valTax) {
      BTax tax = BTax.fromMap((taxRaw));
      orderParent.mappingTaxServices["${tax.type}"] = tax;
    }

    // Sales type
    arrSalesType.clear();
    for (var typeRaw in valSalesType) {
      BSalesType type = BSalesType.fromMap(typeRaw);
      if (type.mode == "manual" && type.name != "Dicicil")
        arrSalesType.add(type);
    }

    // Customer
    for (var customerRaw in valCustomer) {
      BPelanggan cs = BPelanggan.fromMap(customerRaw);
      arrPelanggan.add(cs);
    }

    // Variants
    variantData.clear();
    for (var varian in valVariants) {
      // print(varian);
      BVariantDetails v = BVariantDetails.fromMap(varian);
      // print(v.parent_id);
      variantData.add(v);
    }
    mappingVariantsToProduct();

    // Pasang datanya ke filtered
    doSearch();
  }

  Future doUpdateData() async {
    // Refresh ui aja cukup, di build function sudah di cek, untuk refresh the whole data
    // setState(() {});

    if (SyncData.newData) {
      SyncData.newData = false;
      reloadHalaman();
    }
  }

  Future<void> loadFromWebservice({doUpdate = false}) async {
    // Ambil dari database
    List<Future> arrFut = List();
    arrFut.add(getProducts(doUpdate: doUpdate));
    arrFut.add(getTax());
    arrFut.add(getTierOutlet());
    arrFut.add(getCustomer());
    arrFut.add(getCompanyDetails());
    arrFut.add(getVariants());
    arrFut.add(getCustomAmount());
    arrFut.add(subscribeToken());
    arrFut.add(getBilling());

    await Future.wait(arrFut);
    await getSalesType();

    pasangDefaultValues();
  }

  void displayHighlightTutorial() {
    UserManager.getBool(UserManager.DISPLAY_TUTORIAL).then((value) {
      if (value == null || value) {
        Timer(Duration(seconds: 1), () {
          Helper.highlightOverlay1(context, listenerClose: () {
            UserManager.saveBool(UserManager.DISPLAY_TUTORIAL, false);

            if (arrSalesType == null || arrSalesType.isEmpty) return;
            Timer(Duration(milliseconds: 50), () {
              Helper.highlightOverlay2(context, name: orderParent.op.name);
            });
          });
        });
      }
    });
  }

  void displayHighlightTutorialBayar() {
    if (orderParent.mappingOrder.isEmpty &&
        (orderParent.customAmount == null ||
            orderParent.customAmount.total <= 0)) return;
    UserManager.getBool(UserManager.DISPLAY_TUTORIAL_BAYAR_1)
        .then((value) async {
      await UserManager.saveBool(UserManager.DISPLAY_TUTORIAL_BAYAR_1, false);
      if (value == false) return;
      Timer(Duration(milliseconds: 50), () async {
        Helper.highlightOverlayBayar(context,
            name: orderParent.op.name, listenerClose: () async {});
      });
    });
  }

  Future<void> doSaveData() async {
    List<Future> arrFut = List();
    arrFut.add(DBPawoon().insertProduct(mapProducts));

    return Future.wait(arrFut);
  }

  void doStopRefresh() {
    loader.isLoading = false;
    pullToRefresh.stopRefresh();
    setState(() {});

    displayHighlightTutorial();
  }

  Future getCompanyDetails() {
    return Logic(context).companyDetails(
        outletid: outletid,
        success: (j) {
          if (orderParent != null && orderParent.outlet != null) {
            orderParent.outlet.company = BCompany.fromJson(j["data"]);

            UserManager.saveString(
                UserManager.OUTLET_ID, orderParent.outlet.id);
            UserManager.saveString(UserManager.OUTLET_OBJ,
                json.encode(orderParent.outlet.saveObject()));
          }
        });
  }

  Future getCustomAmount() {
    return Logic(context).customAmount(
        outletid: outletid,
        success: (j) async {
          if (j["data"] != null) {
            for (var item in j["data"]) {
              BCustomAmount amt = BCustomAmount.fromJson(item);
              await UserManager.saveString(UserManager.CUSTOM_AMOUNT_OBJ,
                  json.encode(amt.toObjectLocal()));
              String textCustomAmount =
                  await UserManager.getString(UserManager.CUSTOM_AMOUNT_OBJ);
              if (textCustomAmount != null && textCustomAmount != "")
                orderParent.customAmount =
                    BCustomAmount.fromJson(json.decode(textCustomAmount));
            }
          }
        });
  }

  Future subscribeToken() async {
    if (await Helper.hasInternet()) {
      String token = await Helper.firebaseMessaging.getToken();
      return Logic(context).subscribeToken(
          deviceid: orderParent.device.id,
          assignid: Logic.ASSIGNMENT_TOKEN,
          token: token,
          success: (json) {});
    }
  }

  Future getProducts({doUpdate = false}) {
    return Logic(context).products(
        outletid: outletid,
        page: page,
        success: (json) async {
          for (var item in json["data"]) {
            // Clipboard.setData(ClipboardData(text: "${item}"));
            // break;
            BProduct prod = BProduct.fromJson(item);
            if (prod.category == null) continue;
            if (mapProducts[prod.category.id] == null)
              mapProducts[prod.category.id] = List();

            if (mapProducts["all"] == null) mapProducts["all"] = List();
            mapProducts["all"].add(prod);

            mapProducts[prod.category.id].add(prod);
            mapCategory[prod.category.id] = prod.category.name;

            DBPawoon().insertOrUpdate(
                tablename: DBPawoon.DB_PRODUCTS, data: prod.toDb());
          }
          if (json["meta"] != null) {
            var count = json["meta"]["count"];
            var per_page = json["meta"]["per_page"];
            if (count == per_page) {
              page++;
              getProducts(doUpdate: doUpdate);
            } else {
              // Di sort by values
              var sortedEntries = mapCategory.entries.toList()
                ..sort((e1, e2) {
                  var diff = e1.value.compareTo(e2.value);
                  if (diff == 0) diff = e1.key.compareTo(e2.key);
                  return diff;
                });
              mapCategory = Map<String, String>.fromEntries(sortedEntries);

              // if (!doUpdate) {
              //   await doSaveData();
              // } else {
              //   await DBPawoon().updateProduct(mapProducts).then((value) {
              //     // doStopRefresh();
              //     // doSearch();
              //   });
              // }
              // doStopRefresh();
              // doSearch();
            }
          }

          drawer.mapCategory = mapCategory;
          drawer.mapProducts = mapProducts;
        });
  }

  List<BVariantDetails> variantData = List();
  Future getVariants({doUpdate = false}) {
    return Logic(context).variants(
        outletid: outletid,
        page: pageVariant,
        success: (json) async {
          for (var item in json["data"]) {
            BVariantDetails prod = BVariantDetails.fromJson(item);
            variantData.add(prod);
            // mapVariants[prod.name] = prod;
            DBPawoon().insertOrUpdate(
                tablename: DBPawoon.DB_PRODUCT_VARIANTS, data: prod.toMap());
          }

          if (json["meta"] != null) {
            var count = json["meta"]["count"];
            var per_page = json["meta"]["per_page"];
            if (count == per_page) {
              pageVariant++;
              getVariants(doUpdate: doUpdate);
            } else {
              mappingVariantsToProduct();
            }
          }
        });
  }

  void mappingVariantsToProduct() {
    // Masukin masing2 variant ke dalem product
    // Variants
    if (variantData != null)
      for (var variant in variantData) {
        if (mapProducts["all"] != null)
          for (BProduct p in mapProducts["all"]) {
            if (p.id == variant.parent_id) {
              if (p.variantdetails == null) p.variantdetails = List();
              p.variantdetails.add(variant);
            }
          }
      }

    // if (mapProducts["all"] == null)
    //   for (BProduct p in mapProducts["all"]) {
    //     DBPawoon().update(tablename: DBPawoon.DB_PRODUCTS, data: p.toDb());
    //   }
  }

  Future getTax() {
    return Logic(context).tax(
        outlet: outletid,
        success: (json) {
          orderParent.mappingTaxServices.clear();
          if (json["data"] != null &&
              json["data"]["taxes_and_services"] != null &&
              json["data"]["taxes_and_services"]["data"] != null) {
            for (var item in json["data"]["taxes_and_services"]["data"]) {
              BTax tax = BTax.fromJson(item);
              var key = tax.type;
              // var value = tax.percentage;
              orderParent.mappingTaxServices[key] = tax;
              DBPawoon().insertOrUpdate(
                  tablename: DBPawoon.DB_TAX_SERVICES, data: tax.toMap());
            }
          }
          setState(() {});
        });
  }

  Future getTierOutlet() {
    return Logic(context).tierOutlet(success: (json) {});
  }

  Future getSalesType() async {
    var outletstr = await UserManager.getString(UserManager.OUTLET_OBJ);
    BOutlet o;
    if (outletstr != null && outletstr != "")
      o = BOutlet.parseObject(json.decode(outletstr));
    String companyid;
    if (o != null && o.company != null) companyid = o.company.id;
    return Logic(context).salesType(
        companyid: companyid ?? "",
        success: (json) {
          arrSalesType.clear();
          for (var item in json["data"]) {
            BSalesType type = BSalesType.fromJson(item);
            DBPawoon().insertOrUpdate(
                tablename: DBPawoon.DB_SALES_TYPE, data: type.toMap());

            if (type.mode == "manual") arrSalesType.add(type);
          }
        });
  }

  Future getCustomer() {
    return Logic(context).customer(success: (json) {
      for (var data in json["data"]) {
        BPelanggan customer = BPelanggan.fromJson(data);
        arrPelanggan.add(customer);
        DBPawoon().insertOrUpdate(
            tablename: DBPawoon.DB_CUSTOMERS, data: customer.toMap());
      }
    });
  }

  Future getCustomerLastUpdate() {
    return Logic(context).customerLastUpdate(success: (json) {
      // for (var data in json["data"]){
      //   print(data);
      // }
    });
  }

  Future getMeja() {
    return Logic(context).meja(
        outletid: outletid,
        success: (json) {
          if (json["data"] != null)
            for (var item in json["data"]) {
              BMeja meja = BMeja.fromJson(item);
              DBPawoon().insertOrUpdate(
                  tablename: DBPawoon.DB_TABLES,
                  data: meja.toMap(),
                  id: "uuid");
            }
        });
  }

  Future getBilling() {
    return Logic(context).billing(success: (j) {
      // print("data:$j");
      if (j["billing"]["data"] != null) {
        UserManager.saveString(
            UserManager.BILLING_OBJ, json.encode(j["billing"]["data"]));
        billings = BBillings.fromJson((j["billing"]["data"]));
        checkBillingExpired();
      }
    });
  }

  void checkBillingExpired() {
    if (billings == null) {
      return;
    }
    // if (billings.)
    print("helo?");
    if (billings.subscription_type == "trial") {
      var date1 = DateTime.now();
      var date2 = Helper.parseDate(dateString: billings.trial_end_date);
      var difference = date2.difference(date1).inDays + 1;
      if (difference >= 1 && difference <= 14) {
        Helper.popupDialog(context,
            title: "Info",
            text: "Masa trial akan berakhir $difference hari lagi");
      }
    }

    // print("billing:${billings.tier}");
    // print("billing:${billings.subscription_type}");
    // print("billing:${billings.trial_end_date}");
    // print("billing:${billings.upgrade_link}");
  }

/* -------------------------------------------------------------------------- */
/*                             DRAWER RIGHT CLICK                             */
/* -------------------------------------------------------------------------- */
  void doClickDrawerRight(tag) {
    switch (tag) {
      case DrawerRightClick.diskon:
        break;

      case DrawerRightClick.pelanggan:
        doPopupNama();
        break;

      case DrawerRightClick.promo:
        break;

      case DrawerRightClick.cancel:
        doCancelOrder();
        break;
    }
  }

  Future<void> doPopupNama() async {
    var balikan = await showDialog(
        context: context,
        builder: (_) => PopupNama(nama: orderParent.pelanggan.name));
    if (balikan != null && balikan["nama"] != null) {
      orderParent.pelanggan.name = balikan["nama"];
    }
  }

  void doCancelOrder() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 5,
            child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  JudulPopup(title: "Batalkan Transaksi"),
                  Wgt.separator(),
                  Container(
                      padding: EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Wgt.text(
                            context, "Yakin ingin membatalkan transaksi ini?",
                            align: TextAlign.center, maxlines: 5),
                        Wgt.spaceTop(20),
                        Row(children: [
                          Expanded(
                              child: Wgt.btn(context, "BATALKAN TRANSAKSI",
                                  onClick: () {
                            if (orderParent.id != null &&
                                orderParent.id != "") {
                              DBPawoon().delete(
                                  tablename: DBPawoon.DB_ORDERS,
                                  id: "id",
                                  data: {"id": "${orderParent.id}"});
                            }
                            doResetOrder();
                            Helper.closePage(context);
                            setState(() {});
                          }, color: Colors.red))
                        ]),
                      ]))
                ]))));
    // Helper.confirm(
    //     context, "Batalkan Transaksi", "Yakin ingin membatalkan transaksi ini?",
    //     () {
    // }, () {});
  }

  Future<void> doResetOrder() async {
    orderParent = BOrderParent();
    orderParent.pelanggan = BPelanggan();
    orderParent.mappingOrder = Map();
    orderParent.payment.clear();
    orderParent.payment.add(BPayment.cash());
    orderParent.id = await DBPawoon().getLocalID();

    await UserManager.getBool(UserManager.SETTING_STOK).then((value) {
      Order.displayStock = value ?? false;
    });
    activeSearch = false;
    activeScan = false;
    await doLengkapiParentOrder();
    doResetDrawer();
  }

  Future doLengkapiParentOrder({overrideCustomAmount = true}) async {
    List<Future> arrFut = List();
    arrFut.add(loadData(overrideCustomAmount: overrideCustomAmount));
    arrFut.add(doLoadLocation());
    arrFut.add(doGetDeviceDetails());
    arrFut.add(doGetAngkaTersimpan());

    if (overrideCustomAmount) {
      String textCustomAmount =
          await UserManager.getString(UserManager.CUSTOM_AMOUNT_OBJ);
      if (textCustomAmount != null && textCustomAmount != "")
        orderParent.customAmount =
            BCustomAmount.fromJson(json.decode(textCustomAmount));
    }

    return Future.wait(arrFut);
  }

  void doResetDrawer() {
    drawerRight = DrawerRight(
        listenerClick: (tag) => doClickDrawerRight(tag),
        orderParent: orderParent);
    drawer = DrawerLeft(
        listenerUpdateData: () => doUpdateData(),
        listenerOpenSetting: () => doOpenSetting(),
        listenerUpgrade: () => doUpgrade(),
        listenerOpenRekap: () => doOpenRekap());
  }

  void pasangDefaultValues() {
    if (orderParent.salestype.name == null || orderParent.salestype.name == "")
      // if (orderParent.id == null)
      for (BSalesType sales in arrSalesType) {
        if (sales.deleted == 0) {
          orderParent.salestype = sales;
          break;
        }
      }
    setState(() {});
  }

  Future<void> doLoadLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    Geolocator.getCurrentPosition().then((value) {
      orderParent.latitude = value.latitude;
      orderParent.longitude = value.longitude;
    });
  }

  Future<void> doGetDeviceDetails() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;

      orderParent.app_version = "";
      orderParent.manufacturer = "$systemName";
      orderParent.model = "$model";
      orderParent.os_version = "$version";
    }
  }

  void activateScheduler() {
    SyncData.schedulerTransactionStart(context);
    SyncData.schedulerMasterDataStart(context);
  }
}
