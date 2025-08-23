//
//  AdsDemoSwiftUIApp.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 10/03/25.
//

import SwiftUI

@main
struct AdsDemoSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
