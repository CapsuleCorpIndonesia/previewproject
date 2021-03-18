import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:catcher/core/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/handlers/email_manual_handler.dart';
import 'package:catcher/mode/dialog_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pawoon/Views/BayarSukses.dart';
import 'package:pawoon/Views/BillingMidtrans.dart';
import 'package:pawoon/Views/BillingPaymentMethod.dart';
import 'package:pawoon/Views/InfoBisnis.dart';
import 'package:pawoon/Views/InputPin.dart';
import 'package:pawoon/Views/OrderOnline.dart';
import 'package:pawoon/Views/PaymentGateway.dart';
import 'package:pawoon/Views/PaymentOvo.dart';
import 'package:pawoon/Views/PrinterWifi.dart';
import 'package:pawoon/Views/Saved.dart';

import 'Helper/AppBuilder.dart';
import 'Helper/Cons.dart';
import 'Helper/Helper.dart';
import 'Views/Base.dart';
import 'Views/Bayar.dart';
import 'Views/Billing.dart';
import 'Views/BillingBCA.dart';
import 'Views/Device.dart';
import 'Views/Forgot.dart';
import 'Views/History.dart';
import 'Views/Intro.dart';
import 'Views/JenisBayar.dart';
import 'Views/Login.dart';
import 'Views/Meja.dart';
import 'Views/MejaEdit.dart';
import 'Views/Operator.dart';
import 'Views/Order.dart';
import 'Views/Outlet.dart';
import 'Views/Pelanggan.dart';
import 'Views/PrinterDetails.dart';
import 'Views/PrinterLogic.dart';
import 'Views/Rekap.dart';
import 'Views/Report.dart';
import 'Views/Setting.dart';
import 'Views/Signup.dart';
import 'Views/SplitPayment.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupFCM();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light));
  // await SystemChrome.setPreferredOrientations([
  //   // DeviceOrientation.landscapeRight,
  //   DeviceOrientation.landscapeLeft,
  // ]);
  CatcherOptions debugOptions = CatcherOptions(DialogReportMode(), [
    ConsoleHandler(),
    EmailManualHandler(["exruinz@gmail.com"])
  ]);

  /// STEP 2. Pass your root widget (MyApp) along with Catcher configuration:

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitDown,
    //  DeviceOrientation.portraitUp,
  ]).then((value) => runApp(AppBuilder(builder: (context) {
        Widget app = OKToast(
            child: MaterialApp(
                navigatorKey: navigatorKey,
                // navigatorKey: Catcher.navigatorKey,
                debugShowCheckedModeBanner: false,
                builder: BotToastInit(),
                navigatorObservers: [
                  BotToastNavigatorObserver()
                ], //2. registered route observer

                darkTheme: ThemeData(
                    backgroundColor: Cons.COLOR_BG,
                    primarySwatch: Colors.greenAccent[600],
                    fontFamily: 'Avenir',
                    textTheme: TextTheme(
                        body1: TextStyle(fontSize: 17),
                        body2: TextStyle(fontSize: 17))),
                theme: ThemeData(
                    backgroundColor: Cons.COLOR_BG,
                    primarySwatch: Colors.lightBlue,
                    fontFamily: 'Avenir',
                    textTheme: TextTheme(
                        body1: TextStyle(fontSize: 17),
                        body2: TextStyle(fontSize: 17))),
                title: 'Pawoon',
                initialRoute: Main.INTRO,
                routes: {
                  Main.HOME: (context) => Base(),
                  Main.INTRO: (context) => Intro(),
                  Main.SIGNUP: (context) => Signup(),
                  Main.LOGIN: (context) => Login(),
                  Main.FORGOT: (context) => Forgot(),
                  Main.OUTLET: (context) => Outlet(),
                  Main.DEVICE: (context) => Device(),
                  Main.OPERATOR: (context) => Operator(),
                  Main.INPUT_PIN: (context) => InputPin(),
                  Main.ORDER: (context) => Order(),
                  Main.INFO_BISNIS: (context) => InfoBisnis(),
                  Main.BAYAR: (context) => Bayar(),
                  Main.JENIS_BAYAR: (context) => JenisBayar(),
                  Main.BAYAR_SUKSES: (context) => BayarSukses(),
                  Main.SPLIT_PAYMENT: (context) => SplitPayment(),
                  Main.SAVED: (context) => Saved(),
                  Main.SETTING: (context) => Setting(),
                  Main.HISTORY: (context) => History(),
                  Main.PELANGGAN: (context) => Pelanggan(),
                  Main.REKAP: (context) => Rekap(),
                  Main.REPORT: (context) => Report(),
                  Main.MEJA: (context) => Meja(),
                  Main.MEJA_EDIT: (context) => MejaEdit(),
                  Main.PRINTER_LOGIC: (context) => PrinterLogic(),
                  Main.PAYMENT_GATEWAY: (context) => PaymentGateway(),
                  Main.PAYMENT_GATEWAY_OVO: (context) => PaymentOvo(),
                  Main.ORDER_ONLINE: (context) => OrderOnline(),
                  Main.PRINTER_WIFI: (context) => PrinterWifi(),
                  Main.PRINTER_DETAILS: (context) => PrinterDetails(),
                  Main.BILLING: (context) => Billing(),
                  Main.BILLING_BCA: (context) => BillingBCA(),
                  Main.BILLING_MIDTRANS: (context) => BillingMidtrans(),
                  Main.BILLING_PAYMENT_METHOD: (context) =>
                      BillingPaymentMethod(),
                }));
        Catcher(
          rootWidget: app,
          // debugConfig: debugOptions,
          // enableLogger: true,
          // navigatorKey: navigatorKey,
        );

        return app;
      })));
}

