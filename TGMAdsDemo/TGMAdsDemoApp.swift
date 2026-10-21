//
//  TGMAdsDemoApp.swift
//  TGMAdsDemo
//
//  Created by TGM on 10/03/25.
//

import SwiftUI

@main
struct TGMAdsDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
