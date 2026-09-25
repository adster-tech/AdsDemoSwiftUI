//
//  MainViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Adverge on 10/03/25.
//
import Combine

class MainViewModel: ObservableObject {
    let sdkTypes: [[SdkType]] = [
        [.gam, .admob, .adverge],
        [.advergeDirect, .amazon, .applovin],
        [.liftoff, .adsease, .inmobi],
        [.unity, .meta]
    ]
    let sdkAdTypes: [[SdkAdType]] = [
        [.banner, .interstitial, .rewarded],
        [.rewardedInterstitial, .native, .nativeReward],
        [.appopen, .carouselBanner, .carouselNative],
        [.customNative, .fsn, .unified],
        [.video]
    ]
    
    @Published private(set) var selectedSdkType = SdkType.gam
    @Published private(set) var selectedAdType = SdkAdType.banner
    @Published private(set) var selectedKey: String? = nil
    @Published var isLinkClicked: Bool = false

    var selectedKeyIndexes: [Int] {
        switch selectedAdType {
        case .carouselBanner, .carouselNative:
            return [0]
        default:
            return Array(0..<10)
        }
    }
    
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
