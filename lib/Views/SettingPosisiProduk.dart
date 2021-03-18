import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BOrder.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBHelper.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import 'MyApp.dart';

class SettingPosisiProduk extends StatefulWidget {
  SettingPosisiProduk();

  @override
  _SettingPosisiProdukState createState() => _SettingPosisiProdukState();
}

class _SettingPosisiProdukState extends State<SettingPosisiProduk> {
  Map<String, List<BProduct>> mapProducts = Map();
  Map<String, String> mapCategory = Map();
  Map<String, String> mapSort = Map();
  // Tampilan ada "kotak","daftar"
  // Map<String, String> mapTampilan = Map();
  String settingTampilan = "kotak";

  String categoryActive = "all";
  Map<String, String> mapUrutkan = Map();
  Dropdown2 ddUrutkan;
  List _imageUris;

  @override
  void initState() {
    super.initState();
    mapUrutkan = {
      "1": "Abjad (A-Z)",
      "2": "Abjad (Z-A)",
      "3": "Produk Baru - Produk Lama",
      "4": "Produk Lama - Produk Baru",
      "5": "Custom",
    };

    initDropdownSort();
    _imageUris = mapProducts[categoryActive];
    doSort();
    doLoadFromDB();
  }

  void initDropdownSort() {
    if (mapSort[categoryActive] == null) mapSort[categoryActive] = "1";
    ddUrutkan = Dropdown2(
        list: mapUrutkan,
        showUnderline: false,
        textColor: Cons.COLOR_PRIMARY,
        onValueChanged: () {
          mapSort[categoryActive] = ddUrutkan.selected;
          doSort();
          doSavePositions();
          setState(() {});
        },
        selected: mapSort[categoryActive]);
  }

  void doSort() {
    if (mapProducts == null || mapProducts[categoryActive] == null) return;
    // Kalau custom jangan di urutkan lagi
    if (ddUrutkan.selected == "5") return;
    mapProducts[categoryActive].sort((prod1, prod2) {
      switch (ddUrutkan.selected) {
        case "1":
          return prod1.name
              .toString()
              .toLowerCase()
              .compareTo(prod2.name.toString().toLowerCase());
        case "2":
          return prod2.name
              .toString()
              .toLowerCase()
              .compareTo(prod1.name.toString().toLowerCase());
        case "3":
          return prod1.name
              .toString()
              .toLowerCase()
              .compareTo(prod2.name.toString().toLowerCase());
        case "4":
          return prod2.name
              .toString()
              .toLowerCase()
              .compareTo(prod1.name.toString().toLowerCase());
      }
      return 0;
    });

    doSavePositions();
    setState(() {});
  }

  Future<void> doLoadFromDB() async {
    List<Future> arrFut = List();
    var valProducts;
    var valFavorite;
    var valPosition;
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_PRODUCTS)
        .then((value) => valProducts = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_PRODUCT_FAVORITE)
        .then((value) => valFavorite = value));
    arrFut.add(DBPawoon()
        .select(tablename: DBPawoon.DB_CUSTOM_PRODUCT_POSITION)
        .then((value) => valPosition = value));
    arrFut
        .add(UserManager.getString(UserManager.SETTING_TAMPILAN).then((value) {
      if (value != null)
        settingTampilan = value;
      else
        settingTampilan = "kotak";
    }));

    await Future.wait(arrFut);
    doProcessFromDB(
        valProducts: valProducts,
        valFavorite: valFavorite,
        valPosition: valPosition);
  }

  void doProcessFromDB({valProducts, valFavorite, valPosition}) {
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
      // Ambil type sort
      mapSort[cat] = pos["sortby"];

      // Ambil type tampilan
      // mapTampilan[cat] = pos["tampilan"];

      // Urutkan product
      String urutanStr = pos["product_order"];
      List<String> urutan = urutanStr.split(",");

      List<BProduct> arrProdBaru = List();
      for (String prodid in urutan) {
        for (BProduct prod in mapProducts[cat]) {
          if (prod.id == prodid) {
            arrProdBaru.add(prod);
            break;
          }
        }
      }

      mapProducts[cat] = arrProdBaru;
    }

    initDropdownSort();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 1, child: panelCategory()),
      Expanded(flex: 3, child: panelKanan()),
    ]));
  }

