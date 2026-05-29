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

class AdsViewModel: ObservableObject, MediationRewardedInterstitialAdEventDelegate {
    func recordRewardedInterstitialClick() {
        
    }
    
    func recordRewardedInterstitialImpression() {
        
    }
    
    let key: String
    let displayKey: String
    let placementKey: String
    let isAdsterInitialized: Bool
    @Published var didAppear = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    @Published var bannerView: BannerAdView?
    @Published var carouselBannerViews: [BannerAdView] = []
    @Published var mediationNativeAd: AdsFramework.MediationNativeAd? = nil
    @Published var carouselNativeAds: [AdsFramework.MediationNativeAd] = []
    @Published var mediationCustomNativeAd: AdsFramework.MediationNativeCustomFormatAd? = nil
    @Published var lastCustomNativeClickMessage: String? = nil
    @Published var revenueMessage: String? = nil
    
    init(key: String, isAdsterInitialized: Bool = false) {
        self.displayKey = key
        self.key = key.replacingOccurrences(of: "-", with: "_").lowercased()
        self.placementKey = self.key
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
            self.carouselBannerViews = []
            self.mediationNativeAd = nil
            self.carouselNativeAds = []
            self.mediationCustomNativeAd = nil
            self.lastCustomNativeClickMessage = nil
            self.revenueMessage = nil
            let loader = AdSterAdLoader()
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

    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

extension AdsViewModel: MediationAdDelegate {
    func onAppOpenAdLoaded(appOpenAd: any AdsFramework.MediationAppOpenAd) {
        Task { @MainActor in
            appOpenAd.eventDelegate = self
            appOpenAd.presentAppOpenAd(from: rootViewController())
            self.isLoading = false
        }
    }

    func onCarouselBannerAdLoaded(carouselBannerAd: any AdsFramework.MediationCarouselBannerAd) {
        Task { @MainActor in
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

    func onCarouselNativeAdLoaded(carouselNativeAd: any AdsFramework.MediationCarouselNativeAd) {
        Task { @MainActor in
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

    func onAdRevenuePaid(revenue: Double, adUnitId: String, network: String, currency: String, precisionType: AdsFramework.PrecisionType) {
        let message = "Revenue: \(revenue) \(currency), adUnitId: \(adUnitId), network: \(network), precision: \(precisionType)"
        print(message)
        Task { @MainActor in
            self.revenueMessage = message
        }
    }
    
    func onBannerAdLoaded(bannerAd: AdsFramework.MediationBannerAd) {
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
    
    func onInterstitialAdLoaded(interstitialAd: AdsFramework.MediationInterstitialAd) {
        Task { @MainActor in
            interstitialAd.presentInterstitial(from: rootViewController())
            interstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedAdLoaded(rewardedAd: AdsFramework.MediationRewardedAd) {
        Task { @MainActor in
            rewardedAd.presentRewarded(from: rootViewController())
            rewardedAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: AdsFramework.MediationRewardedInterstitialAd) {
        Task { @MainActor in
            rewardedInterstitialAd.presentRewardedInterstitial(from: rootViewController())
            rewardedInterstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onNativeAdLoaded(nativeAd: AdsFramework.MediationNativeAd) {
        Task { @MainActor in
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
        Task { @MainActor in
            customNativeAd.eventDelegate = self
            self.mediationCustomNativeAd = customNativeAd
            let formatId = customNativeAd.getCustomFormatId() ?? "unknown format"
            let assetNames = customNativeAd.getAvailableAssetNames()?.joined(separator: ", ") ?? "no assets"
            self.lastCustomNativeClickMessage = "Loaded custom native: \(formatId). Assets: \(assetNames)"
            self.isLoading = false
        }
    }

    func onAdFailedToLoad(error: AdsFramework.AdError) {
        Task { @MainActor in
            self.error = error.description
            self.isLoading = false
        }
    }
}

extension AdsViewModel: AdsFramework.MediationInterstitialAdEventDelegate {
    func recordInterstitialClick() {
        
    }
    
    func recordInterstitialImpression() {
        
    }
    
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

extension AdsViewModel: AdsFramework.MediationRewardedAdEventDelegate {
    func recordRewardedClick() {
        
    }
    
    func recordRewardedImpression() {
        
    }
    
    func didRewardUser(reward: AdsFramework.AdReward) {
        
    }
    
    func didRewardUser() {
    
    }
    
    func didStartVideo() {
        
    }
    
    func didEndVideo() {
        
    }
}

extension AdsViewModel: AdsFramework.MediationAppOpenAdEventDelegate {
    func recordAppOpenClick() {

    }

    func recordAppOpenImpression() {

    }
}

extension AdsViewModel: AdsFramework.MediationBannerAdEventDelegate {
    func recordBannerClick() {
        
    }
    
    func recordBannerImpression() {
        
    }
    
    
}

extension AdsViewModel: AdsFramework.MediationNativeAdEventDelegate {
    func recordNativeClick() {

    }

    func recordNativeImpression() {

    }


}

extension AdsViewModel: AdsFramework.MediationNativeCustomAdEventDelegate {
    func recordNativeCustomClick() {
        Task { @MainActor in
            self.lastCustomNativeClickMessage = "Custom native click"
        }
    }

    func recordNativeCustomClick(ad: AdsFramework.MediationNativeCustomFormatAd, assetName: String) {
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
