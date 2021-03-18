import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BCustomAmount.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BSalesType.dart';
import 'package:pawoon/Bean/BVariant.dart';
import 'package:pawoon/Bean/BVariantData.dart';
import 'package:pawoon/Bean/BModifier.dart';
import 'package:pawoon/Bean/BModifierData.dart';
import 'package:pawoon/Bean/BOrder.dart';
import 'package:pawoon/Bean/BProduct.dart';
import 'package:pawoon/Bean/BVariantDetails.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Enums.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/RekapPopup.dart';

import '../main.dart';

class OrderPopProduct extends StatefulWidget {
  BProduct product;
  BOrder order;
  Map<String, BVariantDetails> mapVariant = Map();
  OrderPopProduct({product, order, this.mapVariant}) {
    if (product != null) this.product = BProduct.clone(product);
    if (order != null) this.order = BOrder.clone(order);
  }

  @override
  _OrderPopProductState createState() => _OrderPopProductState();
}

class _OrderPopProductState extends State<OrderPopProduct>
    with TickerProviderStateMixin {
  bool btnSimpanEnable = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null && widget.product.has_variant)
      widget.product.has_variant = widget.product.variant.isNotEmpty;
    if (widget.product != null && widget.product.has_modifier)
      widget.product.has_modifier = widget.product.modifiers.isNotEmpty;
    if (!widget.product.has_variant) btnSimpanEnable = true;

    doResetQtyProduct();
    doCekPerluPopup();
  }

  void doResetQtyProduct() {
    for (BModifier mod in widget.product.modifiers) {
      for (BModifierData data in mod.modifiers) {
        data.qty = 0;
      }
    }

    if (widget.order != null && widget.product != null) {
      // Pasang modifiers lama
      for (BModifier mod in widget.product.modifiers) {
        for (BModifierData data in mod.modifiers) {
          for (BModifierData data2 in widget.order.modifiers) {
            if (data.id == data2.id) {
              data.qty = data2.qty;
            }
          }
        }
      }

      // Pasang variants lama
      if (widget.order.variants != null) {
        for (var i = 0; i < widget.order.variants.length; i++) {
          tabMatrixSelection[i] = widget.order.variants[i];
        }
        btnSimpanEnable = true;
      }
    }
  }
  // Map<int, BMatrixData> tabMatrixSelection = Map();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
          color: Colors.white,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                padding: EdgeInsets.all(15),
                child: Row(children: [
                  InkWell(
                      onTap: () => doDismiss(),
                      child:
                          Icon(Icons.clear, size: 30, color: Colors.grey[500])),
                  Wgt.spaceLeft(10),
                  Wgt.text(context, "${widget.product.name}", maxlines: 1)
                ])),
            Wgt.separator(),
            Container(height: 15, color: Colors.grey[100], child: Container()),
            Wgt.separator(),
            opsi(),
            Container(
                margin: EdgeInsets.all(15),
                child: Row(children: [
                  Expanded(
                      child: Wgt.btn(context, "SIMPAN",
                          color:
                              btnSimpanEnable ? Cons.COLOR_ACCENT : Colors.grey,
                          onClick: btnSimpanEnable ? () => doSimpan() : null)),
                ])),
          ]),
        ));
  }

  void doSimpan() {
    num numPages = 0;
    if (widget.product.has_variant) numPages++;
    if (widget.product.has_modifier) numPages++;

    if (pageController != null && pageController.page < numPages - 1) {
      pageController.jumpToPage(pageController.page.toInt() + 1);
    } else {
      // Halaman terakhir, simpan beneran
      BOrder order = doCreateOrders();
      if (order != null) {
        Navigator.pop(context, order);
      }
    }
  }

  void doCekPerluPopup() {
    if ((widget.product.modifiers == null ||
            widget.product.modifiers.isEmpty) &&
        (widget.product.variant == null || widget.product.variant.isEmpty)) {
      doSimpan();
    }
  }

  BOrder doCreateOrders() {
    // Create list selected modifiers
    List<BModifierData> selectedModifiers;
    if (widget.product.has_modifier) {
      selectedModifiers = List();

      for (BModifier mod in widget.product.modifiers) {
        for (BModifierData data in mod.modifiers) {
          if (data.qty > 0) selectedModifiers.add(data);
        }
      }

      // Di sort by name
      selectedModifiers.sort((BModifierData a, BModifierData b) =>
          a.name.toString().compareTo(b.name.toString()));
    }

    // Create list selected variants
    List<BVariantData> selectedVariants;
    if (widget.product.has_variant) {
      selectedVariants = List();

      tabMatrixSelection.forEach((key, value) {
        selectedVariants.add(value);
      });

      // Di sort by name
      selectedVariants.sort((BVariantData a, BVariantData b) =>
          a.name.toString().compareTo(b.name.toString()));
    }

    if (widget.product.variantdetails != null && selectedVariants != null) {
      String keyMaster = "";
      for (BVariantData data in selectedVariants) {
        keyMaster += data.id + "-";
      }

      Map<String, BVariantDetails> mappingVariantDetails = Map();
      for (BVariantDetails det in widget.product.variantdetails) {
        String key = "";
        if (det.variantdata != null)
          for (BVariantData data in det.variantdata) {
            key += data.id + "-";
          }

        mappingVariantDetails[key] = det;
      }

      if (mappingVariantDetails[keyMaster] != null) {
        // print(mappingVariantDetails[keyMaster]);
        widget.product.price = mappingVariantDetails[keyMaster].price;
      }
      // print("price:${widget.product.price}");
    }

    BOrder order = BOrder(
        product: widget.product,
        modifiers: selectedModifiers,
        variants: selectedVariants,
        qty: 1);

    return order;
  }

  void doDismiss() {
    Navigator.pop(context);
  }

  /**
   * Widget opsi
   */
  PageController pageController;
  Widget opsi() {
    List<Widget> pages = List();
    if (widget.product.has_variant) pages.add(listMatrix());
    if (widget.product.has_modifier) pages.add(listModifiers());

    if (pageController == null) {
      pageController = PageController(initialPage: 0, keepPage: true);
      // pageController = PageController(length: pages.length, vsync: this);
    }
    return Expanded(
        child: PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      children: pages,
    ));
  }

  /**
   * Matrix
   * Display matrix kalau
   * has_variant = true
   */
  TabController tabController;
  var selectedTabIndex = 0;
  Map<int, BVariantData> tabMatrixSelection = Map();
  Widget listMatrix() {
    if ((!widget.product.has_modifier && !widget.product.has_variant))
      return Container();
    List<BVariant> matrix = widget.product.variant;

    if (tabController == null) {
      tabController = TabController(length: matrix.length, vsync: this);
      tabController.addListener(() {
        if (tabController.index == 0)
          // Do nothing kalo index pertama
          return;

        if (tabMatrixSelection[tabController.index - 1] == null) {
          tabController.index -= 1;
          setState(() {});
          Helper.popupDialog(context,
              title: "Peringatan!",
              text: "Harap pilih varian di grup sebelumnya.");
        }
      });
    }

    return Container(
        child: Column(children: [
      TabBar(
          controller: tabController,
          onTap: (index) {},
          tabs: List.generate(matrix.length, (index) {
            return Container(
                height: 80,
                child: Tab(
                    child: Column(children: [
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Wgt.text(context, matrix[index].name)),
                  tabMatrixSelection[index] == null
                      ? Container(
                          child: Wgt.textSecondary(
                              context, "Pilih pilihan ${index + 1}"))
                      : Container(
                          child: Wgt.textSecondary(
                              context, tabMatrixSelection[index].name,
                              color: Cons.COLOR_PRIMARY,
                              weight: FontWeight.bold))
                ])));
          })),
      Expanded(
          child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: List.generate(matrix.length, (index) {
                return Container(
                    child: gridMatrix(index, matrix[index].variantdata));
              })))
    ]));
  }

  Widget gridMatrix(indexParent, List<BVariantData> list) {
    return GridView.count(
        padding: EdgeInsets.all(20),
        // shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: List.generate(list.length, (index) {
          bool active = tabMatrixSelection[indexParent] != null &&
              tabMatrixSelection[indexParent].id == list[index].id;
          return InkWell(
              onTap: () => selectMatrixData(indexParent, list[index]),
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Cons.COLOR_PRIMARY),
                    color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: Wgt.textLarge(context, "${list[index].name}",
                            align: TextAlign.center,
                            color: active ? Colors.white : Colors.black)),
                  )));
        }));
  }

  void selectMatrixData(indexParent, BVariantData data) {
    tabMatrixSelection[indexParent] = data;
    if (tabController.index < tabController.length - 1) {
      tabController.animateTo(tabController.index + 1);
    } else {
      btnSimpanEnable = true;
    }
    setState(() {});
  }

  /**
   * Modifiers
   * Display matrix kalau
   * has_modifier = true
   */
  Widget listModifiers() {
    if ((!widget.product.has_modifier && !widget.product.has_variant))
      return Container();

    List<BModifier> modifiers = widget.product.modifiers;
    List<BModifierData> modData = List();
    for (BModifier mod in modifiers) {
      modData.addAll(mod.modifiers);
    }

    return Container(
        child: Container(
            padding: EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 20),
            child: Container(
                child: Column(mainAxisSize: MainAxisSize.max, children: [
              Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(children: [
                    Image.asset("assets/ic_layers_blue_24_px.png", height: 25),
                    Wgt.spaceLeft(10),
                    Wgt.text(context, "Opsi Tambahan", weight: FontWeight.bold),
                    Wgt.spaceLeft(5),
                    Wgt.text(context, "(Opsional)", weight: FontWeight.w300),
                  ])),
              Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      itemCount: modData.length,
                      itemBuilder: (context, index) {
                        return cellModifier(modData[index]);
                      }))
            ]))));
  }

  Widget cellModifier(BModifierData data) {
    bool active = data.qty != null && data.qty > 0;
    return Container(
        color: active ? Cons.COLOR_PRIMARY : Colors.transparent,
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        child: Row(children: [
          Wgt.text(context, "${data.name}",
              color: active ? Colors.white : Colors.black,
              size: Wgt.FONT_SIZE_NORMAL_2),
          Expanded(child: Container()),
          Wgt.text(context, "${Helper.formatRupiahInt(data.price)}",
              color: active ? Colors.white : Colors.grey),
          Wgt.spaceLeft(10),
          Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => doMinQty(data),
                child: Image.asset("assets/group_4_copy_4.png",
                    height: 35,
                    color: active ? Colors.white : Cons.COLOR_PRIMARY_2),
              )),
          Wgt.spaceLeft(20),
          Wgt.textLarge(context, "${data.qty}",
              color: active ? Colors.white : Colors.black),
          Wgt.spaceLeft(20),
          Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => doAddQty(data),
                child: Image.asset("assets/group_4_copy_3.png",
                    height: 35,
                    color: active ? Colors.white : Cons.COLOR_PRIMARY),
              )),
        ]));
  }

  void doAddQty(BModifierData data) {
    data.qty += 1;
    setState(() {});
  }

  void doMinQty(BModifierData data) {
    data.qty -= 1;
    if (data.qty < 0) {
      data.qty = 0;
    }
    setState(() {});
  }
}

