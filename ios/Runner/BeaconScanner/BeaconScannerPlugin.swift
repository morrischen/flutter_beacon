//
//  BeaconScannerPlugin.swift
//  Runner
//
//  Created by itrd-morris on 2025/1/24.
//

// Flutter 插件的註冊類
class BeaconScannerPlugin: NSObject, FlutterPlugin {
    private var beaconScanner: BeaconScanner?
    private let channel: FlutterMethodChannel

    // 初始化時綁定 MethodChannel
    init(messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(name: "com.example.flutterBeacon/beacon_scanner_plugin", binaryMessenger: messenger)
        super.init()
        self.beaconScanner = BeaconScanner(flutterChannel: channel)
    }

    // 透過 instance 方式註冊 Plugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = BeaconScannerPlugin(messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
    }

    // 處理 Flutter 傳來的 method calls
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMonitoringRegion":
            beaconScanner?.startMonitoringRegion()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
