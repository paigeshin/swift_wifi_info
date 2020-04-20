# swift_wifi_info

# 설명 필요 없이 그냥 쓰고 싶은 경우

**I.** info.plist 에서 Privacy - Location When In Use Usage Description 추가

**II.** Capability에서 Access Wifi Information 추가

**III.**  WifiVC.swift 파일 copy & paste 

**IV.**  쓰고자하는 ViewController에서 `WifiVC` 를 상속 받고, `getWifi()` 함수를 호출하면 된다.

        //
        //  ViewController.swift
        //  Swift_wifi_SSID
        //
        //  Created by shin seunghyun on 2020/04/20.
        //  Copyright © 2020 shin seunghyun. All rights reserved.
        //

        import UIKit

        class ViewController: WifiVC {

            override func viewDidLoad() {
                super.viewDidLoad()
                
                print(getWifi())
            }

        }



# Reference

[https://github.com/HackingGate/iOS13-WiFi-Info](https://github.com/HackingGate/iOS13-WiFi-Info)

# Notion

[https://www.notion.so/Swift-ios-get-wifi-f2f001efba14478296b338d24a57effd](https://www.notion.so/Swift-ios-get-wifi-f2f001efba14478296b338d24a57effd)

공유로 열어놨으니 위 notion link 타고 들어와서 보는게 더 좋습니다. 사진도 첨부했습니다.

# Wifi

## iOS 13 이전 버전

- ❗️Android에서는 모든 연결 가능한 wifi 정보를 가져올 수 있으나, iOS는 현재 연결된 wifi 정보만 가져올 수 있다.
- `SystemConfiguration.CaptiveNetwork` Framework를 가져온다.
- `CNCopyCurrentNetworkInfo` 라는 Object를 통해서 wifi 정보를 가져옴

### 함수로 정의하여 가져오기

    import Foundation
    import SystemConfiguration.CaptiveNetwork
    
    func getSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                            return ssid
                }
            }
        } 
    
            return nil 
            
    }

### extension에 변수로 정의하여 가져오기

    public var SSID: String? {
        get {
            if let interfaces = CNCopySupportedInterfaces() {
                let interfacesArray = interfaces.takeRetainedValue() as [String]
                if let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfacesArray.firstObject) {
                    let interfaceData = unsafeInterfaceData.takeRetainedValue() as Dictionary
                    return interfaceData["SSID"]
                }
            }
            return nil
        }
    }


## iOS 13 이후 버전

- `CoreLocation` Framework를 가져온다.
- `SystemConfiguration.CaptiveNetwork` Framework를 가져온다.
- `CNCopyCurrentNetworkInfo` 라는 Object를 통해서 wifi 정보를 가져옴

### 순서

**i.** info.plist 에서 Privacy - Location When In Use Usage Description 추가

**ii.** Capability에서 Access Wifi Information 추가

**iii.** 코드 작성

- 먼저 location permission을 물어봐야함
- 그리고 나서 `CNCopyCurrentNetworkInfo` 라는 Object를 통해서 wifi 정보에 access가 가능해진다.


## 코드 작성

1. Wifi 정보를 담아줄 Model Struct 작성

        struct NetworkInfo {
            var interface: String
            var success: Bool = false
            var ssid: String?
            var bssid: String?
        }

 2. SSID class를 만들고 static 함수를 만든다.

        import SystemConfiguration.CaptiveNetwork
        
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

3. `CoreLocation` 을 import하고  `CLLocationManagerDelegate` protocol을 가져온다

        import CoreLocation
        
        class ViewController: UIViewController, CLLocationManagerDelegate {
            
        }

4.  해당 정보를 가지고 오고 싶은 곳에 각각 `CLLocationManager` , `currentNetworkInfos` 를 정의 해준다.

        import CoreLocation
        
        class ViewController: UIViewController, CLLocationManagerDelegate {
            
            var locationManager = CLLocationManager()
            var currentNetworkInfos: Array<NetworkInfo>? {
                get {
                    return SSID.fetchNetworkInfo()
                }
            }
        
        }

 (4).  `permission status`를 `observe` 하는 `delegate method`를 통해서 SSID 를 가져온다 

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          if status == .authorizedWhenInUse {
              updateWiFi()
          }
    }

 5. UI화면이 로딩되기전에 화면을 loading 해주는 `viewDidLoad` 에 `iOS 13` 또는 이전 버전일 경우 어떤 식으로 와이파이 정보를 가져올 것인지 정의해준다

        override func viewDidLoad() {
                super.viewDidLoad()
                
                if #available(iOS 13.0, *) {
                    let status = CLLocationManager.authorizationStatus()
                    if status == .authorizedWhenInUse {
                        updateWiFi()
                    } else {
                        locationManager.delegate = self
                        locationManager.requestWhenInUseAuthorization()
                    }
                //ios 13버전
                } else {
                    updateWiFi()
                }
          }

        func updateWiFi() {
              print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")") 
        }

### 전체 코드

    //
    //  ViewController.swift
    //  Swift_wifi_SSID
    //
    //  Created by shin seunghyun on 2020/04/20.
    //  Copyright © 2020 shin seunghyun. All rights reserved.
    //
    
    import UIKit
    import CoreLocation
    import SystemConfiguration.CaptiveNetwork
    
    
    
    class ViewController: UIViewController, CLLocationManagerDelegate {
        
        var locationManager = CLLocationManager()
        var currentNetworkInfos: Array<NetworkInfo>? {
            get {
                return SSID.fetchNetworkInfo()
            }
        }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            if #available(iOS 13.0, *) {
                let status = CLLocationManager.authorizationStatus()
                if status == .authorizedWhenInUse {
                    updateWiFi()
                } else {
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                }
            //ios 13버전
            } else {
                updateWiFi()
            }
        }
        
        func updateWiFi() {
            print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")")
            
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                updateWiFi()
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

### 코드 수정

- nil 값을 return 하거나 ssid를 return
- 아래 두 개의 함수는 똑같은 말이 다르게 작성되있을 뿐이다.

        // conditional statement로 작성
        func getWifi() -> String? {
            if let ssid: String = currentNetworkInfos?.first?.ssid {
                return ssid
            }
            return nil
        }
          
        // guard 로 작성 
        func getWifi() -> String? {
            guard let ssid: String = currentNetworkInfos?.first?.ssid else { return nil}
            return ssid
        }

- 함수만 호출하여 ssid 가져오게 만들기

        func getWifi() -> String? {
                let currentNetworkInfos: Array<NetworkInfo>?  = SSID.fetchNetworkInfo()
                if let ssid: String = currentNetworkInfos?.first?.ssid {
                    return ssid
                }
              return nil
        }
        
        func getWifi() -> String? {
            let currentNetworkInfos: Array<NetworkInfo>?  = SSID.fetchNetworkInfo()
            guard let ssid: String = currentNetworkInfos?.first?.ssid else { return nil}
            return ssid
        }

- 그냥 아예 함수만 호출하여 ssid

        func getWifi() -> String? {
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

- 완전 모듈화
    - protocol 을 써야하기 때문에 그냥 함수만 호출해서 원하는 값을 가져오게하긴 불가능해서 inheritance를 이용함
    - 위 클래스를 상속 받으면 `getWifi()` 를 호출하면 Optional String이 결과값으로 나온다.

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
                
                
                func getWifi() -> String? {
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
                        //ios 13버전
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