class PopupHarga extends StatefulWidget {
  num harga;
  num jumlah;
  PopupHarga({this.harga, this.jumlah});

  @override
  _PopupHargaState createState() => _PopupHargaState();
}

class _PopupHargaState extends State<PopupHarga> {
  num divider = 6.5;
  @override
  Widget build(BuildContext context) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width;
    num size = min(height, width) / divider;

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
          width: size * 4,
          color: Colors.white,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: EdgeInsets.all(15),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                          onTap: () => doDismiss(),
                          child: Icon(Icons.clear,
                              size: 30, color: Colors.grey[500])),
                      Wgt.spaceLeft(10),
                      Wgt.text(context,
                          "${widget.harga != null ? "Ubah Harga" : "Ubah Jumlah"}",
                          maxlines: 1, weight: FontWeight.bold),
                    ])),
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200])),
                    child: Row(children: [
                      Expanded(child: Container()),
                      Container(
                          height: size,
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, right: 20, left: 20),
                          child: FittedBox(
                              child: Wgt.textLarge(context,
                                  "${Helper.formatRupiahInt(widget.harga != null ? widget.harga : widget.jumlah ?? 0, currency: "")}",
                                  align: TextAlign.end))),
                    ])),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Column(children: [
                    Row(children: [
                      btnNumber(1),
                      btnNumber(2),
                      btnNumber(3),
                    ]),
                    Wgt.separator(),
                    Row(children: [
                      btnNumber(4),
                      btnNumber(5),
                      btnNumber(6),
                    ]),
                    Wgt.separator(),
                    Row(children: [
                      btnNumber(7),
                      btnNumber(8),
                      btnNumber(9),
                    ]),
                    if (widget.harga != null)
                      Row(children: [
                        btnNumber(0),
                        btnNumberExtended("00", extended: true),
                      ]),
                    if (widget.jumlah != null)
                      Row(children: [
                        btnNumberExtended("0"),
                        btnNumberExtended(".", extended: false),
                      ]),
                  ]),
                  Column(children: [
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => doHapusNumber(),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[200])),
                              padding: EdgeInsets.all(20),
                              height: size * 2,
                              width: size,
                              child: FittedBox(
                                  child: Wgt.text(context, "HAPUS",
                                      weight: FontWeight.normal))),
                        )),
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => doSimpan(),
                          child: Container(
                              color: Cons.COLOR_ACCENT,
                              padding: EdgeInsets.all(20),
                              height: size * 2,
                              width: size,
                              child: FittedBox(
                                  child: Wgt.text(context, "SIMPAN",
                                      color: Colors.white,
                                      weight: FontWeight.bold))),
                        )),
                  ]),
                ]),
              ]),
        ));
  }

  Widget btnNumber(qty) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width;
    num size = min(height, width) / divider;

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => doAddNumber(qty),
          child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey[200])),
              padding: EdgeInsets.all(30),
              height: size,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: FittedBox(child: Wgt.text(context, "$qty")))),
        ));
  }

  Widget btnNumberExtended(qty, {extended = true}) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width;
    num size = min(height, width) / divider;

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => doAddNumber(qty),
          child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey[200])),
              padding: EdgeInsets.all(30),
              height: size,
              width: size * (extended ? 2 : 1),
              child: FittedBox(child: Wgt.text(context, "$qty"))),
        ));
  }

  void doAddNumber(qty) {
    if (widget.harga != null)
      widget.harga = num.parse(widget.harga.toString() + "$qty");
    else if (widget.jumlah != null)
      widget.jumlah = num.parse(widget.jumlah.toString() + "$qty");
    setState(() {});
  }

  void doHapusNumber() {
    if (widget.harga != null) {
      if (widget.harga.toString().length == 1) {
        widget.harga = 0;
      } else {
        widget.harga = num.parse(widget.harga
            .toString()
            .substring(0, widget.harga.toString().length - 1));
      }
    } else if (widget.jumlah != null) {
      if (widget.jumlah.toString().length == 1) {
        widget.jumlah = 0;
      } else {
        widget.jumlah = num.parse(widget.jumlah
            .toString()
            .substring(0, widget.jumlah.toString().length - 1));
      }
    }
    setState(() {});
  }

  void doDismiss() {
    Navigator.pop(context);
  }

  void doSimpan() {
    num baru = widget.harga != null ? widget.harga : widget.jumlah ?? 0;
    Navigator.pop(context, baru);
  }
}

