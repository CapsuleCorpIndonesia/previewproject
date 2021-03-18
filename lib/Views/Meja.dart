import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BMeja.dart';
import 'package:pawoon/Bean/BOrderParent.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/DBPawoon.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:fdottedline/fdottedline.dart';

import '../main.dart';

class Meja extends StatefulWidget {
  Meja({Key key}) : super(key: key);

  @override
  _MejaState createState() => _MejaState();
}

class _MejaState extends State<Meja> {
  Loader2 loader = Loader2();
  List<BMeja> arrMeja = List();
  BOrderParent orderParent;
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
          name: !editMode ? "Pilih Meja" : "Pengaturan Meja",
          displayRight: true,
          arrIconButtons: btnRight(),
        ),
        body: body());
  }

  List<Widget> btnRight() {
    return <Widget>[
      InkWell(
          onTap: () async {
            // editMode = true;
            // setState(() {});
            await Helper.openPage(context, Main.MEJA_EDIT, arg: {"orderParent": orderParent});
            loadData();
          },
          child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(50)),
              child: Row(children: [
                Icon(Icons.settings, color: Cons.COLOR_PRIMARY),
                Wgt.spaceLeft(10),
                Wgt.text(context, "Pengaturan",
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
                          return !editMode
                              ? cellMeja(arrMeja[index])
                              : cellMejaEdit(arrMeja[index]);
                        }))),
                if (selected)
                  Container(
                      margin: EdgeInsets.all(20),
                      child: Row(children: [
                        Expanded(
                            child: Wgt.btn(context, "PILIH MEJA",
                                color: Cons.COLOR_ACCENT,
                                onClick: () => doPilihMeja())),
                      ]))
              ]));
  }

  Widget cellMeja(BMeja meja) {
    bool active = meja.selected;
    return InkWell(
        onTap: () {
          resetSelectedMeja();
          meja.selected = !meja.selected;
          this.selected = true;
          setState(() {});
        },
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 7,
                    color: active ? Cons.COLOR_ACCENT : Colors.transparent),
                borderRadius: BorderRadius.circular(200)),
            margin: EdgeInsets.all(0),
            child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: active ? Cons.COLOR_ACCENT : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(200)),
                child: Column(children: [
                  Wgt.textLarge(context, "${meja.name}"),
                  Expanded(
                      child: Image.asset("assets/ic_action_table.png",
                          color: Colors.grey[300], fit: BoxFit.fill)),
                ]))));
  }

  Widget cellMejaEdit(BMeja meja) {
    bool active = meja.selected;
    return InkWell(
        onTap: () {},
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

  void doPilihMeja() {
    for (BMeja meja in arrMeja) {
      if (meja.selected) {
        orderParent.meja = meja;
        break;
      }
    }
    Helper.closePage(context, payload: true);
  }

  void resetSelectedMeja() {
    for (BMeja item in arrMeja) {
      item.selected = false;
    }
  }

  Future<void> loadData() async {
    loader.isLoading = true;
    setState(() {});

    await DBPawoon().select(tablename: DBPawoon.DB_TABLES).then((value) {
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
    });

    loader.isLoading = false;
    setState(() {});
  }
}
