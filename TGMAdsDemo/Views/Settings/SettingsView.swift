//
//  SettingsView.swift
//  TGMAdsDemo
//
//  Created by TGM on 21/08/25.
//

import SwiftUI

struct SettingsView: View {
    var items: [SettingsViewType] {
        var base: [SettingsViewType] = [.about]
        if showTGM || Bundle.main.isDebugOrTestFlight {
            base.append(.tgm)
            base.append(.googleAdManager)
        }
        return base
    }
    
    private let showTGM = true
    
    
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
    }
    
    @ViewBuilder
    private func destination(for item: SettingsViewType) -> some View {
        switch item {
        case .tgm:
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
    case tgm = "Ads"
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