class PopupNotes extends StatefulWidget {
  String text;
  PopupNotes({this.text});
  @override
  _PopupNotesState createState() => _PopupNotesState();
}

class _PopupNotesState extends State<PopupNotes> {
  TextEditingController edt = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.text != null) edt.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: EdgeInsets.all(20),
              child: TextField(
                  controller: edt,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 4,
                  decoration: InputDecoration(
                      labelText: "Masukkan catatan untuk pesanan..",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey)))),
            ),
            Row(children: [
              Expanded(child: Container()),
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Wgt.textAction(context, "BATAL",
                        color: Cons.COLOR_PRIMARY),
                  )),
              InkWell(
                  onTap: () => Navigator.pop(context, edt.text),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Wgt.textAction(context, "OK",
                        color: Cons.COLOR_PRIMARY, weight: FontWeight.bold),
                  )),
            ]),
            Wgt.spaceTop(10),
          ]),
        ));
  }
}

class OrderCustomAmount extends StatefulWidget {
  BCustomAmount customAmount;
  OrderCustomAmount({this.customAmount});

  @override
  _OrderCustomAmountState createState() => _OrderCustomAmountState();
}

class _OrderCustomAmountState extends State<OrderCustomAmount> {
  num divider = 7;
  num total = 0;
  TextEditingController cont = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customAmount != null) {
      total = widget.customAmount.total;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            color: Colors.grey[100],
            child: Column(children: [
              Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Row(children: [
                    InkWell(
                        onTap: () => doDismiss(),
                        child: Icon(Icons.clear,
                            size: 30, color: Colors.grey[500])),
                    Wgt.spaceLeft(10),
                    Wgt.text(context, "Custom Amount", maxlines: 1)
                  ])),
              Expanded(
                  child: Row(children: [
                Expanded(
                    child: Column(children: [
                  Expanded(
                      child: Center(
                          child: Container(
                    padding: EdgeInsets.all(40),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomInput(controller: cont),
                          Wgt.spaceTop(30),
                          Wgt.text(context, "${Helper.formatRupiahInt(total)}"),
                        ]),
                  ))),
                ])),
                Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(child: Container()),
                      Row(children: [
                        Expanded(child: Container()),
                        btnNumber(1),
                        Expanded(child: Container()),
                        btnNumber(2),
                        Expanded(child: Container()),
                        btnNumber(3),
                        Expanded(child: Container()),
                      ]),
                      Expanded(child: Container()),
                      Row(children: [
                        Expanded(child: Container()),
                        btnNumber(4),
                        Expanded(child: Container()),
                        btnNumber(5),
                        Expanded(child: Container()),
                        btnNumber(6),
                        Expanded(child: Container()),
                      ]),
                      Expanded(child: Container()),
                      Row(children: [
                        Expanded(child: Container()),
                        btnNumber(7),
                        Expanded(child: Container()),
                        btnNumber(8),
                        Expanded(child: Container()),
                        btnNumber(9),
                        Expanded(child: Container()),
                      ]),
                      Expanded(child: Container()),
                      Row(children: [
                        Expanded(child: Container()),
                        btnNumber("+"),
                        Expanded(child: Container()),
                        btnNumber(0),
                        Expanded(child: Container()),
                        btnNumber("-", polos: true),
                        Expanded(child: Container()),
                      ]),
                      Expanded(child: Container()),
                    ])),
              ])),
              Container(
                  color: Colors.white,
                  child: Row(children: [
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(20),
                            child: Wgt.btn(context, "SIMPAN",
                                onClick: () => doSimpan())))
                  ]))
            ])));
  }

  Widget btnNumber(qty, {polos = false}) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width;
    num size = min(height, width) / divider;

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => doAddNumber(qty),
          child: Container(
              decoration: polos
                  ? null
                  : BoxDecoration(
                      boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey[400],
                              blurRadius: 1.0,
                              offset: Offset(1.0, 1.0))
                        ],
                      border: Border.all(color: Colors.grey[200]),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white),
              padding: EdgeInsets.all(polos ? 40 : 30),
              height: size,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: FittedBox(
                      child: polos
                          ? Icon(Icons.backspace, color: Colors.grey[800])
                          : Wgt.text(context, "$qty")))),
        ));
  }

  void doAddNumber(qty) {
    String txt = cont.text;
    if (qty != "-") {
      txt += "$qty";
    } else {
      txt = txt.substring(0, txt.length - 1);
    }
    cont.text = txt;
    hitungTotal();

    setState(() {});
  }

  void hitungTotal() {
    String txt = cont.text;
    total = 0;
    for (String qty in txt.split("+")) {
      if (qty == "") continue;
      total += num.parse(qty);
    }
  }

  void doDismiss() {
    Navigator.pop(context);
  }

  void doSimpan() {
    widget.customAmount.total = this.total;
    Navigator.pop(context, widget.customAmount);
  }
}

