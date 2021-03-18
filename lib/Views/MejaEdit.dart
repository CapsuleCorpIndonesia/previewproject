import 'dart:convert';

import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BMeja.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Bean/BOutlet.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/RekapPopup.dart';

class MejaEdit extends StatefulWidget {
  MejaEdit({Key key}) : super(key: key);

  @override
  _MejaEditState createState() => _MejaEditState();
}

class _MejaEditState extends State<MejaEdit> {
  Loader2 loader = Loader2();
  List<BMeja> arrMeja = List();
  BOrderParent orderParent;
  BOutlet outlet;
  bool editMode = false;

  bool selected = false;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (orderParent == null) {
      orderParent = Helper.getPageData(context)["orderParent"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(
          context,
          name: "Pengaturan Meja",
          arrIconButtons: btnRight(),
          displayRight: true,
        ),
        body: body());
  }

  List<Widget> btnRight() {
    return <Widget>[
      InkWell(
          onTap: () => doTambah(),
          child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(50)),
              child: Row(children: [
                Image.asset("assets/ic_action_table.png",
                    height: 30, color: Cons.COLOR_PRIMARY),
                Wgt.spaceLeft(10),
                Wgt.text(context, "TAMBAH",
                    color: Cons.COLOR_PRIMARY, weight: FontWeight.bold)
              ]))),
      Wgt.spaceLeft(10),
    ];
  }

  Widget body() {
    return Container(
        child: loader.isLoading
            ? loader
            : Column(children: [
                Expanded(
                    child: GridView.count(
                        padding: EdgeInsets.all(20),
                        crossAxisCount: 6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                        children: List.generate(arrMeja.length, (index) {
                          return cellMejaEdit(arrMeja[index]);
                        }))),
              ]));
  }

  Widget cellMejaEdit(BMeja meja) {
    bool active = meja.selected;
    return InkWell(
        onTap: () => doEditMeja(meja),
        child: Container(
            margin: EdgeInsets.all(10),
            child: FDottedLine(
                color: Cons.COLOR_PRIMARY,
                strokeWidth: 2.0,
                dottedLength: 10.0,
                space: 5.0,
                child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(children: [
                          Wgt.textLarge(context, "${meja.name}"),
                          Expanded(
                              child: Image.asset("assets/ic_action_table.png",
                                  color: Colors.grey[300], fit: BoxFit.fill))
                        ]))),
                corner: FDottedLineCorner.all(500))));
  }

  Future<void> doTambah() async {
    var balikan = await showDialog(context: context, builder: (_)=> PopupMejaAdd());
    if (balikan != null && balikan) {
      await loadData();
      await uploadMeja();
    }
  }

  Future<void> doEditMeja(BMeja meja) async {
    var balikan =
        await showDialog(context: context, builder: (_)=> PopupMejaAdd(meja: meja));
    if (balikan != null && balikan) {
      await loadData();
      await uploadMeja();
    }
  }

  void resetSelectedMeja() {
    for (BMeja item in arrMeja) {
      item.selected = false;
    }
  }

  Future<void> loadData() async {
    loader.isLoading = true;
    setState(() {});

    List<Future> arrFut = List();
    arrFut.add(UserManager.getString(UserManager.OUTLET_OBJ).then((value) {
      if (value != null && value != "")
        outlet = BOutlet.parseObject(json.decode(value));
    }));

    arrFut.add(DBPawoon().select(tablename: DBPawoon.DB_TABLES).then((value) {
      arrMeja.clear();
      for (var item in value) {
        BMeja meja = BMeja.fromMap(item);
        arrMeja.add(meja);
        if (orderParent.meja != null && meja.uuid == orderParent.meja.uuid) {
          meja.selected = true;
          this.selected = true;
        }
      }

      setState(() {});
    }));

    await Future.wait(arrFut);

    loader.isLoading = false;
    setState(() {});
  }

  Future uploadMeja() {
    List<Map> dataMeja = List();
    for (BMeja m in arrMeja) {
      dataMeja.add(m.toJson());
    }
    return Logic(context).tablesEdit(
        data: json.encode(dataMeja),
        outletid: outlet.id,
        success: (json) async {
          if (json["data"] != null) {
            arrMeja.clear();
            for (var item in json["data"]) {
              arrMeja.add(BMeja.fromMap(item));
            }
          }

          await saveDataMeja();
          loadData();
        });
  }

  Future saveDataMeja() async {
    List<Future> arrFut = List();
    await DBPawoon().deleteAll(tablename: DBPawoon.DB_TABLES);
    for (BMeja m in arrMeja) {
      arrFut.add(DBPawoon().insertOrUpdate(
          data: m.toMap(), id: "uuid", tablename: DBPawoon.DB_TABLES));
    }

    await Future.wait(arrFut);
  }
}

class PopupMejaAdd extends StatefulWidget {
  BMeja meja;
  PopupMejaAdd({this.meja});
  @override
  _PopupMejaAddState createState() => _PopupMejaAddState();
}

class _PopupMejaAddState extends State<PopupMejaAdd> {
  CustomInput input;
  TextEditingController cont = TextEditingController();

  @override
  void initState() {
    super.initState();
    input = CustomInput(hint: "Masukkan nama meja..", controller: cont);
    if (widget.meja != null) cont.text = widget.meja.name;
    if (widget.meja != null) print(widget.meja.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              JudulPopup(context: context, title: "Tambah Meja"),
              Wgt.separator(),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    input,
                    Wgt.spaceTop(20),
                    Row(children: [
                      if (widget.meja != null)
                        Expanded(
                            child: Wgt.btn(context, "HAPUS",
                                color: Colors.red, onClick: () => doDelete())),
                      if (widget.meja != null) Wgt.spaceLeft(20),
                      Expanded(
                          child:
                              Wgt.btn(context, "OK", onClick: () => doSave()))
                    ])
                  ])),
            ])));
  }

  Future<void> doDelete() async {
    if (widget.meja != null) {
      await DBPawoon()
          .delete(tablename: DBPawoon.DB_TABLES, data: {"id": widget.meja.id});
    }
    Helper.closePage(context, payload: true);
  }

  Future<void> doSave() async {
    if (cont.text == "") {
      Helper.toastError(context, "Nama tidak boleh kosong");
      return;
    }
    if (cont.text.length > 4) {
      Helper.toastError(context, "Nama maksimal 4 karakter");
      return;
    }

    BMeja meja;
    if (widget.meja != null)
      meja = widget.meja;
    else
      meja = BMeja();

    meja.name = cont.text;
    await DBPawoon().insertOrUpdate(
        tablename: DBPawoon.DB_TABLES, data: meja.toMap(), id: "uuid");

    Helper.closePage(context, payload: true);
  }
}