class Main {
  static const String HOME = "/";
  static const String INTRO = "/Intro";
  static const String SIGNUP = "/Signup";
  static const String LOGIN = "/Login";
  static const String FORGOT = "/Forgot";
  static const String OUTLET = "/Outlet";
  static const String DEVICE = "/Device";
  static const String OPERATOR = "/Operator";
  static const String INPUT_PIN = "/InputPin";
  static const String ORDER = "/Order";
  static const String INFO_BISNIS = "/InfoBisnis";
  static const String BAYAR = "/Bayar";
  static const String JENIS_BAYAR = "/JenisBayar";
  static const String BAYAR_SUKSES = "/BayarSukses";
  static const String SPLIT_PAYMENT = "/SplitPayment";
  static const String SAVED = "/TransaksiTersimpan";
  static const String SETTING = "/Setting";
  static const String HISTORY = "/History";
  static const String PELANGGAN = "/Pelanggan";
  static const String REKAP = "/Rekap";
  static const String REPORT = "/Report";
  static const String MEJA = "/Meja";
  static const String MEJA_EDIT = "/MejaEdit";
  static const String PRINTER_LOGIC = "/PrinterSearch";
  static const String PRINTER_WIFI = "/PrinterWifi";
  static const String PRINTER_DETAILS = "/PrinterDetails";
  static const String PAYMENT_GATEWAY = "/PaymentGateway";
  static const String PAYMENT_GATEWAY_OVO = "/PaymentGatewayOvo";
  static const String ORDER_ONLINE = "/OrderOnline";
  static const String BILLING = "/Billing";
  static const String BILLING_PAYMENT_METHOD = "/BillingPaymentMethod";
  static const String BILLING_BCA = "/BillingBCA";
  static const String BILLING_MIDTRANS = "/BillingMidtrans";
}

// ------- FIREBASE --------
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void setupFCM() {
  firebaseCloudMessaging_Listeners();
}

void firebaseCloudMessaging_Listeners() {
  if (Platform.isIOS) iOS_Permission();

  _firebaseMessaging.getToken().then((token) {
    print(token);
  });
}

void iOS_Permission() {
  _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true));
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    print("Settings registered: $settings");
  });
}
