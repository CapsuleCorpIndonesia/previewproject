import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:pawoon/Bean/BBisnis.dart';
import 'package:pawoon/Bean/BBisnisSub.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';

import '../main.dart';
import 'Outlet.dart';

class InfoBisnis extends StatefulWidget {
  InfoBisnis({Key key}) : super(key: key);

  @override
  _InfoBisnisState createState() => _InfoBisnisState();
}

class _InfoBisnisState extends State<InfoBisnis> {
  CustomInput inputNamaBisnis, inputTelp;
  TextEditingController contNama = TextEditingController();
  TextEditingController contTelp = TextEditingController();
  bool inputValid1 = false;
  bool inputValid2 = false;
  bool inputValid3 = false;
  List<BBisnis> arrBisnis = List();
  Loader2 loader = Loader2();
  PullToRefresh pullToRefresh = PullToRefresh();
  DDCustom ddCustom;
  Map<String, String> suggestions = Map();
  Map dataRegister;
  num step = 1;
  bool inputValid4 = false;
  bool firstTime = true;

  @override
  void initState() {
    super.initState();
    inputNamaBisnis = CustomInput(
      hint: "Nama Bisnis",
      displayUnderline: false,
      bordered: true,
      controller: contNama,
      validator: (text) {
        inputValid1 = false;
        setState(() {});
        if (text == "") return "*Tidak boleh kosong";
        if (text.length <= 3) return "*Terlalu pendek";

        inputValid1 = true;
        setState(() {});
        return "";
      },
    );

    inputTelp = CustomInput(
      hint: "No. telepon",
      displayUnderline: false,
      bordered: true,
      type: TextInputType.phone,
      controller: contTelp,
      validator: (text) {
        inputValid4 = false;
        setState(() {});
        if (num.tryParse(text) == null) return "Format salah";
        if (!text.startsWith("0")) return "*Harus diawali dengan angka 0";
        if (text.length <= 9) return "*Terlalu pendek";
        if (text.length > 15) return "*Terlalu panjang";

        inputValid4 = true;
        setState(() {});
        return "";
      },
    );
    ddCustom = DDCustom(listenerSelect: () {
      inputValid3 = true;
      setState(() {});
    });

    // contAutocomplete.addListener(() {
    //   if (contAutocomplete.text.length >= 3) doGetCity();
    // });

    refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (dataRegister == null) {
      dataRegister = Helper.getPageData(context)["data"];
    }
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Informasi Bisnis"), body: body());
  }

  Widget body() {
    return InkWell(
      // onTap: () => (),
      child: Container(
        child: Row(children: [
          Expanded(child: xBanner()),
          Expanded(child: form()),
        ]),
      ),
    );
  }

