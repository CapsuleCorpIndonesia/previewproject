import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawoon/Helper/Wgt.dart';

class BillingMidtrans extends StatefulWidget {
  @override
  _BillingMidtransState createState() => _BillingMidtransState();
}

class _BillingMidtransState extends State<BillingMidtrans> {
  @override
  Widget build(BuildContext context) {
    return Wgt.base(context,
        appbar: Wgt.appbar(context, name: "midtrans"),
        body: Center(child: Wgt.btn(context, "test", onClick: () => _getBatteryLevel())));
  }
  
  static const platform = const MethodChannel('com.pawoon.pos/midtrans');
   // Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      var result = await platform.invokeMethod('midtrans',{"text":"hehe"});
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
      print("$_batteryLevel");
    });
  }

  void test() {
    
    //
  }
  
}