class CustomAmountNotes extends StatefulWidget {
  BCustomAmount customAmount;
  CustomAmountNotes({this.customAmount});

  @override
  _CustomAmountNotesState createState() => _CustomAmountNotesState();
}

class _CustomAmountNotesState extends State<CustomAmountNotes> {
  TextEditingController cont = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.customAmount != null) {
      cont.text = widget.customAmount.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            color: Colors.grey[100],
            child: Column(children: [
              Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Row(children: [
                    InkWell(
                        onTap: () => doDismiss(),
                        child: Icon(Icons.clear,
                            size: 30, color: Colors.grey[500])),
                    Wgt.spaceLeft(10),
                    Wgt.text(context, "Custom Amount", maxlines: 1)
                  ])),
              Container(
                  padding: EdgeInsets.all(20),
                  child: CustomInput(
                    controller: cont,
                    hint: "Ketik untuk menambah catatan",
                  )),
              Expanded(child: Container()),
              Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Row(children: [
                    Expanded(
                        child: Wgt.btn(context, "SIMPAN",
                            onClick: () => doSimpan())),
                  ]))
            ])));
  }

  void doSimpan() {
    widget.customAmount.notes = cont.text;
    Navigator.pop(context, widget.customAmount);
  }

  void doDismiss() {
    Navigator.pop(context);
  }
}