  Widget xBanner() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child: Image.asset("assets/register_2.jpg", fit: BoxFit.fitWidth),
    );
  }

  TextEditingController contAutocomplete = TextEditingController();

  Widget ubahHp() {
    return Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wgt.spaceTop(30),
            Wgt.textLarge(context, "Ubah No Handphone",
                weight: FontWeight.bold),
            Wgt.text(context, "Masukkan nomer telepon anda"),
            Wgt.spaceTop(30),
            inputTelp,
            Wgt.spaceTop(40),
            // Expanded(child: Container()),
            Row(children: [
              Expanded(
                  child: Wgt.btn(context, "DAFTAR",
                      enabled: inputValid4, onClick: () => doSignup())),
            ]),
            Wgt.spaceTop(20),
            Center(
                child: Wgt.text(context, "\u00a9 2020, Pawoon",
                    weight: FontWeight.w300)),
            Wgt.spaceTop(50),
          ]),
        ));
  }

  Widget verifikasiHp() {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wgt.spaceTop(30),
            Wgt.textLarge(context, "Verifikasi No Handphone",
                weight: FontWeight.bold),
            Wgt.spaceTop(30),
            Wrap(children: [
              Wgt.text(
                  context, "Apakah nomor yang Anda masukkan sudah benar ? "),
              Wgt.text(context, "${dataRegister["phone"]}",
                  weight: FontWeight.bold),
              InkWell(
                  onTap: () {
                    step += 1;
                    setState(() {});
                  },
                  child: Wgt.text(context, " ( ubah nomor ) ",
                      color: Cons.COLOR_PRIMARY, weight: FontWeight.bold)),
            ]),
            Wgt.spaceTop(20),
            // Expanded(child: Container()),
            Row(children: [
              Expanded(
                  child: Wgt.btn(context, "DAFTAR", onClick: () => doSignup())),
            ]),
            Wgt.spaceTop(20),
            Center(
                child: Wgt.text(context, "\u00a9 2020, Pawoon",
                    weight: FontWeight.w300)),
            Wgt.spaceTop(50),
          ]),
        ));
  }

  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  Widget textField;
  Widget form() {
    if (step == 2) return verifikasiHp();
    if (step == 3) return ubahHp();
    return pullToRefresh.generate(
        onRefresh: () => refresh(),
        child: loader.isLoading
            ? loader
            : Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Wgt.spaceTop(30),
                      Wgt.textLarge(context, "Informasi Bisnis",
                          weight: FontWeight.bold),
                      Wgt.text(context, "Isikan informasi bisnis Anda",
                          color: Colors.grey[700]),
                      Wgt.spaceTop(20),
                      inputNamaBisnis,
                      Wgt.spaceTop(20),
                      ddCustom,
                      Wgt.spaceTop(20),
                      Container(
                          child: AutoCompleteTextField<String>(
                              controller: contAutocomplete,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: 20, right: 20, top: 20, bottom: 20),
                                  labelText: "Lokasi Bisnis",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide:
                                          BorderSide(color: Colors.grey))),
                              textChanged: (text) {
                                setState(() {
                                  firstTime = false;
                                  inputValid2 = false;
                                });
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  contAutocomplete.text = item;
                                  inputValid2 = true;
                                });
                              },
                              clearOnSubmit: false,
                              textSubmitted: (text) {},
                              key: key,
                              suggestions: suggestions.keys.toList(),
                              itemBuilder: (context, suggestion) => Padding(
                                  child: ListTile(title: Text(suggestion)),
                                  padding: EdgeInsets.all(8.0)),
                              itemSorter: (a, b) => a.compareTo(b),
                              itemFilter: (suggestion, input) => suggestion
                                  .toLowerCase()
                                  .contains(input.toLowerCase()))),
                      Wgt.spaceTop(10),
                      Wgt.textSecondary(context, "*Coba Jakarta",
                          color: Colors.grey[600]),
                      if (!firstTime &&
                          !inputValid2 &&
                          contAutocomplete.text == "")
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Wgt.textSecondary(
                              context, "Lokasi bisnis tidak boleh kosong",
                              color: Colors.red),
                        ),
                      // dropdownCustom(),
                      Wgt.spaceTop(30),
                      Row(children: [
                        Expanded(
                            child: Wgt.btn(context, "LANJUTKAN",
                                enabled:
                                    inputValid1 && inputValid2 && inputValid3,
                                onClick: () => doSignup())),
                      ]),
                      Wgt.spaceTop(20),
                      InkWell(
                          // onTap: () => navLogin(),
                          child: Row(children: [
                        Expanded(child: Container()),
                        Wgt.text(context, "Sudah punya akun?"),
                        Wgt.spaceLeft(5),
                        Wgt.text(context, "Masuk di sini",
                            color: Cons.COLOR_PRIMARY),
                        Expanded(child: Container()),
                      ])),
                      Wgt.spaceTop(10),
                      Center(
                          child: Wgt.text(context, "\u00a9 2020, Pawoon",
                              weight: FontWeight.w300)),
                      Wgt.spaceTop(30),
                    ]))));
  }

  Future<void> refresh() async {
    List<Future> arrFut = List();
    arrFut.add(doGetBisnis());
    arrFut.add(doGetCity());
    await Future.wait(arrFut);

    ddCustom = DDCustom(
        arrBisnis: arrBisnis,
        listenerSelect: () {
          inputValid3 = true;
          setState(() {});
        });

    pullToRefresh.stopRefresh();
    loader.isLoading = false;
    setState(() {});
  }

  Future doGetBisnis() {
    return Logic(context).getBisnis(success: (json) {
      arrBisnis.clear();
      for (var item in json["data"]) {
        arrBisnis.add(BBisnis.fromJson(item));
      }
    });
  }

  Widget dropdownCustom() {
    return DropdownButton(
        underline: Container(),
        elevation: 1,
        isDense: false,
        iconSize: 30,
        isExpanded: true,
        hint: Container(
            padding: EdgeInsets.all(0),
            child: Wgt.textSecondary(context, "Kategori bisnis",
                color: Colors.grey)),
        // Not necessary for Option 1
        onChanged: (newValue) {
          // widget.selected = newValue;
          setState(() {});
        },
        items: List.generate(arrBisnis.length, (index) {
          BBisnis bisnis = arrBisnis[index];
          return DropdownMenuItem(
              child: ExpansionTile(
                  title: Wgt.text(context, "${bisnis.name}"),
                  children: List.generate(bisnis.arrSub.length, (index) {
                    BBisnisSub sub = bisnis.arrSub[index];
                    return Row(children: [
                      Wgt.spaceLeft(30),
                      Expanded(
                          child: Container(
                              padding: EdgeInsets.all(20),
                              child: Wgt.text(context, "${sub.name}"))),
                    ]);
                  })));
        }));
  }

  Future doGetCity() {
    return Logic(context).getCity(
        key: "",
        success: (json) {
          suggestions.clear();
          for (var item in json["data"]) {
            String name = item["name"];
            String id = "${item["id"]}";
            suggestions[name] = id;
          }
          // customAutocomplete.suggestions = suggestions.keys.toList();
          setState(() {});
        });
  }

  void doSignup() {
    String txtAutoComplete = contAutocomplete.text;
    String idCity = suggestions[txtAutoComplete];
    if (txtAutoComplete.isEmpty || idCity == null) {
      Helper.toastError(context, "Invalid city");
      return;
    }

    dataRegister["business_name"] = contNama.text;
    dataRegister["business_type"] = ddCustom.selectedBisnis.id;
    dataRegister["business_type_id"] = ddCustom.selectedSub.id;
    dataRegister["city_id"] = "$idCity";
    switch (step) {
      case 1:
        step += 1;
        setState(() {});
        break;

      case 2:
        doWsSignup();
        break;

      case 3:
        if (contTelp.text.isEmpty) {
          Helper.toastError(context, "Please provide no. handphone");
          return;
        }
        dataRegister["phone"] = contTelp.text;
        doWsSignup();
        break;
    }
  }

  Future<void> doWsSignup() async {
    if (!await Helper.validateInternet(context)) return;

    Helper.showProgress(context);
    Logic(context)
        .signup(
            data: dataRegister,
            success: (json) async {
              // Do something, kalo udah sukses
              if (json["access_token"] == null) {
                // Register gagal
                Map j = json;
                j.forEach((key, value) {
                  if (value.runtimeType == String) {
                    Helper.toastError(context, "$value");
                  } else {
                    for (var i in value) {
                      Helper.toastError(context, "$i");
                      break;
                    }
                  }

                  return;
                });
              } else {
                // Helper.popupDialog(context, title: "Sukses", text: "Pendaftaran sukses!");

                UserManager.clearDataNewDevice();

                Logic.ACCESS_TOKEN = json["access_token"];
                await UserManager.saveString(
                    UserManager.ACCESS_TOKEN, json["access_token"]);

                navOutlet();
              }
              // Helper.hideProgress(context);
            })
        .then((value) {
      Helper.hideProgress(context);
    });
  }

  void doShowSukses() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 5,
            child: Container(
                padding: EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Wgt.text(context, "Pendaftaran Sukses"),
                  Wgt.spaceTop(5),
                  Icon(Icons.check_circle, color: Cons.COLOR_PRIMARY, size: 50),
                ]))));
  }

  void navOutlet() {
    Helper.openPageNoNav(context, Outlet());
    Helper.openPage(context, Main.OUTLET);
    doShowSukses();
  }
}

