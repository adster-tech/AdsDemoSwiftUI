//
//  AdsViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//
import Combine
import AdsFramework
import SwiftUI

class AdsViewModel: ObservableObject {
    let key: String
    let displayKey: String
    @Published var didAppear = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    @Published var bannerView: BannerAdView?
    @Published var mediationNativeAd: MediationNativeAd? = nil
    init(key: String) {
        self.displayKey = key
        self.key = key.replacingOccurrences(of: "-", with: "_").lowercased()
    }
    
    func loadAdActivity() {
        Task { @MainActor in
            self.isLoading = true
            self.error = nil
            self.bannerView = nil
            self.mediationNativeAd = nil
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
}

extension AdsViewModel: MediationAdDelegate {
    func onBannerAdLoaded(bannerAd: MediationBannerAd) {
        Task { @MainActor in
            guard let bannerview = bannerAd.view else {
                print("Banner Ad request failed with reason banner ad null")
                return
            }
            addBannerViewToView(bannerview)
            bannerAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onInterstitialAdLoaded(interstitialAd: MediationInterstitialAd) {
        Task { @MainActor in
            interstitialAd.presentInterstitial(from: UIApplication.shared.windows.first?.rootViewController)
            interstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedAdLoaded(rewardedAd: MediationRewardedAd) {
        Task { @MainActor in
            rewardedAd.presentRewarded(from: UIApplication.shared.windows.first?.rootViewController)
            rewardedAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    
    func onNativeAdLoaded(nativeAd: MediationNativeAd) {
        Task { @MainActor in
            setNativeAdFromAdster(nativeAd: nativeAd)
            self.isLoading = false
        }
    }
    
    func setNativeAd(nativeAd: MediationNativeAd) {
        Task { @MainActor in
            self.mediationNativeAd = nativeAd
        }
    }
    
    func setNativeAdFromAdster(nativeAd: MediationNativeAd) {
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
            self.isLoading = false
        }
    }
}

extension AdsViewModel: MediationInterstitialAdEventDelegate {
    func ad(didFailToPresentFullScreenContentWithError error: AdsFramework.AdError) {
        
    }
    
    func adWillPresentFullScreenContent() {
        
    }
    
    func adDidDismissFullScreenContent() {
        
    }
    
    func recordClick() {
        
    }
    
    func recordImpression() {
        
    }
}

extension AdsViewModel: MediationRewardedAdEventDelegate {
    func didRewardUser(reward: AdsFramework.AdReward) {
        
    }
    
    func didRewardUser() {
        
    }
    
    func didStartVideo() {
        
    }
    
    func didEndVideo() {
        
    }
}

extension AdsViewModel: MediationBannerAdEventDelegate {
    
}

extension AdsViewModel: MediationNativeAdEventDelegate {
    
}
