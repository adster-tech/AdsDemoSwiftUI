//
//  GoogleAdManagerView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 09/09/25.
//

import SwiftUI
import GoogleMobileAds
import AppLovinSDK
import UIKit

private func nsValue(from size: AdSize) -> NSValue {
    return nsValue(for: size)
}

struct GoogleAdManagerView: View {
    @State private var isGAMInitialized = false
    @State private var bannerView: AdManagerBannerView?
    @State private var interstitialAd: AdManagerInterstitialAd?
    @State private var rewardedAd: RewardedAd?
    @State private var statusMessage = "GAM not initialized"
    @State private var isLoading = false
    @State private var error: String?
    @State private var bannerDelegate: GAMBannerDelegate?  // strong ref so delegate isn't deallocated

    // AppLovin via GAM Mediation
    @State private var alBannerView: MAAdView?
    @State private var alInterstitialAd: MAInterstitialAd?
    @State private var alRewardedAd: MARewardedAd?
    @State private var isALInitialized = false
    @State private var alStatusMessage = "AppLovin not initialized"
    @State private var alIsLoading = false
    @State private var alError: String?
    @State private var alBannerDelegate: AppLovinBannerDelegate?
    @State private var alInterstitialDelegate: AppLovinInterstitialDelegate?
    @State private var alRewardedDelegate: AppLovinRewardedDelegate?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                detailsView

                if let bannerView = bannerView {
                    AdManagerBannerHostController(bannerView: bannerView)
                        .frame(height: bannerView.adSize.size.height)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                Divider()
                    .padding(.horizontal)

                appLovinSection

                if let alBannerView = alBannerView {
                    AppLovinBannerHostController(bannerView: alBannerView)
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationTitle("Google Ad Manager")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            statusView
            buttonSection
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.blue)
                    .frame(width: 50, height: 50)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
            }
            
