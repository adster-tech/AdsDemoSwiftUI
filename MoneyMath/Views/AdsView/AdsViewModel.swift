//
//  AdsViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//
import Combine
import AdsFramework
import SwiftUI
import GoogleMobileAds

class AdsViewModel: ObservableObject {
    let key: String
    let displayKey: String
    let isAdsterInitialized: Bool
    @Published var didAppear = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    @Published var bannerView: BannerAdView?
    @Published var mediationNativeAd: AdsFramework.MediationNativeAd? = nil
    @Published var adCallbacks: [String] = []
    
    init(key: String, isAdsterInitialized: Bool = false) {
        self.displayKey = key
        self.key = key.replacingOccurrences(of: "-", with: "_").lowercased()
        self.isAdsterInitialized = isAdsterInitialized
    }
    
    func loadAdActivity() {
        Task { @MainActor in
            guard isAdsterInitialized else {
                self.error = "Adster SDK is not initialized. Please initialize it first."
                return
            }
            
            self.isLoading = true
            self.error = nil
            self.bannerView = nil
            self.mediationNativeAd = nil
            self.adCallbacks = []
            addCallback("Ad loading started for placement: \(key)")
            let loader = AdSterAdLoader()
            loader.delegate = self
            loader.loadAd(
                adRequestConfiguration: AdRequestConfiguration(
                    placement: key,
                    viewController: UIApplication.shared.windows.first?.rootViewController,
                    publisherProvidedId: "Test",
                    customTargetingValues: ["test": "123"]
                )
            )
        }
    }
    
    func launchAdInspector() {
        guard isAdsterInitialized else {
            self.error = "Adster SDK is not initialized. Please initialize it first."
            return
        }
        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            self.error = "Could not find root view controller"
            return
        }
        
        MobileAds.shared.presentAdInspector(from: viewController) { [weak self] (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = "Ad Inspector failed to launch: \(error.localizedDescription)"
                } else {
                    self?.error = nil
                }
            }
        }
    }
}