class DDCustom extends StatefulWidget {
  List<BBisnis> arrBisnis = List();
  BBisnis selectedBisnis;
  BBisnisSub selectedSub;
  bool isExpanded = false;
  var listenerSelect;

  DDCustom({this.arrBisnis, this.listenerSelect});

  @override
  _DDCustomState createState() => _DDCustomState();
}

class _DDCustomState extends State<DDCustom> {
  int _activeMeterIndex;
  @override
  Widget build(BuildContext context) {
    String bisName =
        widget.selectedBisnis != null ? widget.selectedBisnis.name : "";
    String subName = widget.selectedSub != null ? widget.selectedSub.name : "";
    var selectedName =
        bisName.isNotEmpty && subName.isNotEmpty ? "$bisName // $subName" : "";
    /*
    return ExpansionTile(
        title: Wgt.text(context, "$selectedName"),
        children: List.generate(widget.arrBisnis.length, (index) {
          BBisnis bisnis = widget.arrBisnis[index];
          return ExpansionTile(
              title: Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Wgt.text(context, "${bisnis.name}", weight: FontWeight.bold)),
              children: List.generate(bisnis.arrSub.length, (index) {
                BBisnisSub sub = bisnis.arrSub[index];
                return Row(children: [
                  Expanded(
                      child: InkWell(
                    onTap: () => select(bisnis: bisnis, sub: sub),
                    child: Container(
                        padding: EdgeInsets.only(left: 50, top: 10, bottom: 10),
                        child: Wgt.text(context, "${sub.name}")),
                  ))
                ]);
              }));
        }));
        */

    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: ExpansionPanelList(
                elevation: 0,
                expansionCallback: (i, expanded) {
                  widget.isExpanded = !widget.isExpanded;
                  setState(() {});
                },
                children: [
                  ExpansionPanel(
                      canTapOnHeader: true,
                      isExpanded: widget.isExpanded,
                      headerBuilder: (context, index) {
                        return Row(children: [
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(left: 20),
                                  child: selectedName == ""
                                      ? Wgt.text(context, "Jenis Bisnis",
                                          color: Colors.grey)
                                      : Wgt.text(context, "$selectedName",
                                          maxlines: 2)))
                        ]);
                      },
                      body: ExpansionPanelList(
                          expansionCallback: (i, isExpanded) {
                            if (!isExpanded)
                              _activeMeterIndex = i;
                            else
                              _activeMeterIndex = null;
                            setState(() {});
                          },
                          children: List.generate(widget.arrBisnis.length, (i) {
                            BBisnis bisnis = widget.arrBisnis[i];
                            return ExpansionPanel(
                                canTapOnHeader: true,
                                isExpanded: _activeMeterIndex == i,
                                headerBuilder: (context, isExpanded) {
                                  return Center(
                                      child: Row(children: [
                                    Expanded(
                                        child: Container(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Wgt.text(
                                                context, "${bisnis.name}",
                                                weight: FontWeight.bold))),
                                  ]));
                                },
                                body: Container(
                                    child: Column(
                                        children: List.generate(
                                            bisnis.arrSub.length, (index) {
                                  BBisnisSub sub = bisnis.arrSub[index];
                                  return InkWell(
                                      onTap: () =>
                                          select(bisnis: bisnis, sub: sub),
                                      child: Row(children: [
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 30,
                                                    top: 10,
                                                    bottom: 10),
                                                child: Wgt.text(
                                                    context, "${sub.name}"))),
                                      ]));
                                }))));
                          })))
                ])));
  }

  void select({BBisnis bisnis, BBisnisSub sub}) {
    if (bisnis == null || sub == null) return;
    widget.selectedBisnis = bisnis;
    widget.selectedSub = sub;
    _activeMeterIndex = null;

    widget.listenerSelect();

    widget.isExpanded = false;
    setState(() {});
  }
}
