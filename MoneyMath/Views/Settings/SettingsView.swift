//
//  SettingsView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 21/08/25.
//

import SwiftUI
import AdsFramework
import AppTrackingTransparency

struct SettingsView: View {
    var items: [SettingsViewType] {
        var base: [SettingsViewType] = [.about]
        if showAdster || Bundle.main.isDebugOrTestFlight {
            base.append(.adster)
            base.append(.googleAdManager)
        }
        return base
    }
    
    private let showAdster = true
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                NavigationLink(destination: destination(for: item)) {
                    Text(item.rawValue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            requestATT()
        }
    }
    
    func requestATT() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("ATT: Authorised")
                configure()
            case .notDetermined:
                print("ATT: not determined")
            case .restricted:
                print("ATT: restricted")
            case .denied:
                print("ATT: denied")
            @unknown default:
                print("ATT: unknown")
            }
        }
    }
    
    func configure() {
        AdSter.sharedInstance().start(completionHandler: { status in
            if let status {
                print("Ad initialized \(status)")
            }
        })
    }
    
    @ViewBuilder
    private func destination(for item: SettingsViewType) -> some View {
        switch item {
        case .adster:
            MainView(viewModel: .init())
        case .about:
            AboutView()
        case .googleAdManager:
            GoogleAdManagerView()
        }
    }
}

enum SettingsViewType: String, Hashable {
    case about = "About"
    case adster = "Ads"
    case googleAdManager = "Google Ad Manager"
}

extension Bundle {
    var isDebugOrTestFlight: Bool {
#if DEBUG
        return true
#else
        guard let url = appStoreReceiptURL else { return false }
        return url.lastPathComponent == "sandboxReceipt"
#endif
    }
}
