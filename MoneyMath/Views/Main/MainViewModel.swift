//
//  MainViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Razorpay on 10/03/25.
//
import Combine

class MainViewModel: ObservableObject {
    let sdkTypes: [[SdkType]] = [
        [.gam, .admob, .razorpay],
        [.razorpayDirect, .amazon, .applovin],
        [.liftoff, .adsease, .inmobi],
        [.unity, .meta]
    ]
    let sdkAdTypes: [[SdkAdType]] = [
        [.banner, .interstitial, .rewarded],
        [.rewardedInterstitial, .native, .nativeReward],
        [.appopen, .carouselBanner, .carouselNative],
        [.customNative, .fsn, .unified],
        [.video, .carouselCustomNative, .carouselNativeReward]
    ]
    
    @Published private(set) var selectedSdkType = SdkType.gam
    @Published private(set) var selectedAdType = SdkAdType.banner
    @Published private(set) var selectedKey: String? = nil
    @Published var isLinkClicked: Bool = false
    @Published var nativeAdSize: NativeAdSize = .big

    var showsNativeSize: Bool { selectedAdType == .native || selectedAdType == .customNative }

    var selectedKeyIndexes: [Int] {
        switch selectedAdType {
        case .carouselCustomNative, .carouselNativeReward:
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
