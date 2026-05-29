//
//  SdkType.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 10/03/25.
//

enum SdkType: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case gam = "GAM"
    case admob = "AdMob"
    case meta = "Meta"
    case amazon = "Amazon"
    case liftoff = "LiftOff"
    case applovin = "Applovin"
    case inmobi = "InMobi"
    case unity = "Unity"
    case adsease = "Adsease"
    case adster = "Adster"
    case adsterDirect = "Adster-Direct"
}


enum SdkAdType: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }

    case banner = "Banner"
    case interstitial = "Interstitial"
    case rewarded = "Rewarded"
    case rewardedInterstitial = "RewardedInterstitial"
    case native = "Native"
    case carouselBanner = "CarouselBanner"
    case carouselNative = "CarouselNative"
    case fsn = "FSN"
    case unified = "Unified"
    case video = "Video"
    case appopen = "Appopen"
    case customNative = "CustomNative"
}