class JumlahBayar extends StatefulWidget {
  int harga;
  int hargaTagihan;
  JumlahBayar({this.harga = 0, this.hargaTagihan = 0});

  @override
  _JumlahBayarState createState() => _JumlahBayarState();
}

class _JumlahBayarState extends State<JumlahBayar> {
  num divider = 6.5;
  bool jumlahOke = false;
  @override
  Widget build(BuildContext context) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width;
    num size = min(height, width) / divider;

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
          width: size * 4,
          color: Colors.white,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: EdgeInsets.all(15),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                          onTap: () => doDismiss(),
                          child: Icon(Icons.clear,
                              size: 30, color: Colors.grey[500])),
                      Wgt.spaceLeft(30),
                      Wgt.text(context,
                          "Total : ${Helper.formatRupiahInt(widget.hargaTagihan, currency: '')}",
                          maxlines: 1, weight: FontWeight.bold),
                    ])),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200])),
                  child: Row(children: [
                    Expanded(child: Container()),
                    Container(
                        height: size,
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 20, left: 20),
                        child: FittedBox(
                            child: Wgt.textLarge(context,
                                "${Helper.formatRupiahInt(widget.harga)}",
                                align: TextAlign.end))),
                  ]),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Column(children: [
                    Row(children: [
                      btnNumber(1),
                      btnNumber(2),
                      btnNumber(3),
                    ]),
                    Wgt.separator(),
                    Row(children: [
                      btnNumber(4),
                      btnNumber(5),
                      btnNumber(6),
                    ]),
                    Wgt.separator(),
                    Row(children: [
                      btnNumber(7),
                      btnNumber(8),
                      btnNumber(9),
                    ]),
                    Row(children: [
                      btnNumber(0),
                      btnNumberExtended("00"),
                    ]),
                  ]),
                  Column(children: [
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => doHapusNumber(),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[200])),
                              padding: EdgeInsets.all(20),
                              height: size * 2,
                              width: size,
                              child: FittedBox(
                                  child: Wgt.text(context, "HAPUS",
                                      color: Colors.grey[500],
                                      weight: FontWeight.normal))),
                        )),
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => doSimpan(),
                          child: Container(
                              color: jumlahOke
                                  ? Cons.COLOR_ACCENT
                                  : Colors.transparent,
                              padding: EdgeInsets.all(20),
                              height: size * 2,
                              width: size,
                              child: FittedBox(
                                  child: Wgt.text(context, "BAYAR",
                                      color: jumlahOke
                                          ? Colors.white
                                          : Colors.grey[800],
                                      weight: FontWeight.bold))),
                        ))
                  ])
                ])
              ]),
        ));
  }

  Widget btnNumber(qty) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width;
    num size = min(height, width) / divider;

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => doAddNumber(qty),
          child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey[200])),
              padding: EdgeInsets.all(30),
              height: size,
              child: AspectRatio(
                  aspectRatio: 1,
                  child: FittedBox(child: Wgt.text(context, "$qty")))),
        ));
  }

  Widget btnNumberExtended(qty, {extended = false}) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width;
    num size = min(height, width) / divider;

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => doAddNumber(qty),
          child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey[200])),
              padding: EdgeInsets.all(30),
              height: size,
              width: size * 2,
              child: FittedBox(child: Wgt.text(context, "$qty"))),
        ));
  }

  void doAddNumber(qty) {
    widget.harga = num.parse(widget.harga.toString() + "$qty");
    jumlahOke = widget.harga >= widget.hargaTagihan;
    setState(() {});
  }

  void doHapusNumber() {
    if (widget.harga.toString().length == 1) {
      widget.harga = 0;
    } else {
      widget.harga = num.parse(widget.harga
          .toString()
          .substring(0, widget.harga.toString().length - 1));
    }
    jumlahOke = widget.harga > widget.hargaTagihan;
    setState(() {});
  }

  void doDismiss() {
    Navigator.pop(context);
  }

  void doSimpan() {
    if (jumlahOke) Navigator.pop(context, widget.harga);
    else{
      Helper.popupDialog(context, text: "Pembayaran tidak cukup");
    }
  }
}

class BayarSplit extends StatefulWidget {
  @override
  BayarSplitState createState() => BayarSplitState();
}

