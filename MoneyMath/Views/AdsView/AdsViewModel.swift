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
    let isAdsterInitialized: Bool
    @Published var didAppear = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    @Published var bannerView: BannerAdView?
    @Published var mediationNativeAd: AdsFramework.MediationNativeAd? = nil

    // Keep a strong reference to active video ads so their backing AVPlayer +
    // IMA ads-manager don't get deallocated while the view renders them.
    // (The SDK's internal map is keyed by MediationAdConfiguration and is not
    //  guaranteed to outlive our callbacks.)
    var currentBannerVideoAd: AdsFramework.MediationBannerVideoAd?
    var currentVideoAd: AdsFramework.MediationVideoAd?
    var currentVideoPresenter: IMAVideoPresenterViewController?
    
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
            print("[Demo] loadAdActivity — requesting placement=\(key) displayKey=\(displayKey)")
            let loader = AdSterAdLoader()
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
    func onBannerVideoAdLoaded(bannerVideoAd: any AdsFramework.MediationBannerVideoAd) {
        print("[Demo] onBannerVideoAdLoaded — view=\(bannerVideoAd.view == nil ? "nil" : "ok")")
        Task { @MainActor in
            guard let view = bannerVideoAd.view else {
                self.error = "Banner-video ad returned a nil view"
                self.isLoading = false
                return
            }
            // Retain the ad so its AVPlayer + IMA ads-manager stay alive while
            // SwiftUI renders the UIView.
            self.currentBannerVideoAd = bannerVideoAd
            bannerVideoAd.eventDelegate = self
            addBannerViewToView(view)
            self.isLoading = false
        }
    }

    func onVideoAdLoaded(videoAd: any AdsFramework.MediationVideoAd) {
        print("[Demo] onVideoAdLoaded — presenting full-screen")
        Task { @MainActor in
            guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
                self.error = "Could not find root view controller to present video ad"
                self.isLoading = false
                return
            }
            videoAd.eventDelegate = self
            self.currentVideoAd = videoAd

            let presenter = IMAVideoPresenterViewController(videoAd: videoAd) { [weak self] in
                // Clear the retained references once the ad is dismissed so
                // they can be deallocated.
                self?.currentVideoAd = nil
                self?.currentVideoPresenter = nil
            }
            presenter.modalPresentationStyle = .fullScreen
            self.currentVideoPresenter = presenter

            // Walk to the top-most presented VC so we present over any existing modal.
            var top = rootVC
            while let presented = top.presentedViewController {
                top = presented
            }
            top.present(presenter, animated: true) {
                self.isLoading = false
            }
        }
    }
    
    func onAppOpenAdLoaded(appOpenAd: any AdsFramework.MediationAppOpenAd) {
        
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
            interstitialAd.presentInterstitial(from: UIApplication.shared.windows.first?.rootViewController)
            interstitialAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedAdLoaded(rewardedAd: AdsFramework.MediationRewardedAd) {
        Task { @MainActor in
            rewardedAd.presentRewarded(from: UIApplication.shared.windows.first?.rootViewController)
            rewardedAd.eventDelegate = self
            self.isLoading = false
        }
    }
    
    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: AdsFramework.MediationRewardedInterstitialAd) {
        Task { @MainActor in
            rewardedInterstitialAd.presentRewardedInterstitial(from: UIApplication.shared.windows.first?.rootViewController)
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
        
    }
    
    func onAdFailedToLoad(error: AdsFramework.AdError) {
        print("[Demo] onAdFailedToLoad — \(error.description ?? "<nil>")")
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

// MARK: - IMA banner-video event delegate
//
// NOTE: Every method of both delegate protocols is spelled out below — we don't
// rely on the SDK's default-implementation protocol extensions because the Swift
// compiler doesn't always pick them up across module boundaries when a single
// type conforms to multiple related protocols (both delegates share method
// names like `onAdCompleted()` / `onAdStarted()`).

extension AdsViewModel: AdsFramework.MediationBannerVideoAdEventDelegate {
    func recordBannerVideoClick() {
        print("[IMA] banner-video click")
    }

    func recordBannerVideoImpression() {
        print("[IMA] banner-video impression")
    }

    func onAdStarted() {
        // Shared name with MediationVideoAdEventDelegate — satisfies both.
    }

    func onAdCompleted() {
        // Shared name with MediationVideoAdEventDelegate — auto-dismiss the
        // full-screen video presenter if one is active.
        Task { @MainActor in
            self.currentVideoPresenter?.adDidComplete()
        }
    }

    func onAdSkipped() {
        // Shared name with MediationVideoAdEventDelegate.
        Task { @MainActor in
            self.currentVideoPresenter?.adDidComplete()
        }
    }

    func onAdPaused() {}
    func onAdResumed() {}
    func onContentPauseRequested() {}
    func onContentResumeRequested() {}

    func onAllAdCompleted() {
        // Shared name with MediationVideoAdEventDelegate.
        Task { @MainActor in
            self.currentVideoPresenter?.adDidComplete()
        }
    }

    func onVolumeChanged(volumePercent: Int) {}
}

// MARK: - IMA full-screen video event delegate

extension AdsViewModel: AdsFramework.MediationVideoAdEventDelegate {
    func recordVideoClick() {
        print("[IMA] video click")
    }

    func recordVideoImpression() {
        print("[IMA] video impression")
    }

    func onAdTapped() {}
    func onSkippableStateChanged() {}

    // onAdStarted / onAdCompleted / onAdSkipped / onAdPaused / onAdResumed /
    // onContentPauseRequested / onContentResumeRequested / onAllAdCompleted /
    // onVolumeChanged are already implemented in the banner-video extension
    // above — a single method named e.g. `onAdCompleted()` on AdsViewModel
    // satisfies both protocol requirements.
}
