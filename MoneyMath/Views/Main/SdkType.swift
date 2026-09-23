//
//  SdkType.swift
//  AdsDemoSwiftUI
//
//  Created by Erelego on 10/03/25.
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
    case erelego = "Erelego"
    case erelegoDirect = "Erelego-Direct"

    // These prefixes identify existing backend placements, independent of UI branding.
    var placementPrefix: String {
        switch self {
        case .erelego: return "Adster"
        case .erelegoDirect: return "Adster-Direct"
        default: return rawValue
        }
    }
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
