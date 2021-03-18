import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pawoon/Helper/Helper.dart';
import 'package:pawoon/Helper/Logic.dart';
import 'package:pawoon/Helper/UserManager.dart';
import 'package:pawoon/Helper/Wgt.dart';
import 'package:pawoon/Views/Operator.dart';

import 'Intro.dart';
import 'Outlet.dart';

class Base extends StatelessWidget {
  const Base({Key key}) : super(key: key);
  static var context;
  static var context2;
  static var page_tag = "";
  static var broadcast;
  static Map<String, Timer> mapTimerAcceptOrder = Map();

  @override
  Widget build(BuildContext context) {
    // Helper.closePage(context);
    Base.context = context;

    redirect(context);
    return Wgt.base(context);
  }

  void redirect(context) {
    Helper.subscribeToFirebase(context);

    UserManager.getBool(UserManager.IS_LOGGED_IN).then((value) async {
      if (value == null || !value) {
        Helper.openPageNoNav(context, Intro());
      } else {
        var assignmentToken =
            await UserManager.getString(UserManager.ASSIGNMENT_TOKEN);
        var outletobj = await UserManager.getString(UserManager.OUTLET_OBJ);
        var deviceobj = await UserManager.getString(UserManager.DEVICE_OBJ);

        if (assignmentToken != null && assignmentToken != "") {
          Logic.ASSIGNMENT_TOKEN = assignmentToken;
        }
        Logic.ACCESS_TOKEN = await UserManager.getToken();

        if (outletobj != null &&
            outletobj != "" &&
            deviceobj != null &&
            deviceobj != "") {
          Helper.openPageNoNav(context, Operator(firstPage: true));
        } else {
          Helper.openPageNoNav(context, Outlet());
        }
        // UserManager.getString(UserManager.ASSIGNMENT_TOKEN).then((value) async {
        // });
      }
    });
  }
}
