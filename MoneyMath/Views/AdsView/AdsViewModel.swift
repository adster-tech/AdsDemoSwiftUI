//
//  AdsViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//
import Combine
import RazorpayAdsSdk
import SwiftUI
import GoogleMobileAds

class AdsViewModel: ObservableObject, MediationRewardedInterstitialAdEventDelegate {
    func recordRewardedInterstitialClick() {
        
    }
    
    func recordRewardedInterstitialImpression() {
        
    }
    
    let key: String
    let displayKey: String
    let isAdsterInitialized: Bool
    @Published var didAppear = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    @Published var bannerView: BannerAdView?
    @Published var mediationNativeAd: RazorpayAdsSdk.MediationNativeAd? = nil
    
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
            let loader = RazorpayAdLoader()
            loader.delegate = self
            loader.loadAd(
                adRequestConfiguration: AdRequestConfiguration(
                    placement: key,
                    viewController: UIApplication.shared.windows.first?.rootViewController,
                    publisherProvidedId: "Test",
                    customTargetingValues: ["test": "123"],
                    adaptiveAdWidth: Int(UIScreen.main.bounds.width),
                    adaptiveType: "Anchored"
                )
            )
            
//            loader.loadAd(
//                adRequestConfiguration: AdRequestConfiguration(
//                    placement: "gam_banner_2",
//                    viewController: UIApplication.shared.windows.first?.rootViewController,
//                    publisherProvidedId: "Test",
//                    customTargetingValues: ["test": "123"],
//                    adaptiveAdWidth: Int(UIScreen.main.bounds.width),
//                    adaptiveType: "CurrentOrientationInline"
//                )
//            )
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
    func onBannerAdLoaded(bannerAd: RazorpayAdsSdk.MediationBannerAd) {
        Task { @MainActor in
            guard let bannerview = bannerAd.view else {
                print("Banner Ad request failed with reason banner ad null")
                return
            }
            print("banner", bannerview)
            addBannerViewToView(bannerview)
            bannerAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onInterstitialAdLoaded(interstitialAd: RazorpayAdsSdk.MediationInterstitialAd) {
        Task { @MainActor in
            interstitialAd.presentInterstitial(from: UIApplication.shared.windows.first?.rootViewController)
            interstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedAdLoaded(rewardedAd: RazorpayAdsSdk.MediationRewardedAd) {
        Task { @MainActor in
            rewardedAd.presentRewarded(from: UIApplication.shared.windows.first?.rootViewController)
            rewardedAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: RazorpayAdsSdk.MediationRewardedInterstitialAd) {
        Task { @MainActor in
            rewardedInterstitialAd.presentRewardedInterstitial(from: UIApplication.shared.windows.first?.rootViewController)
            rewardedInterstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onNativeAdLoaded(nativeAd: RazorpayAdsSdk.MediationNativeAd) {
        Task { @MainActor in
            setNativeAdFromAdster(nativeAd: nativeAd)
            self.isLoading = false
        }
    }
    
    func setNativeAd(nativeAd: RazorpayAdsSdk.MediationNativeAd) {
        Task { @MainActor in
            self.mediationNativeAd = nativeAd
        }
    }
    
    func setNativeAdFromAdster(nativeAd: RazorpayAdsSdk.MediationNativeAd) {
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
    
    func onCustomNativeAdLoaded(customNativeAd: any RazorpayAdsSdk.MediationNativeCustomFormatAd) {

    }

    func onAppOpenAdLoaded(appOpenAd: RazorpayAdsSdk.MediationAppOpenAd) {
        Task { @MainActor in
            appOpenAd.presentAppOpenAd(from: UIApplication.shared.windows.first?.rootViewController)
            appOpenAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onAdFailedToLoad(error: RazorpayAdsSdk.AdError) {
        Task { @MainActor in
            self.error = error.description
            self.isLoading = false
        }
    }
}

extension AdsViewModel: RazorpayAdsSdk.MediationInterstitialAdEventDelegate {
    func recordInterstitialClick() {
        
    }
    
    func recordInterstitialImpression() {
        
    }
    
    func ad(didFailToPresentFullScreenContentWithError error: RazorpayAdsSdk.AdError) {
        
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

extension AdsViewModel: RazorpayAdsSdk.MediationRewardedAdEventDelegate {
    func recordRewardedClick() {
        
    }
    
    func recordRewardedImpression() {
        
    }
    
    func didRewardUser(reward: RazorpayAdsSdk.AdReward) {
        
    }
    
    func didRewardUser() {
    
    }
    
    func didStartVideo() {
        
    }
    
    func didEndVideo() {
        
    }
}

extension AdsViewModel: RazorpayAdsSdk.MediationBannerAdEventDelegate {
    func recordBannerClick() {
        
    }
    
    func recordBannerImpression() {
        
    }
    
    
}

extension AdsViewModel: RazorpayAdsSdk.MediationNativeAdEventDelegate {
    func recordNativeClick() {

    }

    func recordNativeImpression() {

    }
}

extension AdsViewModel: RazorpayAdsSdk.MediationAppOpenAdEventDelegate {
    func recordAppOpenClick() {

    }

    func recordAppOpenImpression() {

    }

    // Note: ad(didFailToPresentFullScreenContentWithError:), adWillPresentFullScreenContent(),
    // and adDidDismissFullScreenContent() are already implemented via MediationInterstitialAdEventDelegate conformance.
}
