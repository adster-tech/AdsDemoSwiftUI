//
//  AdsViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Razorpay on 11/03/25.
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
    
    private var retainedCarousels: [RazorpayAdsSdk.Ad] = []
    @Published var carouselCustomNativeAds: [MediationNativeCustomFormatAd] = []
    @Published var carouselNativeRewardAds: [MediationNativeRewardAd] = []

    func releaseAds() {
        retainedCarousels.forEach { $0.destroy() }
        retainedCarousels = []
        carouselBannerViews = []
        carouselNativeAds = []
        carouselCustomNativeAds = []
        carouselNativeRewardAds = []
        mediationNativeAd?.destroy()
        mediationNativeAd = nil
        mediationCustomNativeAd?.destroy()
        mediationCustomNativeAd = nil
        bannerView = nil
        mediationNativeRewardAd?.destroy()
        mediationNativeRewardAd = nil
        isLoading = false
    }

    let key: String
    let displayKey: String
    let placementKey: String
    let isRazorpayInitialized: Bool
    let nativeAdSize: NativeAdSize?
    @Published var didAppear = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    @Published var bannerView: BannerAdView?
    @Published var carouselBannerViews: [BannerAdView] = []
    @Published var mediationNativeAd: RazorpayAdsSdk.MediationNativeAd? = nil
    @Published var mediationNativeRewardAd: RazorpayAdsSdk.MediationNativeRewardAd? = nil
    @Published var carouselNativeAds: [RazorpayAdsSdk.MediationNativeAd] = []
    @Published var mediationCustomNativeAd: RazorpayAdsSdk.MediationNativeCustomFormatAd? = nil
    @Published var lastCustomNativeClickMessage: String? = nil
    @Published var revenueMessage: String? = nil

    init(key: String, isRazorpayInitialized: Bool = false, nativeAdSize: NativeAdSize? = nil) {
        self.nativeAdSize = nativeAdSize
        self.displayKey = key.replacingOccurrences(of: "Adster", with: "Razorpay")
        self.key = key.replacingOccurrences(of: "-", with: "_").lowercased()
        self.placementKey = self.key
        self.isRazorpayInitialized = isRazorpayInitialized
    }
    
    func loadAdActivity() {
        Task { @MainActor in
            guard isRazorpayInitialized else {
                self.error = "Razorpay SDK is not initialized. Please initialize it first."
                return
            }
            
            releaseAds()
            self.isLoading = true
            self.error = nil
            self.bannerView = nil
            self.carouselBannerViews = []
            self.mediationNativeAd = nil
            self.mediationNativeRewardAd = nil
            self.carouselNativeAds = []
            self.mediationCustomNativeAd = nil
            self.lastCustomNativeClickMessage = nil
            self.revenueMessage = nil
            let loader = RazorpayAdLoader()
            loader.delegate = self
            loader.loadAd(
                adRequestConfiguration: AdRequestConfiguration(
                    placement: key,
                    viewController: rootViewController(),
                    publisherProvidedId: "Test",
                    customTargetingValues: ["test": "123"],
                    adaptiveAdWidth: Int(UIScreen.main.bounds.width),
                    adaptiveType: "Anchored"
                )
            )
            
//            loader.loadAd(
//                adRequestConfiguration: AdRequestConfiguration(
//                    placement: "gam_banner_2",
//                    viewController: rootViewController(),
//                    publisherProvidedId: "Test",
//                    customTargetingValues: ["test": "123"],
//                    adaptiveAdWidth: Int(UIScreen.main.bounds.width),
//                    adaptiveType: "CurrentOrientationInline"
//                )
//            )
        }
    }
    
    func launchAdInspector() {
        guard isRazorpayInitialized else {
            self.error = "Razorpay SDK is not initialized. Please initialize it first."
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

    func loadNativeRewardAd() {
        Task { @MainActor in
            guard isRazorpayInitialized else {
                self.error = "Razorpay SDK is not initialized. Please initialize it first."
                return
            }

            releaseAds()
            self.isLoading = true
            self.error = nil
            self.mediationNativeRewardAd = nil
            self.revenueMessage = nil

            let loader = RazorpayAdLoader()
            loader.delegate = self
            loader.loadAd(
                adRequestConfiguration: AdRequestConfiguration(
                    placement: key,
                    viewController: rootViewController(),
                    publisherProvidedId: "Test",
                    customTargetingValues: ["test": "123"],
                    adaptiveAdWidth: Int(UIScreen.main.bounds.width),
                    adaptiveType: "Anchored"
                )
            )
        }
    }

    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

extension AdsViewModel: MediationAdDelegate {
    func onCarouselCustomNativeAdLoaded(carouselCustomNativeAd: MediationCarouselCustomNativeAd) {
        Task { @MainActor in
            self.retainedCarousels.append(carouselCustomNativeAd)
            carouselCustomNativeAd.ads.forEach { $0.eventDelegate = self }
            self.carouselCustomNativeAds = carouselCustomNativeAd.ads
            self.error = carouselCustomNativeAd.ads.isEmpty ? "Carousel loaded without ads." : nil
            self.isLoading = false
        }
    }

    func onCarouselNativeRewardAdLoaded(carouselNativeRewardAd: MediationCarouselNativeRewardAd) {
        Task { @MainActor in
            self.retainedCarousels.append(carouselNativeRewardAd)
            carouselNativeRewardAd.ads.forEach { $0.eventDelegate = self }
            self.carouselNativeRewardAds = carouselNativeRewardAd.ads
            self.error = carouselNativeRewardAd.ads.isEmpty ? "Carousel loaded without ads." : nil
            self.isLoading = false
        }
    }



    func onAppOpenAdLoaded(appOpenAd: any RazorpayAdsSdk.MediationAppOpenAd) {
        Task { @MainActor in
            appOpenAd.eventDelegate = self
            appOpenAd.presentAppOpenAd(from: rootViewController())
            self.isLoading = false
        }
    }

    func onCarouselBannerAdLoaded(carouselBannerAd: any RazorpayAdsSdk.MediationCarouselBannerAd) {
        Task { @MainActor in
            self.retainedCarousels.append(carouselBannerAd)
            let bannerViews = carouselBannerAd.ads.compactMap { bannerAd -> BannerAdView? in
                bannerAd.eventDelegate = self
                guard let view = bannerAd.view else { return nil }
                return BannerAdView(bannerView: view, fillsAvailableWidth: false)
            }
            guard !bannerViews.isEmpty else {
                self.error = "Carousel banner ad request loaded without banner views."
                self.isLoading = false
                return
            }
            self.carouselBannerViews = bannerViews
            self.isLoading = false
        }
    }

    func onCarouselNativeAdLoaded(carouselNativeAd: any RazorpayAdsSdk.MediationCarouselNativeAd) {
        Task { @MainActor in
            self.retainedCarousels.append(carouselNativeAd)
            let nativeAds = carouselNativeAd.ads
            nativeAds.forEach { $0.eventDelegate = self }
            guard !nativeAds.isEmpty else {
                self.error = "Carousel native ad request loaded without native ads."
                self.isLoading = false
                return
            }
            self.carouselNativeAds = nativeAds
            self.isLoading = false
        }
    }

    func onAdRevenuePaid(revenue: Double, adUnitId: String, network: String, currency: String, precisionType: RazorpayAdsSdk.PrecisionType) {
        let message = "Revenue: \(revenue) \(currency), adUnitId: \(adUnitId), network: \(network), precision: \(precisionType)"
        print(message)
        Task { @MainActor in
            self.revenueMessage = message
        }
    }
    
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
            interstitialAd.presentInterstitial(from: rootViewController())
            interstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedAdLoaded(rewardedAd: RazorpayAdsSdk.MediationRewardedAd) {
        Task { @MainActor in
            rewardedAd.presentRewarded(from: rootViewController())
            rewardedAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: RazorpayAdsSdk.MediationRewardedInterstitialAd) {
        Task { @MainActor in
            rewardedInterstitialAd.presentRewardedInterstitial(from: rootViewController())
            rewardedInterstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onNativeAdLoaded(nativeAd: RazorpayAdsSdk.MediationNativeAd) {
        Task { @MainActor in
            guard self.didAppear else { nativeAd.destroy(); return }
            setNativeAdFromRazorpay(nativeAd: nativeAd)
            self.isLoading = false
        }
    }

    func onNativeRewardAdLoaded(nativeRewardAd: RazorpayAdsSdk.MediationNativeRewardAd) {
        Task { @MainActor in
            nativeRewardAd.eventDelegate = self
            self.mediationNativeRewardAd = nativeRewardAd
            self.isLoading = false
        }
    }
    
    func setNativeAd(nativeAd: RazorpayAdsSdk.MediationNativeAd) {
        Task { @MainActor in
            self.mediationNativeAd = nativeAd
        }
    }
    
    func setNativeAdFromRazorpay(nativeAd: RazorpayAdsSdk.MediationNativeAd) {
        if mediationNativeAd !== nativeAd { mediationNativeAd?.destroy() }
        nativeAd.eventDelegate = self
        mediationNativeAd = nativeAd
    }

    func addBannerViewToView(_ bannerView: UIView) {
        Task { @MainActor in
            self.bannerView = .init(bannerView: bannerView)
            self.isLoading = false
        }
    }
    
    func onCustomNativeAdLoaded(customNativeAd: any RazorpayAdsSdk.MediationNativeCustomFormatAd) {
        Task { @MainActor in
            guard self.didAppear else { customNativeAd.destroy(); return }
            if self.mediationCustomNativeAd !== customNativeAd { self.mediationCustomNativeAd?.destroy() }
            customNativeAd.eventDelegate = self
            self.mediationCustomNativeAd = customNativeAd
            let formatId = customNativeAd.getCustomFormatId() ?? "unknown format"
            let assetNames = customNativeAd.getAvailableAssetNames()?.joined(separator: ", ") ?? "no assets"
            self.lastCustomNativeClickMessage = "Loaded custom native: \(formatId). Assets: \(assetNames)"
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

extension AdsViewModel: RazorpayAdsSdk.MediationAppOpenAdEventDelegate {
    func recordAppOpenClick() {

    }

    func recordAppOpenImpression() {

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

extension AdsViewModel: RazorpayAdsSdk.MediationNativeRewardAdEventDelegate {
    func recordNativeRewardClick() {

    }

    func recordNativeRewardImpression() {

    }
}

extension AdsViewModel: RazorpayAdsSdk.MediationNativeCustomAdEventDelegate {
    func recordNativeCustomClick() {
        Task { @MainActor in
            self.lastCustomNativeClickMessage = "Custom native click"
        }
    }

    func recordNativeCustomClick(ad: RazorpayAdsSdk.MediationNativeCustomFormatAd, assetName: String) {
        Task { @MainActor in
            self.lastCustomNativeClickMessage = "Custom native click on asset: \(assetName)"
        }
    }

    func recordNativeCustomImpression() {
        Task { @MainActor in
            if self.lastCustomNativeClickMessage == nil {
                self.lastCustomNativeClickMessage = "Custom native impression recorded"
            }
        }
    }
}