extension AdsViewModel: MediationAdDelegate {
    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: any AdsFramework.MediationRewardedInterstitialAd) {
        
    }
    
    func onBannerAdLoaded(bannerAd: AdsFramework.MediationBannerAd) {
        Task { @MainActor in
            guard let bannerview = bannerAd.view else {
                print("Banner Ad request failed with reason banner ad null")
                return
            }
            addBannerViewToView(bannerview)
            bannerAd.eventDelegate = self
            addCallback("Banner ad loaded successfully")
            self.isLoading = false
        }
    }
    
    func onInterstitialAdLoaded(interstitialAd: AdsFramework.MediationInterstitialAd) {
        Task { @MainActor in
            addCallback("Interstitial ad loaded successfully")
            interstitialAd.presentInterstitial(from: UIApplication.shared.windows.first?.rootViewController)
            interstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedAdLoaded(rewardedAd: AdsFramework.MediationRewardedAd) {
        Task { @MainActor in
            addCallback("Rewarded ad loaded successfully")
            rewardedAd.presentRewarded(from: UIApplication.shared.windows.first?.rootViewController)
            rewardedAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
//    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: AdsFramework.MediationRewardedInterstitialAd) {
//        Task { @MainActor in
//            rewardedInterstitialAd.presentRewardedInterstitial(from: UIApplication.shared.windows.first?.rootViewController)
//            rewardedInterstitialAd.eventDelegate = self
//            self.isLoading = false
//        }
//    }
    
    func onNativeAdLoaded(nativeAd: AdsFramework.MediationNativeAd) {
        Task { @MainActor in
            addCallback("Native ad loaded successfully")
            setNativeAdFromAdster(nativeAd: nativeAd)
            self.isLoading = false
        }
    }
    
    func setNativeAd(nativeAd: AdsFramework.MediationNativeAd) {
        Task { @MainActor in
            self.mediationNativeAd = nativeAd
        }
    }
    
    func setNativeAdFromAdster(nativeAd: AdsFramework.MediationNativeAd) {
        Task { @MainActor in
            nativeAd.eventDelegate = self
            let bundle = Bundle(for: MediationNativeAdView.self)
            let nib = UINib(nibName: "NativeView", bundle: bundle)
            guard let adView = nib.instantiate(withOwner: nil, options: nil).first as? MediationNativeAdView else { return }
            
            (adView.bodyView as? UILabel)?.text = nativeAd.body
            (adView.headlineView as? UILabel)?.text = nativeAd.headline
            (adView.ctaView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            (adView.ctaView as? UIButton)?.isUserInteractionEnabled = false
            adView.setNativeAd(nativeAd: nativeAd)
            if let mediaView = nativeAd.mediaView {
                addMediaViewToParentView(childView: mediaView, parentView: adView.mediaView)
            }
            addBannerViewToView(adView)
        }
    }
    
    func addMediaViewToParentView(childView: UIView, parentView: UIView) {
           childView.translatesAutoresizingMaskIntoConstraints = false
           parentView.addSubview(childView)

           NSLayoutConstraint.activate([
               childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
               childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
               childView.topAnchor.constraint(equalTo: parentView.topAnchor),
               childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
           ])
    }
    
    func addBannerViewToView(_ bannerView: UIView) {
        Task { @MainActor in
            self.bannerView = .init(bannerView: bannerView)
            self.isLoading = false
        }
    }
    
    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {
        
    }
    
    func onAdFailedToLoad(error: AdsFramework.AdError) {
        Task { @MainActor in
            self.error = error.description
            addCallback("Ad failed to load: \(error.description)")
            self.isLoading = false
        }
    }
    
    private func addCallback(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let callbackMessage = "[\(timestamp)] \(message)"
        adCallbacks.append(callbackMessage)
        if adCallbacks.count > 20 {
            adCallbacks.removeFirst()
        }
    }
}

extension AdsViewModel: AdsFramework.MediationInterstitialAdEventDelegate {
    func recordInterstitialClick() { addCallback("Interstitial clicked") }
    func recordInterstitialImpression() { addCallback("Interstitial impression recorded") }
    func ad(didFailToPresentFullScreenContentWithError error: AdsFramework.AdError) {
        addCallback("Interstitial failed to present: \(error.description)")
    }
    
    func adWillPresentFullScreenContent() {
        addCallback("Interstitial will present full screen content")
    }
    
    func adDidDismissFullScreenContent() {
        addCallback("Interstitial dismissed full screen content")
    }
}

extension AdsViewModel: AdsFramework.MediationRewardedAdEventDelegate {
    func recordRewardedClick() { addCallback("Rewarded clicked") }
    func recordRewardedImpression() { addCallback("Rewarded impression recorded") }
    func didRewardUser(reward: AdsFramework.AdReward) {
        addCallback("User rewarded: \(reward.amount) \(reward.type)")
    }
    
    func didStartVideo() {
        addCallback("Rewarded video started")
    }
    
    func didEndVideo() {
        addCallback("Rewarded video ended")
    }
    
}

extension AdsViewModel: AdsFramework.MediationBannerAdEventDelegate {
    func recordBannerClick() { addCallback("Banner clicked") }
    func recordBannerImpression() { addCallback("Banner impression recorded") }
}

extension AdsViewModel: AdsFramework.MediationNativeAdEventDelegate {
    func recordNativeClick() { addCallback("Native clicked") }
    func recordNativeImpression() { addCallback("Native impression recorded") }
}


extension AdsViewModel: AdsFramework.MediationRewardedInterstitialAdEventDelegate {
    func recordRewardedInterstitialClick() { addCallback("Rewarded interstitial clicked") }
    func recordRewardedInterstitialImpression() { addCallback("Rewarded interstitial impression recorded") }
}
