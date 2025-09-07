//
//  MainViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 10/03/25.
//
import Combine

class MainViewModel: ObservableObject {
    let sdkTypes: [[SdkType]] = [
        [.gam, .admob, .adster],
        [ .amazon, .applovin, .vungle],
        [.adsease, .inmobi, .unity],
        [.meta]
    ]
    let sdkAdTypes: [[SdkAdType]] = [
        [.banner, .interstitial, .rewarded],
        [.native, .appopen, .fsn],
        [.unified, .video]
    ]
    
    @Published private(set) var selectedSdkType = SdkType.gam
    @Published private(set) var selectedAdType = SdkAdType.banner
    @Published private(set) var selectedKey: String? = nil
    @Published var isLinkClicked: Bool = false
    
    func update(_ sdk: SdkType) {
        self.selectedSdkType = sdk
        self.selectedAdType = .banner
        self.selectedKey = nil
    }
    
    func update(_ ad: SdkAdType) {
        self.selectedAdType = ad
        self.selectedKey = nil
    }
    
    func select(_ key: String) {
        self.selectedKey = key
        self.isLinkClicked = true
    }
}
