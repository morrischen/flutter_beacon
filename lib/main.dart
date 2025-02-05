import 'dart:async';
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/beacon_scanner_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon 距離計算器',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BeaconScanner(),
    );
  }
}

class BeaconScanner extends StatefulWidget {
  @override
  _BeaconScannerState createState() => _BeaconScannerState();
}

class _BeaconScannerState extends State<BeaconScanner> {
  final StreamController<List<BeaconData>> _beaconsController =
      StreamController<List<BeaconData>>.broadcast();
  List<BeaconData> _beacons = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
    // _initBeaconScanner();
  }

  Future<void> _startMonitoring() async {
    // 請求必要權限
    await _requestPermissions();
    try {
      // 初始化插件
      final beaconScannerPlugin = BeaconScannerPlugin();
      await beaconScannerPlugin.init();
      await beaconScannerPlugin.startMonitoringRegion();
      // 設置 beacons 監聽
      beaconScannerPlugin.onBeaconsRanged = (beacons) {
        print('Received beacons: $beacons');
        // 處理接收到的 beacons 數據
        if (mounted) {
          final beaconData = beacons
              .map((result) => BeaconData(
                    uuid: result.proximityUUID,
                    rssi: result.rssi,
                    distance: result.accuracy,
                  ))
              .toList();

          setState(() {
            _beacons = beaconData;
          });
          _beaconsController.add(beaconData);
        }
      };
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _initBeaconScanner() async {
    // 請求必要權限
    await _requestPermissions();
    // 初始化 flutter_beacon
    try {
      await flutterBeacon.setScanPeriod(1000);
      await flutterBeacon.setBetweenScanPeriod(500);
      await flutterBeacon.initializeScanning;
      // 監聽 beacon 廣播
      flutterBeacon.ranging(
        [
          Region(
            identifier: 'MyBeacon',
            proximityUUID: 'fda50693-a4e2-4fb1-afcf-c6eb07647825',
            major: 10001,
            minor: 22688,
          ),
        ],
      ).listen((results) {
        print('Received beacons: ${results.beacons}');
        if (mounted) {
          final beacons = results.beacons
              .map((result) => BeaconData(
                    uuid: result.proximityUUID,
                    rssi: result.rssi,
                    distance: result.accuracy,
                  ))
              .toList();

          setState(() {
            _beacons = beacons;
          });
          _beaconsController.add(beacons);
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
  }

  String _getAccuracyLevel(int rssi) {
    if (rssi >= -50) return '高';
    if (rssi >= -70) return '中';
    return '低';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon 距離計算器'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BeaconData>>(
        stream: _beaconsController.stream,
        initialData: _beacons,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('未檢測到 Beacon'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final beacon = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('UUID: ${beacon.uuid}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RSSI: ${beacon.rssi} dBm'),
                      Text('估計距離: ${beacon.distance.toStringAsFixed(2)} 公尺'),
                      Text('準確度: ${_getAccuracyLevel(beacon.rssi)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _beaconsController.close();
    super.dispose();
  }
}

class BeaconData {
  final String uuid;
  final int rssi;
  final double distance;

  BeaconData({
    required this.uuid,
    required this.rssi,
    required this.distance,
  });
}
