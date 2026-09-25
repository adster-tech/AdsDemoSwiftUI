//
//  SdkType.swift
//  AdsDemoSwiftUI
//
//  Created by Adverge on 10/03/25.
//

enum SdkType: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    // Placement keys still use the current service configuration names.
    var placementPrefix: String {
        switch self {
        case .adverge: return "Adster"
        case .advergeDirect: return "Adster-Direct"
        default: return rawValue
        }
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
    case adverge = "Adverge"
    case advergeDirect = "Adverge-Direct"
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
    case nativeReward = "NativeReward"
    case carouselBanner = "CarouselBanner"
    case carouselNative = "CarouselNative"
    case fsn = "FSN"
    case unified = "Unified"
    case video = "Video"
    case appopen = "Appopen"
    case customNative = "CustomNative"
}
