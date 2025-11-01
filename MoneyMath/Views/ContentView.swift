//
//  ContentView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 21/08/25.
//

import SwiftUI
import AdsFramework

struct ContentView: View {
    
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
    }
}
