import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      BeaconScannerPlugin.register(with: self.registrar(forPlugin: "com.example.flutterBeacon/beacon_scanner_plugin")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
