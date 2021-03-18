import UIKit
import Flutter
import Firebase
import MidtransKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // // Hybrid test --------------
    // let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    //    let batteryChannel = FlutterMethodChannel(name: "com.pawoon.pos/midtrans",
    //                                              binaryMessenger: controller.binaryMessenger)
    //    batteryChannel.setMethodCallHandler({
    //     [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
    //      // Note: this method is invoked on the UI thread.

    //      guard call.method == "midtrans" else {
    //         result(FlutterMethodNotImplemented)
    //         return
    //      }
    //      guard let args = call.arguments else {
    //       result("iOS could not recognize flutter arguments in method: (sendParams)") 
    //       return
    //      }
    //     //  let text = args["text"]
    //     //  result("\(args["text"]?? "") heeee")
    //     //  self?.receiveBatteryLevel(result: result, text: text)
    //    })
    // // Hybrid end --------------
    
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  // func initMidtrans(){
  //   MidtransConfig.shared().setClientKey("SB-Mid-client-WNkot0AVHheEzN6S", environment: .sandbox, merchantServerURL: "https://api-staging.pawoon.com/v2/billing-v2/midtrans")

//     let itemDetail = MidtransItemDetail.init(itemID: item_id, name: item_name, price: item_price, quantity: item_qty)

// let customerDetail = MidtransCustomerDetails.init(firstName: first_name, lastName: last_name, email: email_addr, phone: phone_number, shippingAddress: ship_addr, billingAddress: bill_addr)

// let transactionDetail = MidtransTransactionDetails.init(orderID: order_ir, andGrossAmount: gross_amount)

// MidtransMerchantClient.shared().requestTransactionToken(with: transactionDetail!, itemDetails: [itemDetail!], customerDetails: customerDetail) { (response, error) in
// 	if (response != nil) {
// 		//handle response                
//     }
//     else {        
//     	//handle error
//     }
// }
  // }
}
