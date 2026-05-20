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

    var placementComponent: String {
        switch self {
        case .adsterDirect:
            return "adster_direct"
        default:
            return rawValue.replacingOccurrences(of: " ", with: "_").lowercased()
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
    case adster = "Adster"
    case adsterDirect = "Adster Direct"
}


enum SdkAdType: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }

    var placementComponent: String {
        switch self {
        case .unifiedAoi:
            return "unified_aoi"
        case .appopen:
            return "appopen"
        case .carouselBanner:
            return "carousel_banner"
        case .carouselNative:
            return "carousel_native"
        default:
            return rawValue.replacingOccurrences(of: "-", with: "_").lowercased()
        }
    }

    case banner = "Banner"
    case interstitial = "Interstitial"
    case rewarded = "Rewarded"
    case rewardedInterstitial = "RewardedInterstitial"
    case native = "Native"
    case fsn = "FSN"
    case unified = "Unified"
    case unifiedAoi = "Unified-AOI"
    case video = "Video"
    case appopen = "Appopen"
    case carouselBanner = "Carousel Banner"
    case carouselNative = "Carousel Native"
}