            errorView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var statusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GAM Status")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(statusMessage)
                .font(.subheadline)
                .foregroundColor(isGAMInitialized ? .green : .orange)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 16) {
            Text("Ad Controls")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                
                // Initialize GAM
                Button(action: initializeGAM) {
                    HStack {
                        Image(systemName: "power")
                        Text("Initialize GAM")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGAMInitialized)
                
                // Load Banner
                Button(action: loadBannerAd) {
                    HStack {
                        Image(systemName: "rectangle.portrait")
                        Text("Load Banner (320x50 / 300x250)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isGAMInitialized)
                
                HStack(spacing: 12) {
                    // Load Interstitial
                    Button(action: loadInterstitialAd) {
                        VStack {
                            Image(systemName: "rectangle.expand.vertical")
                            Text("Load Interstitial")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isGAMInitialized)
                    
                    // Show Interstitial
                    Button(action: showInterstitialAd) {
                        VStack {
                            Image(systemName: "display")
                            Text("Show Interstitial")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(interstitialAd == nil)
                }
                
                HStack(spacing: 12) {
                    // Load Rewarded
                    Button(action: loadRewardedAd) {
                        VStack {
                            Image(systemName: "gift")
                            Text("Load Rewarded")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isGAMInitialized)
                    
                    // Show Rewarded
                    Button(action: showRewardedAd) {
                        VStack {
                            Image(systemName: "play.rectangle")
                            Text("Show Rewarded")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(rewardedAd == nil)
                }
                
                // Ad Inspector
                Button(action: launchAdInspector) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Launch Ad Inspector")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isGAMInitialized)
            }
        }
    }
    
    @ViewBuilder
    private var errorView: some View {
        if let error = error {
            Text("Error: \(error)")
                .font(.callout)
                .foregroundColor(.red)
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - AppLovin Section

    private var appLovinSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            alStatusView
            alButtonSection

            if alIsLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.purple)
                    .frame(width: 50, height: 50)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
            }

            alErrorView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private var alStatusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AppLovin Status")
                .font(.headline)
                .foregroundColor(.primary)

            Text(alStatusMessage)
                .font(.subheadline)
                .foregroundColor(isALInitialized ? .green : .orange)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }

    private var alButtonSection: some View {
        VStack(spacing: 16) {
            Text("AppLovin Ad Controls")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Button(action: initializeAppLovin) {
                    HStack {
                        Image(systemName: "power")
                        Text("Initialize AppLovin")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(isALInitialized)

                Button(action: loadALBannerAd) {
                    HStack {
                        Image(systemName: "rectangle.portrait")
                        Text("Load Banner (320x50)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(!isALInitialized)

                HStack(spacing: 12) {
                    Button(action: loadALInterstitialAd) {
                        VStack {
                            Image(systemName: "rectangle.expand.vertical")
                            Text("Load Interstitial")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                    .disabled(!isALInitialized)

                    Button(action: showALInterstitialAd) {
                        VStack {
                            Image(systemName: "display")
                            Text("Show Interstitial")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                    .disabled(alInterstitialDelegate?.isReady != true)
                }

                HStack(spacing: 12) {
                    Button(action: loadALRewardedAd) {
                        VStack {
                            Image(systemName: "gift")
                            Text("Load Rewarded")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                    .disabled(!isALInitialized)

                    Button(action: showALRewardedAd) {
                        VStack {
                            Image(systemName: "play.rectangle")
                            Text("Show Rewarded")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                    .disabled(alRewardedDelegate?.isReady != true)
                }

                Button(action: launchALMediationDebugger) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Launch Mediation Debugger")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(!isALInitialized)
            }
        }
    }

    @ViewBuilder
    private var alErrorView: some View {
        if let alError = alError {
            Text("Error: \(alError)")
                .font(.callout)
                .foregroundColor(.red)
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
        }
    }

    // MARK: - AppLovin Actions

    private func initializeAppLovin() {
        alIsLoading = true
        alError = nil

        let initConfig = ALSdkInitializationConfiguration(sdkKey: "YOUR_SDK_KEY") { builder in
            builder.mediationProvider = ALMediationProviderMAX
            builder.testDeviceAdvertisingIdentifiers = ["7641046A05914CBCBAFA838FAEB7295A"]
        }

        ALSdk.shared().initialize(with: initConfig) { sdkConfiguration in
            DispatchQueue.main.async {
                self.alIsLoading = false
                self.isALInitialized = true
                self.alStatusMessage = "AppLovin initialized successfully"
                print("=== AppLovin SDK Initialized (from GAM view) ===")
                print("Country code: \(sdkConfiguration.countryCode)")
                print("================================================")
            }
        }
    }

    private func loadALBannerAd() {
        guard isALInitialized else { return }

        alIsLoading = true
        alError = nil

        let adView = MAAdView(adUnitIdentifier: "YOUR_BANNER_AD_UNIT_ID")
        adView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)

        let delegate = AppLovinBannerDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.alStatusMessage = "Banner ad loaded successfully"
                    self.alIsLoading = false
                }
            },
            onFailure: { adError in
                DispatchQueue.main.async {
                    self.alError = "Failed to load banner: \(adError.message)"
                    self.alIsLoading = false
                }
            },
            onRevenue: { ad in
                DispatchQueue.main.async {
                    self.handleALRevenuePaid(ad: ad, adType: "Banner")
                }
            }
        )
        self.alBannerDelegate = delegate
        adView.delegate = delegate

        self.alBannerView = adView
        adView.loadAd()

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.alIsLoading {
                self.alIsLoading = false
                self.alError = "Banner ad loading timed out"
            }
        }
    }

    private func loadALInterstitialAd() {
        guard isALInitialized else { return }

        alIsLoading = true
        alError = nil

        let ad = MAInterstitialAd(adUnitIdentifier: "YOUR_INTERSTITIAL_AD_UNIT_ID")

        let delegate = AppLovinInterstitialDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.alStatusMessage = "Interstitial ad loaded successfully"
                    self.alIsLoading = false
                }
            },
            onFailure: { adError in
                DispatchQueue.main.async {
                    self.alError = "Failed to load interstitial: \(adError.message)"
                    self.alIsLoading = false
                }
            },
            onDisplayFailure: { adError in
                DispatchQueue.main.async {
                    self.alError = "Failed to display interstitial: \(adError.message)"
                }
            },
            onHidden: {
                DispatchQueue.main.async {
                    self.alStatusMessage = "Interstitial ad dismissed"
                }
            },
            onRevenue: { ad in
                DispatchQueue.main.async {
                    self.handleALRevenuePaid(ad: ad, adType: "Interstitial")
                }
            }
        )
        self.alInterstitialDelegate = delegate
        ad.delegate = delegate
        ad.revenueDelegate = delegate

        self.alInterstitialAd = ad
        ad.load()
    }

    private func showALInterstitialAd() {
        guard let alInterstitialAd = alInterstitialAd, alInterstitialAd.isReady else {
            alError = "Interstitial ad is not ready"
            return
        }

        if let rootVC = topViewController() {
            alInterstitialAd.show(forPlacement: nil, customData: nil, viewController: rootVC)
            alStatusMessage = "Interstitial ad presented"
        } else {
            alError = "No active rootViewController to present interstitial"
        }
    }

    private func loadALRewardedAd() {
        guard isALInitialized else { return }

        alIsLoading = true
        alError = nil

        let ad = MARewardedAd.shared(withAdUnitIdentifier: "YOUR_REWARDED_AD_UNIT_ID")

        let delegate = AppLovinRewardedDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.alStatusMessage = "Rewarded ad loaded successfully"
                    self.alIsLoading = false
                }
            },
            onFailure: { adError in
                DispatchQueue.main.async {
                    self.alError = "Failed to load rewarded: \(adError.message)"
                    self.alIsLoading = false
                }
            },
            onDisplayFailure: { adError in
                DispatchQueue.main.async {
                    self.alError = "Failed to display rewarded: \(adError.message)"
                }
            },
            onReward: { reward in
                DispatchQueue.main.async {
                    self.alStatusMessage = "User earned reward: \(reward.amount) \(reward.label)"
                    print("=== USER EARNED REWARD (GAM view): \(reward.amount) \(reward.label) ===")
                }
            },
            onHidden: {
                DispatchQueue.main.async {
                    self.alStatusMessage = "Rewarded ad dismissed"
                }
            },
            onRevenue: { ad in
                DispatchQueue.main.async {
                    self.handleALRevenuePaid(ad: ad, adType: "Rewarded")
                }
            }
        )
        self.alRewardedDelegate = delegate
        ad.delegate = delegate
        ad.revenueDelegate = delegate

        self.alRewardedAd = ad
        ad.load()
    }

    private func showALRewardedAd() {
        guard let alRewardedAd = alRewardedAd, alRewardedAd.isReady else {
            alError = "Rewarded ad is not ready"
            return
        }

        if let rootVC = topViewController() {
            alRewardedAd.show(forPlacement: nil, customData: nil, viewController: rootVC)
            alStatusMessage = "Rewarded ad presented"
        } else {
            alError = "No active rootViewController to present rewarded ad"
        }
    }

    private func launchALMediationDebugger() {
        guard isALInitialized else { return }
        alError = nil
        ALSdk.shared().showMediationDebugger()
    }

    private func handleALRevenuePaid(ad: MAAd, adType: String) {
        let revenue = ad.revenue
        let networkName = ad.networkName
        let adUnitId = ad.adUnitIdentifier
        let placement = ad.placement

        print("=== AL REVENUE EVENT - \(adType) ===")
        print("Revenue: \(revenue)")
        print("Network: \(networkName)")
        print("Ad Unit ID: \(adUnitId)")
        print("Placement: \(placement ?? "N/A")")
        print("====================================")

        alStatusMessage = "\(adType) ad revenue: \(revenue) from \(networkName)"
    }

    // MARK: - GAM Actions

    private func initializeGAM() {
        isLoading = true
        error = nil
        
        // Test device for debug
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "7641046A05914CBCBAFA838FAEB7295A"
        ]
        
        MobileAds.shared.start { status in
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGAMInitialized = true
                self.statusMessage = "GAM initialized successfully"
                
                let adapters = status.adapterStatusesByClassName
                print("=== Adapter Statuses ===")
                for (className, adapterStatus) in adapters {
                    print("\(className): \(adapterStatus.state.rawValue) - \(adapterStatus.description)")
                }
                print("========================")
            }
        }
    }
    
    private func loadBannerAd() {
        guard isGAMInitialized else { return }
        
        isLoading = true
        error = nil
        
        let newBanner = AdManagerBannerView(adSize: AdSize(size: CGSize(width: 320, height: 50), flags: 0)) // 320x50 base
        newBanner.validAdSizes = [
            nsValue(from: AdSize(size: CGSize(width: 320, height: 50), flags: 0)),             // 320x50
            nsValue(from: AdSize(size: CGSize(width: 300, height: 250), flags: 0))     // 300x250
        ]
        
        newBanner.adUnitID = "/23104024203/iosCustomAdaptertest"
        
        let delegate = GAMBannerDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.statusMessage = "Banner ad loaded and displayed successfully"
                    self.isLoading = false
                }
            },
            onFailure: { loadErr in
                DispatchQueue.main.async {
                    self.error = "Failed to load banner ad: \(loadErr.localizedDescription)"
                    self.isLoading = false
                }
            }
        )
        self.bannerDelegate = delegate
        newBanner.delegate = delegate
        
        newBanner.paidEventHandler = { adValue in
            DispatchQueue.main.async {
                self.handlePaidEvent(adValue: adValue, adType: "Banner")
            }
        }
        
        self.bannerView = newBanner
        
        let request = AdManagerRequest()
        print(">>> Calling load() on GAMBannerView with sizes 320x50 + 300x250")
        newBanner.load(request)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isLoading {
                self.isLoading = false
                self.error = "Banner ad loading timed out"
            }
        }
    }
    
    private func loadInterstitialAd() {
        guard isGAMInitialized else { return }
        
        isLoading = true
        error = nil
        
        let request = AdManagerRequest()
        
        AdManagerInterstitialAd.load(
            with: "/23104024203/IosIntercustomtest",
            request: request
        ) { ad, loadError in
            DispatchQueue.main.async {
                self.isLoading = false
                if let loadError = loadError {
                    self.error = "Failed to load interstitial ad: \(loadError.localizedDescription)"
                    return
                }
                self.interstitialAd = ad
                
                // Set up paid event handler for interstitial
                ad?.paidEventHandler = { adValue in
                    DispatchQueue.main.async {
                        self.handlePaidEvent(adValue: adValue, adType: "Interstitial")
                    }
                }
                
                self.statusMessage = "Interstitial ad loaded successfully"
            }
        }
    }
    
    private func showInterstitialAd() {
        guard let interstitialAd = interstitialAd else { return }
        
        // Find a visible controller to present from
        if let rootVC = topViewController() {
            interstitialAd.present(from: rootVC)
            statusMessage = "Interstitial ad presented"
            self.interstitialAd = nil // reset after showing
        } else {
            error = "No active rootViewController to present interstitial"
        }
    }
    
    private func loadRewardedAd() {
        guard isGAMInitialized else { return }
        
        isLoading = true
        error = nil
        
        let request = AdManagerRequest()
        
        RewardedAd.load(
            with: "/23104024203/iosrewardedCustomAdapter",
            request: request
        ) { ad, loadError in
            DispatchQueue.main.async {
                self.isLoading = false
                if let loadError = loadError {
                    self.error = "Failed to load rewarded ad: \(loadError.localizedDescription)"
                    return
                }
                self.rewardedAd = ad
                
                // Set up paid event handler for rewarded
                ad?.paidEventHandler = { adValue in
                    DispatchQueue.main.async {
                        self.handlePaidEvent(adValue: adValue, adType: "Rewarded")
                    }
                }
                
                self.statusMessage = "Rewarded ad loaded successfully"
            }
        }
    }
    
    private func showRewardedAd() {
        guard let rewardedAd = rewardedAd else { return }
        
        // Find a visible controller to present from
        if let rootVC = topViewController() {
            rewardedAd.present(from: rootVC, userDidEarnRewardHandler: {
                DispatchQueue.main.async {
                    self.statusMessage = "User earned reward!"
                    print("=== USER EARNED REWARD ===")
                }
            })
            statusMessage = "Rewarded ad presented"
            self.rewardedAd = nil // reset after showing
        } else {
            error = "No active rootViewController to present rewarded ad"
        }
    }
    
    private func launchAdInspector() {
        guard isGAMInitialized else { return }
        
        error = nil
        
        guard let rootVC = topViewController() else {
            error = "Could not find root view controller for Ad Inspector"
            return
        }
        
        MobileAds.shared.presentAdInspector(from: rootVC) { err in
            DispatchQueue.main.async {
                if let err = err {
                    self.error = "Ad Inspector failed: \(err.localizedDescription)"
                } else {
                    self.statusMessage = "Ad Inspector launched"
                }
            }
        }
    }
    
    // MARK: - Paid Event Handler
    private func handlePaidEvent(adValue: AdValue, adType: String) {
        let micros = adValue.value.doubleValue
        let currency = adValue.currencyCode
        let precision = adValue.precision.rawValue
        
        print("=== PAID EVENT - \(adType) ===")
        print("Value (micros): \(micros)")
        print("Currency Code: \(currency)")
        print("Precision: \(precision)")
        print("Value in \(currency): \(micros / 1_000_000.0)")
        print("=============================")
        
        statusMessage = "\(adType) ad revenue: \(micros / 1_000_000.0) \(currency)"
    }
    
    // MARK: - Utility to get top VC for presentation
    private func topViewController(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

class GAMBannerDelegate: NSObject, BannerViewDelegate {
    private let onSuccess: () -> Void
    private let onFailure: (Error) -> Void
    
    init(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("GAMBannerDelegate: bannerViewDidReceiveAd ✅")
        onSuccess()
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("GAMBannerDelegate: didFailToReceiveAd ❌ \(error)")
        onFailure(error)
    }
    
    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        print("Banner ad clicked")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        print("Banner ad impression recorded")
    }
}

struct AdManagerBannerHostController: UIViewControllerRepresentable {
    let bannerView: AdManagerBannerView
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        bannerView.rootViewController = vc
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}

struct GoogleAdManagerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GoogleAdManagerView()
        }
    }
}
