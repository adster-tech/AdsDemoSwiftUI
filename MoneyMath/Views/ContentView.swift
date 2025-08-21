//
//  ContentView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 21/08/25.
//

import SwiftUI
import AdsFramework

struct ContentView: View {
    @State var hasAppeared = false
    
    var body: some View {
        TabView {
            EMIView()
                .tabItem {
                    Label("EMI", systemImage: "chart.xyaxis.line")
                }
            SICalcView()
                .tabItem {
                    Label("Interest", systemImage: "hourglass.badge.plus")
                }
            SettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
        }
        .accentColor(.blue)
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            AdSter.sharedInstance().start(completionHandler: { status in
                if let status {
                    print("Ad initialized \(status)")
                }
            })
        }
    }
}
