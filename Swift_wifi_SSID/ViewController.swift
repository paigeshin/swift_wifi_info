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
        
        print(getCurrentSSID())
    }

}

