import 'package:flutter/material.dart';
import 'package:pawoon/Helper/Cons.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/Wgt.dart';

import 'Base.dart';

class Forgot extends StatefulWidget {
  Forgot({Key key}) : super(key: key);

  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  TextEditingController contEmail = TextEditingController();
  CustomInput inputEmail;
  bool validInput = false;
  @override
  void initState() {
    super.initState();
    inputEmail = CustomInput(
        hint: "Email",
        type: TextInputType.emailAddress,
        controller: contEmail,
        validator: (text) {
          validInput = false;
          if (text == "") return "*Tidak boleh kosong";
          if (!Helper.validateEmail(text)) return "*Format salah";

          validInput = true;
          setState(() {});
          return "";
        });
  }

  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "Lupa password"), body: body());
  }

  Widget body() {
    return InkWell(
        // onTap: () => doShowSukses(),
        child: Center(
            child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: SingleChildScrollView(
                    child: Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                  Wgt.spaceTop(40),
                  // Expanded(child: Container()),
                  Image.asset("assets/logo_pawoon.png", height: 40),
                  Wgt.spaceTop(50),
                  inputEmail,
                  Wgt.spaceTop(30),
                  Row(children: [
                    Expanded(
                        child: Wgt.btn(context, "RESET PASSWORD",
                            enabled: validInput, onClick: () => doReset())),
                  ]),
                  // Expanded(child: Container()),
                  Wgt.spaceTop(40),
                ]))))));
  }

  void doShowSukses() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 5,
            child: Column(
              children: [
                Expanded(child: Container()),
                Container(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        Wgt.text(context, "Cek Email Anda",
                            size: Wgt.FONT_SIZE_LARGE, color: Colors.grey[700]),
                        Wgt.spaceTop(10),
                        Image.asset("assets/ic_mail.png", height: 30),
                        Wgt.spaceTop(20),
                        Wgt.text(context,
                            "Petunjuk reset password akun anda\ntelah dikirim ke",
                            size: Wgt.FONT_SIZE_NORMAL_2,
                            align: TextAlign.center,
                            color: Colors.grey[700]),
                        Wgt.spaceTop(10),
                        Wgt.textLarge(context, "${contEmail.text}",
                            weight: FontWeight.bold),
                        Wgt.spaceTop(20),
                        Row(children: [
                          Expanded(
                              child: Wgt.btn(context, "MASUK KE PAWOON",
                                  onClick: () =>
                                      Helper.closePage(Base.context)))
                        ])
                      ])),
                ),
                Expanded(child: Container()),
              ],
            )));
  }

  Future<void> doReset() async {
    if (contEmail.text.isEmpty) {
      Helper.toastError(context, "Email kosong");
      return;
    }

    if (!Helper.validateEmail(contEmail.text)) {
      Helper.toastError(context, "Invalid email");
      return;
    }
    if (!await Helper.validateInternet(context)) return;
    
    // FOrgot pass belum ada webservice
    Helper.showProgress(context);
    Logic(context)
        .forgot(
            email: contEmail.text,
            success: (json) {
              Helper.toastSuccess(context, "Please check your email");
              Helper.closePage(context);
              doShowSukses();
            },
            err: (err) {
              Helper.popupDialog(context, text: "Email not found");
            })
        .then((value) {
      Helper.hideProgress(context);
    });
  }
}