// ic_favorite_off.png
// ic_favorite_on.png
// ic_grid_drag.png
// ic_group_order.png
// ic_mode_grid_big_white.png
// ic_mode_list_big_white.png
  Widget panelKanan() {
    return Container(
        padding: EdgeInsets.only(top: 20, right: 20),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: tampilan(
                    text: "Tampilan Kotak",
                    tag: "kotak",
                    icon: "ic_mode_grid_big_white.png")),
            Wgt.spaceLeft(20),
            Expanded(
                child: tampilan(
                    text: "Tampilan Daftar",
                    tag: "daftar",
                    icon: "ic_mode_list_big_white.png")),
          ]),
          Expanded(child: items()),
          panelUrutkan(),
        ]));
  }

  Widget panelUrutkan() {
    if (mapProducts[categoryActive] == null ||
        mapProducts[categoryActive].isEmpty) return Container();
    return Container(
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
        color: Color(0xffeaf8f9),
        child: Row(children: [
          Wgt.text(context, "Urutkan kategori ini berdasarkan"),
          Wgt.spaceLeft(10),
          Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Cons.COLOR_PRIMARY)),
                  child: ddUrutkan)),
        ]));
  }

  Widget tampilan({String tag, text, icon}) {
    if (icon == null) icon = Container();
    // if (mapTampilan[categoryActive] == null)
    //   mapTampilan[categoryActive] = "kotak";
    bool active = tag == settingTampilan;
    return Material(
        color: active ? Cons.COLOR_PRIMARY : Colors.white,
        child: InkWell(
            onTap: () => doGantiTampilan(tag),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Cons.COLOR_PRIMARY)),
                padding: EdgeInsets.all(20),
                child: Row(children: [
                  Image.asset("assets/$icon",
                      height: 20,
                      color: active ? Colors.white : Cons.COLOR_PRIMARY),
                  Wgt.spaceLeft(10),
                  Expanded(
                      child: Wgt.text(context, "$text",
                          color: active ? Colors.white : Cons.COLOR_PRIMARY)),
                ]))));
  }

  Future<void> doGantiTampilan(tag) async {
    // mapTampilan[categoryActive] = tag;
    // mapProducts.forEach((key, value) {
    //   mapTampilan[key] = tag;
    // });

    settingTampilan = tag;
    await UserManager.saveString(UserManager.SETTING_TAMPILAN, tag);
    variableSet = 0;
    // doSavePositions();
    setState(() {});
  }

  ScrollController _scrollController;

  num pos;
  Widget items() {
    if (mapProducts == null || mapProducts[categoryActive] == null)
      return Container();
    if (categoryActive == "fav" &&
        (mapProducts[categoryActive] == null ||
            mapProducts[categoryActive].isEmpty)) return panelFavouriteKosong();
    // if (mapTampilan[categoryActive] == null)
    //   mapTampilan[categoryActive] = "kotak";
    if (mapSort[categoryActive] == null) mapSort[categoryActive] = "1";

    String tampilanActive = settingTampilan;
    String urutanActive = mapSort[categoryActive];
    return Container(
        child: DragAndDropGridView(
            controller: _scrollController,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            isCustomChildWhenDragging: false,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: tampilanActive == "kotak" ? 0.8 : 7.0,
                crossAxisCount: tampilanActive == "kotak" ? 4 : 1,
                crossAxisSpacing: tampilanActive == "kotak" ? 5 : 0,
                mainAxisSpacing: tampilanActive == "kotak" ? 5 : 0),
            // Waktu mau di drop
            onWillAccept: (oldIndex, newIndex) {
              if (urutanActive != "5") return false;
              _imageUris = [...mapProducts[categoryActive]];
              int indexOfFirstItem = _imageUris.indexOf(_imageUris[oldIndex]);
              int indexOfSecondItem = _imageUris.indexOf(_imageUris[newIndex]);

              if (indexOfFirstItem > indexOfSecondItem) {
                for (int i = _imageUris.indexOf(_imageUris[oldIndex]);
                    i > _imageUris.indexOf(_imageUris[newIndex]);
                    i--) {
                  var tmp = _imageUris[i - 1];
                  _imageUris[i - 1] = _imageUris[i];
                  _imageUris[i] = tmp;
                }
              } else {
                for (int i = _imageUris.indexOf(_imageUris[oldIndex]);
                    i < _imageUris.indexOf(_imageUris[newIndex]);
                    i++) {
                  var tmp = _imageUris[i + 1];
                  _imageUris[i + 1] = _imageUris[i];
                  _imageUris[i] = tmp;
                }
              }

              setState(() {
                pos = newIndex;
              });
              return true;
            },
            // Setelah di drop
            onReorder: (oldIndex, newIndex) {
              _imageUris = [...mapProducts[categoryActive]];
              int indexOfFirstItem = _imageUris.indexOf(_imageUris[oldIndex]);
              int indexOfSecondItem = _imageUris.indexOf(_imageUris[newIndex]);

              if (indexOfFirstItem > indexOfSecondItem) {
                for (int i = _imageUris.indexOf(_imageUris[oldIndex]);
                    i > _imageUris.indexOf(_imageUris[newIndex]);
                    i--) {
                  var tmp = _imageUris[i - 1];
                  _imageUris[i - 1] = _imageUris[i];
                  _imageUris[i] = tmp;
                }
              } else {
                for (int i = _imageUris.indexOf(_imageUris[oldIndex]);
                    i < _imageUris.indexOf(_imageUris[newIndex]);
                    i++) {
                  var tmp = _imageUris[i + 1];
                  _imageUris[i + 1] = _imageUris[i];
                  _imageUris[i] = tmp;
                }
              }
              mapProducts[categoryActive] = [..._imageUris];
              setState(() {
                pos = null;
              });
              doSavePositions();
            },
            itemCount: mapProducts[categoryActive].length,
            itemBuilder: (context, index) {
              return tampilanActive == "kotak"
                  ? cellItemGrid(
                      index: index, item: mapProducts[categoryActive][index])
                  : cellItemList(
                      index: index, item: mapProducts[categoryActive][index]);
            }));
  }

  Widget cellItemGrid({index, BProduct item}) {
    String favName = "ic_favorite_off.png";
    if (item.isFav) favName = "ic_favorite_on.png";
    String urutanActive = mapSort[categoryActive];
    return Opacity(
        opacity: pos != null
            ? pos == index
                ? 0.3
                : 1
            : 1,
        child: GridTile(
            child: Card(
                elevation: 1.5,
                child: Container(
                    color: Colors.white,
                    child: LayoutBuilder(builder: (context, costrains) {
                      if (variableSet == 0) {
                        height = costrains.maxHeight;
                        width = costrains.maxWidth;
                        variableSet++;
                      }
                      return SizedBox(
                          width: width,
                          height: height,
                          child: Stack(children: [
                            Column(children: [
                              AspectRatio(
                                  aspectRatio: 1,
                                  child: (item.img == null || item.img == "")
                                      ? Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: Colors.purple),
                                          child: FittedBox(
                                              child: Wgt.textLarge(
                                                  context,
                                                  doGetInitials(item.name)
                                                      .toUpperCase(),
                                                  color: Colors.white,
                                                  weight: FontWeight.bold)))
                                      : Wgt.image(url: item.img)),
                              Expanded(
                                  child: Center(
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Wgt.textSecondary(
                                              context, "${item.name}",
                                              color: Colors.black,
                                              maxlines: 1)))),
                            ]),
                            Positioned(
                                right: 5,
                                top: 5,
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: () => doToggleFav(item: item),
                                        child: Image.asset("assets/$favName",
                                            height: 50)))),
                            urutanActive == "5"
                                ? Positioned(
                                    left: 5,
                                    top: 5,
                                    child: Image.asset(
                                        "assets/ic_grid_drag.png",
                                        height: 50))
                                : Container(),
                          ]));
                    })))));
  }

  Widget cellItemList({index, BProduct item}) {
    String urutanActive = mapSort[categoryActive];
    return Opacity(
        opacity: pos != null
            ? pos == index
                ? 0.3
                : 1
            : 1,
        child: GridTile(
            child: Container(
                color: Colors.white,
                child: LayoutBuilder(builder: (context, costrains) {
                  if (variableSet == 0) {
                    height = costrains.maxHeight;
                    width = costrains.maxWidth;
                    variableSet++;
                  }
                  return SizedBox(
                      height: height,
                      width: width,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Row(children: [
                          Container(
                              margin: EdgeInsets.all(10),
                              height: 60,
                              child: AspectRatio(
                                  aspectRatio: 1,
                                  child: (item.img == null || item.img == "")
                                      ? Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: Colors.purple),
                                          child: FittedBox(
                                              child: Wgt.textLarge(
                                                  context,
                                                  doGetInitials(item.name)
                                                      .toUpperCase(),
                                                  color: Colors.white,
                                                  weight: FontWeight.bold)),
                                        )
                                      : Wgt.image(url: item.img))),
                          Expanded(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Wgt.text(context, "${item.name}"),
                                Wgt.spaceTop(3),
                                Wgt.textSecondary(context,
                                    "${Helper.formatRupiah(item.price.toString())}",
                                    color: Colors.black)
                              ])),
                          Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () => doToggleFav(item: item),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: item.isFav
                                          ? Icon(Icons.star,
                                              size: 35, color: Colors.amber)
                                          : Icon(Icons.star_border,
                                              size: 35, color: Colors.grey)))),
                          urutanActive == "5"
                              ? Image.asset("assets/ic_group_order.png",
                                  height: 50)
                              : Container()
                        ]),
                        Wgt.separator()
                      ]));
                }))));
  }

  int variableSet = 0;
  double width;
  double height;

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

  Future<void> doToggleFav({BProduct item}) async {
    item.isFav = !item.isFav;
    if (mapProducts["fav"] == null) mapProducts["fav"] = List();

    if (item.isFav) {
      mapProducts["fav"].add(item);
      await DBPawoon().insert(
          tablename: DBPawoon.DB_PRODUCT_FAVORITE,
          data: {"favorite_product_id": "${item.id}"});
    } else {
      mapProducts["fav"].remove(item);
      await DBPawoon().delete(
          tablename: DBPawoon.DB_PRODUCT_FAVORITE,
          data: {"favorite_product_id": "${item.id}"},
          id: "favorite_product_id");
    }

    setState(() {});
  }

  Future<void> doSavePositions() async {
    if (mapProducts == null || mapProducts[categoryActive] == null) {
      return;
    }

    List<BProduct> list = mapProducts[categoryActive];
    List<String> arrOrders = List();
    for (BProduct prod in list) {
      arrOrders.add(prod.id);
    }

    if (mapSort[categoryActive] == null) mapSort[categoryActive] = "1";
    // if (mapTampilan[categoryActive] == null)
    //   mapTampilan[categoryActive] = "kotak";

    List<Future> arrFut = List();
    // for (var item in mapProducts[categoryActive]) {
    arrFut.add(DBPawoon().insertOrUpdate(
        tablename: DBPawoon.DB_CUSTOM_PRODUCT_POSITION,
        id: "category_custom_product",
        data: {
          "category_custom_product": categoryActive,
          "sortby": "${mapSort[categoryActive]}",
          // "tampilan": "${mapTampilan[categoryActive]}",
          "product_order": "${arrOrders.join(',')}"
        }));
    // }
    // mapProducts.forEach((key, value) {
    //   arrFut.add(DBPawoon().insertOrUpdate(
    //       tablename: DBPawoon.DB_CUSTOM_PRODUCT_POSITION,
    //       id: "category_custom_product",
    //       data: {
    //         "category_custom_product": key,
    //         "sortby": "${mapSort[key]}",
    //         // "tampilan": "${mapTampilan[categoryActive]}",
    //         "product_order": "${arrOrders.join(',')}"
    //       }).then((value) => print("$value")));
    // });

    await Future.wait(arrFut);
  }

