//
//  WifiManager.swift
//  Swift_wifi_SSID
//
//  Created by shin seunghyun on 2020/04/20.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork


class WifiVC: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }
    
    
    func getCurrentSSID() -> String? {
    //ios 13버전 이상
        if #available(iOS 13.0, *) {
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedWhenInUse {
                let currentNetworkInfos: Array<NetworkInfo>?  = SSID.fetchNetworkInfo()
                if let ssid: String = currentNetworkInfos?.first?.ssid {
                    return ssid
                }
                return nil
            } else {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            }
            //ios 13버전 이전
        } else {
            let currentNetworkInfos: Array<NetworkInfo>?  = SSID.fetchNetworkInfo()
            if let ssid: String = currentNetworkInfos?.first?.ssid {
                return ssid
            }
            return nil
        }
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            
        }
    }
    
}



public class SSID {
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(interface: interfaceName,
                                              success: false,
                                              ssid: nil,
                                              bssid: nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkInfo)
            }
            return networkInfos
        }
        return nil
    }
}

struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
}
