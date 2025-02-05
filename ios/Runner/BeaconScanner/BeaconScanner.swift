//
//  BeaconScanner.swift
//  Runner
//
//  Created by itrd-morris on 2025/1/24.
//

import Flutter
import CoreLocation

class BeaconScanner: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: CLLocationManager!
    private var flutterChannel: FlutterMethodChannel!


    init(flutterChannel: FlutterMethodChannel) {
        super.init()
        self.flutterChannel = flutterChannel
        locationManager = CLLocationManager()
        locationManager.delegate = self
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoringRegion() {
        let uuid = UUID(uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825")!
        let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: 10001, minor: 22688)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint, identifier: uuid.uuidString)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true

        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: beaconConstraint)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if !beacons.isEmpty {
            // 將 beacons 轉換為可序列化的資料結構並傳遞給 Flutter
            let beaconData = beacons.map { beacon in
                return [
                    "proximityUUID": beacon.uuid.uuidString,
                    "major": beacon.major.intValue,
                    "minor": beacon.minor.intValue,
                    "rssi": beacon.rssi,
                    "accuracy": beacon.accuracy,
                    "proximity": beacon.proximity.rawValue
                ]
            }
            flutterChannel.invokeMethod("didRangeBeacons", arguments: beaconData)
        }
    }
}