/* -------------------------------------------------------------------------- */
/*                                   CATEGORY                                 */
/* -------------------------------------------------------------------------- */
  Widget panelCategory() {
    if (mapCategory == null) mapCategory = Map();
    return Container(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200])),
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
                  ]))
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
                  child: Wgt.text(context, "$name",
                      maxlines: 2,
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
              Wgt.text(context, "Favorit",
                  color: isactive ? Colors.white : Colors.black),
              Wgt.spaceLeft(10),
              Icon(Icons.star, color: Colors.amber),
            ])));
  }

  void doCategoryClick(id) {
    categoryActive = id;
    _imageUris = mapProducts[categoryActive];
    initDropdownSort();
    setState(() {});
    // Helper.openPageNoNav(context, MyApp());
  }

/* -------------------------------------------------------------------------- */
/*                                  FAVORITE                                  */
/* -------------------------------------------------------------------------- */
  Widget panelFavouriteKosong() {
    return Container(
        margin: EdgeInsets.only(bottom: 20, top: 20),
        color: Colors.grey[100],
        child: Column(children: [
          Row(),
          Expanded(child: Container()),
          Icon(Icons.star_rounded, color: Colors.grey[300], size: 50),
          Wgt.spaceTop(10),
          Wgt.text(context, "Anda belum memilih produk favorit"),
          Expanded(child: Container()),
        ]));
  }
}

enum Urutkan {
  asc,
  desc,
  prodNew,
  prodOld,
  custom,
}