class BayarSplitState extends State<BayarSplit> {
  String pilihan = "";
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: MediaQuery.of(context).size.height * 0.75,
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(0.0, 2.0))
                          ]),
                      padding: EdgeInsets.all(15),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        InkWell(
                            onTap: () => doDismiss(),
                            child: Icon(Icons.clear,
                                size: 30, color: Colors.grey[500])),
                        Wgt.spaceLeft(20),
                        Wgt.text(context, "Split",
                            maxlines: 1, weight: FontWeight.bold),
                        Expanded(child: Container()),
                      ])),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.all(30),
                        child: Column(children: [
                          Wgt.text(context, "Pilih Metode Split",
                              size: Wgt.FONT_SIZE_NORMAL_2,
                              weight: FontWeight.bold,
                              color: Colors.grey[700]),
                          Wgt.spaceTop(10),
                          Expanded(
                              child: Row(children: [
                            Expanded(child: splitPembayaran()),
                            Wgt.spaceLeft(30),
                            Expanded(child: splitBill()),
                          ])),
                          Wgt.spaceTop(30),
                          Row(children: [
                            Expanded(
                                child: Wgt.btn(context, "PILIH",
                                    onClick: () => doPilih(),
                                    enabled: pilihan != "")),
                          ]),
                        ])),
                  )
                ])));
  }

  Widget splitPembayaran() {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () => doSplitPayment(),
            child: Container(
                padding:
                    EdgeInsets.only(bottom: 20, left: 10, right: 10, top: 10),
                decoration: BoxDecoration(
                    color:
                        pilihan == "payment" ? Color(0x3A00BBD4) : Colors.white,
                    border: Border.all(color: Cons.COLOR_PRIMARY),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(children: [
                  Container(
                      width: MediaQuery.of(context).size.width / 6,
                      child: Image.asset("assets/ic_split_payment.png")),
                  Wgt.text(context, "Split Pembayaran",
                      color: Colors.grey[700],
                      weight: FontWeight.bold,
                      size: Wgt.FONT_SIZE_NORMAL_2),
                  Wgt.spaceTop(10),
                  Wgt.text(context,
                      "Membayar 1 tagihan dengan lebih dari satu metode pembayaran",
                      maxlines: 100,
                      align: TextAlign.center,
                      color: Colors.grey[600]),
                ]))));
  }

  Widget splitBill() {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () => doSplitBill(),
            child: Container(
                padding:
                    EdgeInsets.only(bottom: 20, left: 10, right: 10, top: 10),
                decoration: BoxDecoration(
                    color: pilihan == "bill" ? Color(0x3A00BBD4) : Colors.white,
                    border: Border.all(color: Cons.COLOR_PRIMARY),
                    borderRadius: BorderRadius.circular(5)),
                child: Column(children: [
                  Container(
                      width: MediaQuery.of(context).size.width / 6,
                      child: Image.asset("assets/ic_split_bill.png")),
                  Wgt.text(context, "Split Bill",
                      color: Colors.grey[700],
                      weight: FontWeight.bold,
                      size: Wgt.FONT_SIZE_NORMAL_2),
                  Wgt.spaceTop(10),
                  Wgt.text(context,
                      "Memecah 1 tagihan menjadi beberapa struk terpisah tagihan menjadi beberapa struk",
                      maxlines: 100,
                      align: TextAlign.center,
                      color: Colors.grey[600]),
                ]))));
  }

  void doDismiss() {
    Navigator.pop(context);
  }

  void doSplitPayment() {
    pilihan = "payment";
    setState(() {});
  }

  void doSplitBill() {
    pilihan = "bill";
    setState(() {});
  }

  void doPilih() {
    // doDismiss();
    // payment / bill
    Helper.closePage(context, payload: pilihan);
  }
}

class BayarNotes extends StatefulWidget {
  BOrderParent orderParent;
  BayarNotes({this.orderParent});
  @override
  _BayarNotesState createState() => _BayarNotesState();
}

class _BayarNotesState extends State<BayarNotes> {
  CustomInput inputNotes;
  TextEditingController contNotes = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.orderParent != null) {
      contNotes.text = widget.orderParent.notes;
    }
    inputNotes = CustomInput(
        hint: "Catatan",
        bordered: true,
        borderColor: Colors.grey,
        type: TextInputType.multiline,
        controller: contNotes,
        displayUnderline: false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: 500,
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wgt.text(context, "Catatan"),
                  Wgt.spaceTop(10),
                  inputNotes,
                  Wgt.spaceTop(15),
                  Row(children: [
                    Expanded(child: Container()),
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () => doDismiss(),
                            child: Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                child: Wgt.text(context, "BATAL",
                                    color: Cons.COLOR_PRIMARY,
                                    weight: FontWeight.normal)))),
                    Wgt.spaceLeft(10),
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () => doDismiss(),
                            child: Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                child: Wgt.text(context, "OK",
                                    color: Cons.COLOR_PRIMARY,
                                    weight: FontWeight.normal)))),
                  ]),
                ])));
  }

  void doDismiss() {
    if (widget.orderParent != null) widget.orderParent.notes = contNotes.text;
    Helper.closePage(context, payload: {"orderParent": widget.orderParent});
  }
}

class PopupTipePenjualan extends StatefulWidget {
  List<BSalesType> arrSalesType = List();
  BSalesType type;
  PopupTipePenjualan({this.type, this.arrSalesType});

  @override
  _PopupTipePenjualanState createState() => _PopupTipePenjualanState();
}

class _PopupTipePenjualanState extends State<PopupTipePenjualan> {
  num divider = 6.5;

