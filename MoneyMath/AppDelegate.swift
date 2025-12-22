//
//  AppDelegate.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//

import SwiftUI
import AdsFramework
import AppTrackingTransparency

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Adster SDK at app start
        initializeAdsterSDK()
        return true
    }

    private func initializeAdsterSDK() {
        // Request ATT authorization first, then initialize SDK
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("ATT: Authorised")
                case .notDetermined:
                    print("ATT: not determined")
                case .restricted:
                    print("ATT: restricted")
                case .denied:
                    print("ATT: denied")
                @unknown default:
                    print("ATT: unknown")
                }

                // Initialize Adster SDK
                AdSter.sharedInstance().start(completionHandler: { status in
                    if let status {
                        print("Adster SDK initialized: \(status)")
                    }
                })
            }
        }
    }

}
