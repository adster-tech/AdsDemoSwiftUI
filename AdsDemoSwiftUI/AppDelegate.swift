//
//  AppDelegate.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//

import AdsFramework
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    let objAdster = AdsterProvider()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AdSter.sharedInstance().start(completionHandler: { status in
            if let status {
                print("Ad initialized \(status)")
            }
        })
        return true
    }
}