  @override
  Widget build(BuildContext context) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width / 2;

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: width,
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[300]))),
                      padding: EdgeInsets.all(10),
                      child: Row(children: [
                        InkWell(
                            onTap: () => doDismiss(),
                            child: Icon(Icons.clear,
                                size: 30, color: Colors.grey[500])),
                        Wgt.spaceLeft(10),
                        Wgt.text(context, "Tipe Penjualan", maxlines: 1)
                      ])),
                  Expanded(
                      child: SingleChildScrollView(
                          padding: EdgeInsets.all(10),
                          child: Column(
                              children: List.generate(
                                  widget.arrSalesType.length, (index) {
                            return btnType(tag: widget.arrSalesType[index]);
                          })))),
                  Container(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 0),
                      child: Row(children: [
                        Expanded(
                            child: Wgt.btn(context, "SIMPAN",
                                color: Cons.COLOR_ACCENT,
                                onClick: () => doSimpan())),
                      ]))
                ])));
  }

  Widget btnType({BSalesType tag}) {
    String text = tag.name;
    bool active = widget.type.id == tag.id;
    if (tag.deleted == 1) return Container();
    return Material(
        child: InkWell(
            onTap: () {
              widget.type = tag;
              setState(() {});
            },
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 10),
                      decoration: BoxDecoration(
                          color:
                              active ? Cons.COLOR_PRIMARY : Colors.transparent,
                          border: Border.all(color: Cons.COLOR_PRIMARY),
                          borderRadius: BorderRadius.circular(5)),
                      child: Wgt.text(context, "$text",
                          weight: FontWeight.bold,
                          color: active ? Colors.white : Cons.COLOR_PRIMARY)))
            ])));
  }

  void doDismiss() {
    Helper.closePage(context);
  }

  void doSimpan() {
    Helper.closePage(context, payload: {"salestype": widget.type});
  }
}

class PopupNama extends StatefulWidget {
  String nama;
  PopupNama({this.nama});

  @override
  _PopupNamaState createState() => _PopupNamaState();
}

class _PopupNamaState extends State<PopupNama> {
  num divider = 6.5;
  TextEditingController contNama = TextEditingController();
  CustomInput inputNama;
  @override
  void initState() {
    super.initState();
    if (widget.nama != null) contNama.text = widget.nama;
    inputNama = CustomInput(controller: contNama, hint: "Nama");
  }

  @override
  Widget build(BuildContext context) {
    num height = MediaQuery.of(context).size.height;
    num width = MediaQuery.of(context).size.width / 2;

    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: width,
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[300]))),
                      padding: EdgeInsets.all(10),
                      child: Row(children: [
                        InkWell(
                            onTap: () => doDismiss(),
                            child: Icon(Icons.clear,
                                size: 30, color: Colors.grey[500])),
                        Wgt.spaceLeft(10),
                        Wgt.text(context, "Nama", maxlines: 1)
                      ])),
                  Container(padding: EdgeInsets.all(20), child: inputNama),
                  Container(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 0),
                      child: Row(children: [
                        Expanded(
                            child: Wgt.btn(context, "SIMPAN",
                                color: Cons.COLOR_ACCENT,
                                onClick: () => doSimpan())),
                      ]))
                ])));
  }

  void doDismiss() {
    Helper.closePage(context);
  }

  void doSimpan() {
    Helper.closePage(context, payload: {"nama": contNama.text});
  }
}

class PopupStock extends StatefulWidget {
  BProduct prod;

  PopupStock({this.prod});

  @override
  _PopupStockState createState() => _PopupStockState();
}

class _PopupStockState extends State<PopupStock> {
  Map<String, BVariantDetails> mapVariantsFiltered = Map();
  Map<String, bool> mapSelected = Map();

  @override
  void initState() {
    super.initState();
    filter();
  }

  void filter() {
    mapVariantsFiltered.clear();
    if (widget.prod.variantdetails != null && widget.prod != null) {
      widget.prod.variantdetails.forEach((value) {
        if (widget.prod.id == value.parent_id) {
          bool valid = true;
          if (mapSelected.isNotEmpty) {
            for (BVariantData data in value.variantdata)
              if (!mapSelected.keys.toList().contains(data.id)) valid = false;
          }

          if (valid) mapVariantsFiltered[value.name] = value;
        }
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 1.5,
            child: Column(children: [
              JudulPopup(title: "Detail Produk"),
              Wgt.separator(),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      color: Colors.grey[100],
                      child: Row(children: [
                        Expanded(
                            child: Container(
                                color: Colors.white,
                                child: Column(children: [
                                  Container(
                                      padding: EdgeInsets.all(20),
                                      child: Row(children: [
                                        Expanded(
                                            child: Wgt.textLarge(context,
                                                "${widget.prod.name}")),
                                        Container(
                                            width: 100,
                                            child: Wgt.btn(context, "FILTER",
                                                borderColor: Cons.COLOR_PRIMARY,
                                                transparent: true,
                                                radius: 7.0,
                                                textcolor: Cons.COLOR_PRIMARY,
                                                color: Colors.white,
                                                onClick: () => doFilter())),
                                      ])),
                                  Wgt.separator(),
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 10,
                                          bottom: 10),
                                      child: Row(children: [
                                        Expanded(
                                            flex: 2,
                                            child: Wgt.text(context, "Varian",
                                                weight: FontWeight.bold)),
                                        Expanded(
                                            flex: 1,
                                            child: Wgt.text(context, "Harga",
                                                weight: FontWeight.bold)),
                                        Expanded(
                                            flex: 1,
                                            child: Wgt.text(context, "Stok",
                                                align: TextAlign.center,
                                                weight: FontWeight.bold)),
                                      ])),
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount: mapVariantsFiltered.length,
                                          itemBuilder: (context, index) {
                                            String key = mapVariantsFiltered
                                                .keys
                                                .toList()[index];
                                            return cell(
                                                mapVariantsFiltered[key]);
                                          }))
                                ]))),
                      ]))),
              Wgt.separator(),
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  child: Row(children: [
                    Expanded(child: Wgt.text(context, "PRODUK TERSEDIA")),
                    CupertinoSwitch(
                        value: widget.prod.is_active,
                        onChanged: (val) {
                          widget.prod.is_active = !widget.prod.is_active;
                          setState(() {});
                          DBPawoon().update(
                              data: widget.prod.toDb(),
                              tablename: DBPawoon.DB_PRODUCTS);
                        },
                        activeColor: Cons.COLOR_PRIMARY),
                  ]))
            ])));
  }

  Widget cell(BVariantDetails item) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(children: [
          Expanded(flex: 2, child: Wgt.text(context, "${item.name}")),
          Expanded(
              flex: 1,
              child: Wgt.text(context,
                  "${Helper.formatRupiahInt(item.price.toInt(), currency: "")}")),
          Expanded(
              flex: 1,
              child: Wgt.text(context, "${item.stock.toInt()}",
                  align: TextAlign.center)),
        ]));
  }

  Future<void> doFilter() async {
    var selected = await showDialog(
        context: context,
        builder: (_) =>
            PopupStockFilter(prod: widget.prod, mapSelected: mapSelected));
    if (selected != null) {
      mapSelected = selected;
      filter();
    }
  }
}

