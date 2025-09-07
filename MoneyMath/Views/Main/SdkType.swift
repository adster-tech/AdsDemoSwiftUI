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
    case vungle = "Vungle"
    case applovin = "Applovin"
    case inmobi = "InMobi"
    case unity = "Unity"
    case adsease = "Adsease"
    case adster = "Adster"
}


enum SdkAdType: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }

    case banner = "Banner"
    case interstitial = "Interstitial"
    case rewarded = "Rewarded"
    case native = "Native"
    case fsn = "FSN"
    case unified = "Unified"
    case video = "Video"
    case appopen = "Appopen"
}
