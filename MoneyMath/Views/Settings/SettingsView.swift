//
//  SettingsView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 21/08/25.
//

import SwiftUI

struct SettingsView: View {
    var items: [SettingsViewType] {
        var base: [SettingsViewType] = [.about]
        if showAdster || Bundle.main.isDebugOrTestFlight {
            base.append(.adster)
        }
        return base
    }
    
    private let showAdster = true
    
    
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
        case .adster:
            MainView(viewModel: .init())
        case .about:
            AboutView()
        }
    }
}

enum SettingsViewType: String, Hashable {
    case about = "About"
    case adster = "Ads"
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