class DBpawoon {}

class PopupStockFilter extends StatefulWidget {
  BProduct prod;
  Map<String, bool> mapSelected = Map();

  PopupStockFilter({this.prod, this.mapSelected});

  @override
  _PopupStockFilterState createState() => _PopupStockFilterState();
}

class _PopupStockFilterState extends State<PopupStockFilter> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 1.5,
            child: Column(children: [
              JudulPopup(context: context, title: "Filter"),
              Wgt.separator(),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Row(children: [
                    Expanded(
                        child: Wgt.textLarge(context, "${widget.prod.name}")),
                    Wgt.btn(context, "Apply Filter",
                        onClick: () => doApplyFilter()),
                  ])),
              Wgt.separator(),
              Expanded(child: listData()),
            ])));
  }

  Widget listData() {
    return Container(
        child: ListView.builder(
            itemCount: widget.prod.variant.length,
            itemBuilder: (context, index) {
              return cellList(variant: widget.prod.variant[index]);
            }));
  }

  Widget cellList({BVariant variant}) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wgt.text(context, "${variant.name}"),
          Wgt.spaceTop(5),
          Wrap(
              spacing: 0,
              runSpacing: 10,
              children: List.generate(variant.variantdata.length,
                  (index) => cellPilihan(item: variant.variantdata[index]))),
        ]));
  }

  Widget cellPilihan({BVariantData item}) {
    bool active =
        widget.mapSelected[item.id] != null && widget.mapSelected[item.id];
    return InkWell(
        onTap: () {
          if (widget.mapSelected[item.id] == null)
            widget.mapSelected[item.id] = true;
          else {
            widget.mapSelected.remove(item.id);
          }

          setState(() {});
        },
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
            margin: EdgeInsets.only(right: 5, left: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: active ? Cons.COLOR_PRIMARY : Colors.grey),
            child: Wgt.text(context, "${item.name}", color: Colors.white)));
  }

  void doApplyFilter() {
    print(widget.mapSelected);
    Helper.closePage(context, payload: widget.mapSelected);
  }
}

class PopupVoid extends StatefulWidget {
  @override
  _PopupVoidState createState() => _PopupVoidState();
}

class _PopupVoidState extends State<PopupVoid> {
  List<String> arrReasons = [
    "Kesalahan input",
    "Permintaan pelanggan",
    "Produk tidak tersedia",
  ];
  String selected = "";
  TextEditingController cont = TextEditingController();

  @override
  void initState() {
    super.initState();
    selected = arrReasons[0];
    cont.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              JudulPopup(context: context, title: "Batalkan Transaksi"),
              Wgt.separator(),
              Expanded(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Row(children: [
                          Icon(Icons.help, color: Colors.grey[400]),
                          Wgt.spaceLeft(20),
                          Wgt.text(context, "Alasan Pembatalan",
                              color: Colors.grey[500]),
                        ]),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300])),
                            child: Column(children: [
                              Column(
                                  children:
                                      List.generate(arrReasons.length, (index) {
                                return cell(index);
                              })),
                              Container(
                                  padding: EdgeInsets.only(
                                      left: 20, right: 20, top: 10, bottom: 10),
                                  child: Row(children: [
                                    Expanded(
                                        child: CustomInput(
                                            controller: cont,
                                            hint: "Lain - lain",
                                            polosan: true)),
                                    if (cont.text != "")
                                      Icon(Icons.check_circle,
                                          color: Colors.green),
                                  ])),
                            ])),
                        Wgt.spaceTop(20),
                        Row(children: [
                          Expanded(
                              child: Wgt.btn(context, "BATALKAN TRANSAKSI",
                                  onClick: () => doSave(), color: Colors.red))
                        ])
                      ]))),
            ])));
  }

  Widget cell(index) {
    bool active = arrReasons[index] == selected && cont.text == "";
    return InkWell(
        onTap: () {
          selected = arrReasons[index];
          setState(() {});
        },
        child: Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]))),
            padding: EdgeInsets.all(20),
            child: Row(children: [
              Expanded(child: Wgt.text(context, arrReasons[index])),
              if (active) Icon(Icons.check_circle, color: Colors.green),
            ])));
  }

  void doSave() {
    if (cont.text != "") selected = cont.text;
    Helper.closePage(context, payload: selected);
  }
}
