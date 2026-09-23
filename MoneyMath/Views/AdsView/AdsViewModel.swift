//
//  AdsViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Erelego on 11/03/25.
//
import Combine
import ErelegoKit
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
    let isErelegoInitialized: Bool
    @Published var didAppear = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    @Published var bannerView: BannerAdView?
    @Published var carouselBannerViews: [BannerAdView] = []
    @Published var mediationNativeAd: ErelegoKit.MediationNativeAd? = nil
    @Published var mediationNativeRewardAd: ErelegoKit.MediationNativeRewardAd? = nil
    @Published var carouselNativeAds: [ErelegoKit.MediationNativeAd] = []
    @Published var mediationCustomNativeAd: ErelegoKit.MediationNativeCustomFormatAd? = nil
    @Published var lastCustomNativeClickMessage: String? = nil
    @Published var revenueMessage: String? = nil
    
    init(key: String, isErelegoInitialized: Bool = false) {
        self.displayKey = key.replacingOccurrences(of: "Adster", with: "Erelego")
        self.key = key.replacingOccurrences(of: "-", with: "_").lowercased()
        self.placementKey = self.key
        self.isErelegoInitialized = isErelegoInitialized
    }
    
    func loadAdActivity() {
        Task { @MainActor in
            guard isErelegoInitialized else {
                self.error = "Erelego SDK is not initialized. Please initialize it first."
                return
            }
            
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
            let loader = ErelegoAdLoader()
            loader.delegate = self
            loader.loadAd(
                adRequestConfiguration: AdRequestConfiguration(
                    placement: key,
                    viewController: rootViewController(),
                    publisherProvidedId: "7e90f77f9b601f7d5696a660154d5ed26d2405abb43d955dd39b99a0c22ea20b"
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
        guard isErelegoInitialized else {
            self.error = "Erelego SDK is not initialized. Please initialize it first."
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
            guard isErelegoInitialized else {
                self.error = "Erelego SDK is not initialized. Please initialize it first."
                return
            }

            self.isLoading = true
            self.error = nil
            self.mediationNativeRewardAd = nil
            self.revenueMessage = nil

            let loader = ErelegoAdLoader()
            loader.delegate = self
            loader.loadAd(
                adRequestConfiguration: AdRequestConfiguration(
                    placement: key,
                    viewController: rootViewController(),
                    publisherProvidedId: "7e90f77f9b601f7d5696a660154d5ed26d2405abb43d955dd39b99a0c22ea20b"
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
    func onAppOpenAdLoaded(appOpenAd: any ErelegoKit.MediationAppOpenAd) {
        Task { @MainActor in
            appOpenAd.eventDelegate = self
            appOpenAd.presentAppOpenAd(from: rootViewController())
            self.isLoading = false
        }
    }

    func onCarouselBannerAdLoaded(carouselBannerAd: any ErelegoKit.MediationCarouselBannerAd) {
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

    func onCarouselNativeAdLoaded(carouselNativeAd: any ErelegoKit.MediationCarouselNativeAd) {
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

    func onAdRevenuePaid(revenue: Double, adUnitId: String, network: String, currency: String, precisionType: ErelegoKit.PrecisionType) {
        let message = "Revenue: \(revenue) \(currency), adUnitId: \(adUnitId), network: \(network), precision: \(precisionType)"
        print(message)
        Task { @MainActor in
            self.revenueMessage = message
        }
    }
    
    func onBannerAdLoaded(bannerAd: ErelegoKit.MediationBannerAd) {
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
    
    func onInterstitialAdLoaded(interstitialAd: ErelegoKit.MediationInterstitialAd) {
        Task { @MainActor in
            interstitialAd.presentInterstitial(from: rootViewController())
            interstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedAdLoaded(rewardedAd: ErelegoKit.MediationRewardedAd) {
        Task { @MainActor in
            rewardedAd.presentRewarded(from: rootViewController())
            rewardedAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: ErelegoKit.MediationRewardedInterstitialAd) {
        Task { @MainActor in
            rewardedInterstitialAd.presentRewardedInterstitial(from: rootViewController())
            rewardedInterstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onNativeAdLoaded(nativeAd: ErelegoKit.MediationNativeAd) {
        Task { @MainActor in
            setNativeAdFromErelego(nativeAd: nativeAd)
            self.isLoading = false
        }
    }

    func onNativeRewardAdLoaded(nativeRewardAd: ErelegoKit.MediationNativeRewardAd) {
        Task { @MainActor in
            nativeRewardAd.eventDelegate = self
            self.mediationNativeRewardAd = nativeRewardAd
            self.isLoading = false
        }
    }
    
    func setNativeAd(nativeAd: ErelegoKit.MediationNativeAd) {
        Task { @MainActor in
            self.mediationNativeAd = nativeAd
        }
    }
    
    func setNativeAdFromErelego(nativeAd: ErelegoKit.MediationNativeAd) {
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
    
    func onCustomNativeAdLoaded(customNativeAd: any ErelegoKit.MediationNativeCustomFormatAd) {
        Task { @MainActor in
            customNativeAd.eventDelegate = self
            self.mediationCustomNativeAd = customNativeAd
            let formatId = customNativeAd.getCustomFormatId() ?? "unknown format"
            let assetNames = customNativeAd.getAvailableAssetNames()?.joined(separator: ", ") ?? "no assets"
            self.lastCustomNativeClickMessage = "Loaded custom native: \(formatId). Assets: \(assetNames)"
            self.isLoading = false
        }
    }

    func onAdFailedToLoad(error: ErelegoKit.AdError) {
        Task { @MainActor in
            self.error = error.description
            self.isLoading = false
        }
    }
}

extension AdsViewModel: ErelegoKit.MediationInterstitialAdEventDelegate {
    func recordInterstitialClick() {
        
    }
    
    func recordInterstitialImpression() {
        
    }
    
    func ad(didFailToPresentFullScreenContentWithError error: ErelegoKit.AdError) {
        
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

extension AdsViewModel: ErelegoKit.MediationRewardedAdEventDelegate {
    func recordRewardedClick() {
        
    }
    
    func recordRewardedImpression() {
        
    }
    
    func didRewardUser(reward: ErelegoKit.AdReward) {
        
    }
    
    func didRewardUser() {
    
    }
    
    func didStartVideo() {
        
    }
    
    func didEndVideo() {
        
    }
}

extension AdsViewModel: ErelegoKit.MediationAppOpenAdEventDelegate {
    func recordAppOpenClick() {

    }

    func recordAppOpenImpression() {

    }
}

extension AdsViewModel: ErelegoKit.MediationBannerAdEventDelegate {
    func recordBannerClick() {
        
    }
    
    func recordBannerImpression() {
        
    }
    
    
}

extension AdsViewModel: ErelegoKit.MediationNativeAdEventDelegate {
    func recordNativeClick() {

    }

    func recordNativeImpression() {

    }


}

extension AdsViewModel: ErelegoKit.MediationNativeRewardAdEventDelegate {
    func recordNativeRewardClick() {

    }

    func recordNativeRewardImpression() {

    }
}

extension AdsViewModel: ErelegoKit.MediationNativeCustomAdEventDelegate {
    func recordNativeCustomClick() {
        Task { @MainActor in
            self.lastCustomNativeClickMessage = "Custom native click"
        }
    }

    func recordNativeCustomClick(ad: ErelegoKit.MediationNativeCustomFormatAd, assetName: String) {
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
