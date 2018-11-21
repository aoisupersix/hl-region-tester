//
//  ViewController.swift
//  HlRegionTester
//
//  Created by aoisupersix on 2018/11/21.
//  Copyright © 2018 田中葵. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    @IBOutlet var minuteLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var millSecondLabel: UILabel!
    
    weak var timer: Timer!
    var startTime = Date()
    
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()
        ref = Database.database().reference()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.notDetermined) {
            self.locationManager.requestAlwaysAuthorization()
        }
        // ビーコン領域を作成
        let uuid = UUID(uuidString: "2F0B0D9B-B52C-47BF-B5B8-2BFBCE094653")
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: 1, minor: 1, identifier: "identifier")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
    }
    
    @IBAction func startTimer(_ sender: Any) {
        // タイマーが起動中なら一旦破棄
        if timer != nil {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(self.timerCounter),
            userInfo: nil,
            repeats: true)
        
        startTime = Date()
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        if timer != nil {
            timer.invalidate()
            
            minuteLabel.text = "00"
            secondLabel.text = "00"
            millSecondLabel.text = "00"
        }
    }
    
    @IBAction func changeStatusToIn(_ sender: Any) {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let key = ref.child("developer_test").childByAutoId().key
        let content = ["type": "侵入",
                       "date": f.string(from: now)]
        
        ref.child("developer_test/\(key)").updateChildValues(content)
        
        statusLabel.text = "侵入"
    }
    @IBAction func changeStatusToOut(_ sender: Any) {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let key = ref.child("developer_test").childByAutoId().key
        let content = ["type": "退出",
                       "date": f.string(from: now)]
        
        ref.child("developer_test/\(key)").updateChildValues(content)
        
        statusLabel.text = "退出"
    }
    
    @objc func timerCounter() {
        let currentTime = Date().timeIntervalSince(startTime)
        
        let minute = (Int)(fmod((currentTime/60), 60))
        let second = (Int)(fmod(currentTime, 60))
        let msec = (Int)((currentTime - floor(currentTime))*100)
        
        let sMinute = String(format: "%02d", minute)
        let sSecond = String(format: "%02d", second)
        let sMSecond = String(format: "%02d", msec)
        
        minuteLabel.text = sMinute
        secondLabel.text = sSecond
        millSecondLabel.text = sMSecond
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            locationManager.startRangingBeacons(in: self.beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if (beacons.count == 0) { return }
        let beacon = beacons[0] as CLBeacon
        
        var distance = ""
        switch(beacon.proximity) {
        case .unknown:
            distance = "unknown"
            break
        case .immediate:
            distance = "immediate"
            break
        case .far:
            distance = "far"
            break
        case .near:
            distance = "near"
            break
        }
        
        rssiLabel.text = String(beacon.rssi) + ", " + distance
    }
}

