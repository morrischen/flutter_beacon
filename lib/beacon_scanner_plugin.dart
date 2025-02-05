import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:flutter/services.dart';

class BeaconScannerPlugin {
  final MethodChannel _channel =
      const MethodChannel('com.example.flutterBeacon/beacon_scanner_plugin');

  // 設置監聽 beacons 的回調
  void Function(List<Beacon>)? onBeaconsRanged;

  Future<void> init() async {
    // 設置方法調用處理器
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'didRangeBeacons':
          if (onBeaconsRanged != null) {
            final beacons = Beacon.beaconFromArray(call.arguments);
            onBeaconsRanged!(beacons);
          }
          break;
      }
    });
  }

  // 開始監控區域的方法
  Future<void> startMonitoringRegion() async {
    await _channel.invokeMethod('startMonitoringRegion');
  }
}
