//
//  SdkType.swift
//  AdsDemoSwiftUI
//
//  Created by Razorpay on 10/03/25.
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
    case razorpay = "Adster"
    case razorpayDirect = "Adster-Direct"
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
    case carouselCustomNative = "CarouselCustomNative"
    case carouselNativeReward = "CarouselNativeReward"
    case fsn = "FSN"
    case unified = "Unified"
    case video = "Video"
    case appopen = "Appopen"
    case customNative = "CustomNative"
}

// Display labels are separate from the raw values used to construct placement keys.
extension SdkAdType {
    var displayName: String {
        switch self {
        case .rewardedInterstitial: return "Rewarded interstitial"
        case .nativeReward: return "Native reward"
        case .carouselBanner: return "Carousel banner"
        case .carouselNative: return "Carousel native"
        case .carouselCustomNative: return "Carousel custom native"
        case .carouselNativeReward: return "Carousel native reward"
        case .appopen: return "App open"
        case .customNative: return "Custom native"
        default: return rawValue
        }
    }
}

// Keep server placement keys compatible with this demo's existing configuration.
// Branding is applied only to labels shown in the UI.
extension SdkType {
    var displayName: String {
        switch self {
        case .razorpay: return "Razorpay"
        case .razorpayDirect: return "Razorpay Direct"
        default: return rawValue
        }
    }
}
