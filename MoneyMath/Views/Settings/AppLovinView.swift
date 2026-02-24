//
//  AppLovinView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 24/02/26.
//

import SwiftUI
import AppLovinSDK
import UIKit

struct AppLovinView: View {
    @State private var isALInitialized = false
    @State private var bannerAdView: MAAdView?
    @State private var interstitialAd: MAInterstitialAd?
    @State private var rewardedAd: MARewardedAd?
    @State private var statusMessage = "AppLovin not initialized"
    @State private var isLoading = false
    @State private var error: String?
    @State private var bannerDelegate: AppLovinBannerDelegate?
    @State private var interstitialDelegate: AppLovinInterstitialDelegate?
    @State private var rewardedDelegate: AppLovinRewardedDelegate?

    var body: some View {
        VStack(spacing: 24) {
            detailsView

            Spacer()

            if let bannerAdView = bannerAdView {
                AppLovinBannerHostController(bannerView: bannerAdView)
                    .frame(height: bannerAdView.intrinsicContentSize.height > 0 ? bannerAdView.intrinsicContentSize.height : 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationTitle("AppLovin")
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
            Text("AppLovin Status")
                .font(.headline)
                .foregroundColor(.primary)

            Text(statusMessage)
                .font(.subheadline)
                .foregroundColor(isALInitialized ? .green : .orange)
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

                // Initialize AppLovin
                Button(action: initializeAppLovin) {
                    HStack {
                        Image(systemName: "power")
                        Text("Initialize AppLovin")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isALInitialized)

                // Load Banner
                Button(action: loadBannerAd) {
                    HStack {
                        Image(systemName: "rectangle.portrait")
                        Text("Load Banner (320x50)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isALInitialized)

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
                    .disabled(!isALInitialized)

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
                    .disabled(interstitialDelegate?.isReady != true)
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
                    .disabled(!isALInitialized)

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
                    .disabled(rewardedDelegate?.isReady != true)
                }

                // Mediation Debugger
                Button(action: launchMediationDebugger) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Launch Mediation Debugger")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isALInitialized)
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

    // MARK: - Actions

    private func initializeAppLovin() {
        isLoading = true
        error = nil

        let initConfig = ALSdkInitializationConfiguration(sdkKey: "QRogKrHW3wWksf63sF9cwIyoIE8TuWadOGKXv-STG6WTXn-4kJLuui1yKpGvGSzttmf2Bh912skQw7949WWOKp") { builder in
            builder.mediationProvider = ALMediationProviderMAX
            builder.testDeviceAdvertisingIdentifiers = ["7641046A05914CBCBAFA838FAEB7295A"]
        }

        ALSdk.shared().initialize(with: initConfig) { sdkConfiguration in
            DispatchQueue.main.async {
                self.isLoading = false
                self.isALInitialized = true
                self.statusMessage = "AppLovin initialized successfully"
                print("=== AppLovin SDK Initialized ===")
                print("Country code: \(sdkConfiguration.countryCode)")
                print("================================")
            }
        }
    }

    private func loadBannerAd() {
        guard isALInitialized else { return }

        isLoading = true
        error = nil

        let adView = MAAdView(adUnitIdentifier: "9cb62985fffbcddd")
        adView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)

        let delegate = AppLovinBannerDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.statusMessage = "Banner ad loaded successfully"
                    self.isLoading = false
                }
            },
            onFailure: { adError in
                DispatchQueue.main.async {
                    self.error = "Failed to load banner: \(adError.message)"
                    self.isLoading = false
                }
            },
            onRevenue: { ad in
                DispatchQueue.main.async {
                    self.handleRevenuePaid(ad: ad, adType: "Banner")
                }
            }
        )
        self.bannerDelegate = delegate
        adView.delegate = delegate

        self.bannerAdView = adView
        adView.loadAd()

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isLoading {
                self.isLoading = false
                self.error = "Banner ad loading timed out"
            }
        }
    }

    private func loadInterstitialAd() {
        guard isALInitialized else { return }

        isLoading = true
        error = nil

        let ad = MAInterstitialAd(adUnitIdentifier: "cb1e980f2f802802")

        let delegate = AppLovinInterstitialDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.statusMessage = "Interstitial ad loaded successfully"
                    self.isLoading = false
                }
            },
            onFailure: { adError in
                DispatchQueue.main.async {
                    self.error = "Failed to load interstitial: \(adError.message)"
                    self.isLoading = false
                }
            },
            onDisplayFailure: { adError in
                DispatchQueue.main.async {
                    self.error = "Failed to display interstitial: \(adError.message)"
                }
            },
            onHidden: {
                DispatchQueue.main.async {
                    self.statusMessage = "Interstitial ad dismissed"
                }
            },
            onRevenue: { ad in
                DispatchQueue.main.async {
                    self.handleRevenuePaid(ad: ad, adType: "Interstitial")
                }
            }
        )
        self.interstitialDelegate = delegate
        ad.delegate = delegate
        ad.revenueDelegate = delegate

        self.interstitialAd = ad
        ad.load()
    }

    private func showInterstitialAd() {
        guard let interstitialAd = interstitialAd, interstitialAd.isReady else {
            error = "Interstitial ad is not ready"
            return
        }

        if let rootVC = topViewController() {
            interstitialAd.show(forPlacement: nil, customData: nil, viewController: rootVC)
            statusMessage = "Interstitial ad presented"
        } else {
            error = "No active rootViewController to present interstitial"
        }
    }

    private func loadRewardedAd() {
        guard isALInitialized else { return }

        isLoading = true
        error = nil

        let ad = MARewardedAd.shared(withAdUnitIdentifier: "YOUR_REWARDED_AD_UNIT_ID")

        let delegate = AppLovinRewardedDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.statusMessage = "Rewarded ad loaded successfully"
                    self.isLoading = false
                }
            },
            onFailure: { adError in
                DispatchQueue.main.async {
                    self.error = "Failed to load rewarded: \(adError.message)"
                    self.isLoading = false
                }
            },
            onDisplayFailure: { adError in
                DispatchQueue.main.async {
                    self.error = "Failed to display rewarded: \(adError.message)"
                }
            },
            onReward: { reward in
                DispatchQueue.main.async {
                    self.statusMessage = "User earned reward: \(reward.amount) \(reward.label)"
                    print("=== USER EARNED REWARD: \(reward.amount) \(reward.label) ===")
                }
            },
            onHidden: {
                DispatchQueue.main.async {
                    self.statusMessage = "Rewarded ad dismissed"
                }
            },
            onRevenue: { ad in
                DispatchQueue.main.async {
                    self.handleRevenuePaid(ad: ad, adType: "Rewarded")
                }
            }
        )
        self.rewardedDelegate = delegate
        ad.delegate = delegate
        ad.revenueDelegate = delegate

        self.rewardedAd = ad
        ad.load()
    }

    private func showRewardedAd() {
        guard let rewardedAd = rewardedAd, rewardedAd.isReady else {
            error = "Rewarded ad is not ready"
            return
        }

        if let rootVC = topViewController() {
            rewardedAd.show(forPlacement: nil, customData: nil, viewController: rootVC)
            statusMessage = "Rewarded ad presented"
        } else {
            error = "No active rootViewController to present rewarded ad"
        }
    }

    private func launchMediationDebugger() {
        guard isALInitialized else { return }
        error = nil

        ALSdk.shared().showMediationDebugger()
    }

    // MARK: - Revenue Handler

    private func handleRevenuePaid(ad: MAAd, adType: String) {
        let revenue = ad.revenue
        let networkName = ad.networkName
        let adUnitId = ad.adUnitIdentifier
        let placement = ad.placement

        print("=== REVENUE EVENT - \(adType) ===")
        print("Revenue: \(revenue)")
        print("Network: \(networkName)")
        print("Ad Unit ID: \(adUnitId)")
        print("Placement: \(placement ?? "N/A")")
        print("================================")

        statusMessage = "\(adType) ad revenue: \(revenue) from \(networkName)"
    }

    // MARK: - Utility

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

// MARK: - Banner Delegate

class AppLovinBannerDelegate: NSObject, MAAdViewAdDelegate, MAAdRevenueDelegate {
    private let onSuccess: () -> Void
    private let onFailure: (MAError) -> Void
    private let onRevenue: (MAAd) -> Void

    init(onSuccess: @escaping () -> Void,
         onFailure: @escaping (MAError) -> Void,
         onRevenue: @escaping (MAAd) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onRevenue = onRevenue
    }

    func didLoad(_ ad: MAAd) {
        print("AppLovinBannerDelegate: didLoad")
        onSuccess()
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("AppLovinBannerDelegate: didFailToLoadAd - \(error.message)")
        onFailure(error)
    }

    func didDisplay(_ ad: MAAd) {
        print("AppLovin banner displayed")
    }

    func didHide(_ ad: MAAd) {
        print("AppLovin banner hidden")
    }

    func didClick(_ ad: MAAd) {
        print("AppLovin banner clicked")
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("AppLovin banner failed to display: \(error.message)")
    }

    func didExpand(_ ad: MAAd) {
        print("AppLovin banner expanded")
    }

    func didCollapse(_ ad: MAAd) {
        print("AppLovin banner collapsed")
    }

    func didPayRevenue(for ad: MAAd) {
        print("AppLovinBannerDelegate: didPayRevenue")
        onRevenue(ad)
    }
}

// MARK: - Interstitial Delegate

class AppLovinInterstitialDelegate: NSObject, MAAdDelegate, MAAdRevenueDelegate {
    private let onSuccess: () -> Void
    private let onFailure: (MAError) -> Void
    private let onDisplayFailure: (MAError) -> Void
    private let onHidden: () -> Void
    private let onRevenue: (MAAd) -> Void
    var isReady = false

    init(onSuccess: @escaping () -> Void,
         onFailure: @escaping (MAError) -> Void,
         onDisplayFailure: @escaping (MAError) -> Void,
         onHidden: @escaping () -> Void,
         onRevenue: @escaping (MAAd) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onDisplayFailure = onDisplayFailure
        self.onHidden = onHidden
        self.onRevenue = onRevenue
    }

    func didLoad(_ ad: MAAd) {
        print("AppLovinInterstitialDelegate: didLoad")
        isReady = true
        onSuccess()
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("AppLovinInterstitialDelegate: didFailToLoadAd - \(error.message)")
        isReady = false
        onFailure(error)
    }

    func didDisplay(_ ad: MAAd) {
        print("AppLovin interstitial displayed")
    }

    func didHide(_ ad: MAAd) {
        print("AppLovin interstitial hidden")
        isReady = false
        onHidden()
    }

    func didClick(_ ad: MAAd) {
        print("AppLovin interstitial clicked")
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("AppLovin interstitial failed to display: \(error.message)")
        isReady = false
        onDisplayFailure(error)
    }

    func didPayRevenue(for ad: MAAd) {
        print("AppLovinInterstitialDelegate: didPayRevenue")
        onRevenue(ad)
    }
}

// MARK: - Rewarded Delegate

class AppLovinRewardedDelegate: NSObject, MARewardedAdDelegate, MAAdRevenueDelegate {
    private let onSuccess: () -> Void
    private let onFailure: (MAError) -> Void
    private let onDisplayFailure: (MAError) -> Void
    private let onReward: (MAReward) -> Void
    private let onHidden: () -> Void
    private let onRevenue: (MAAd) -> Void
    var isReady = false

    init(onSuccess: @escaping () -> Void,
         onFailure: @escaping (MAError) -> Void,
         onDisplayFailure: @escaping (MAError) -> Void,
         onReward: @escaping (MAReward) -> Void,
         onHidden: @escaping () -> Void,
         onRevenue: @escaping (MAAd) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onDisplayFailure = onDisplayFailure
        self.onReward = onReward
        self.onHidden = onHidden
        self.onRevenue = onRevenue
    }

    func didLoad(_ ad: MAAd) {
        print("AppLovinRewardedDelegate: didLoad")
        isReady = true
        onSuccess()
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("AppLovinRewardedDelegate: didFailToLoadAd - \(error.message)")
        isReady = false
        onFailure(error)
    }

    func didDisplay(_ ad: MAAd) {
        print("AppLovin rewarded displayed")
    }

    func didHide(_ ad: MAAd) {
        print("AppLovin rewarded hidden")
        isReady = false
        onHidden()
    }

    func didClick(_ ad: MAAd) {
        print("AppLovin rewarded clicked")
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("AppLovin rewarded failed to display: \(error.message)")
        isReady = false
        onDisplayFailure(error)
    }

    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        print("AppLovinRewardedDelegate: didRewardUser - \(reward.amount) \(reward.label)")
        isReady = false
        onReward(reward)
    }

    func didPayRevenue(for ad: MAAd) {
        print("AppLovinRewardedDelegate: didPayRevenue")
        onRevenue(ad)
    }
}

// MARK: - Banner Host Controller

struct AppLovinBannerHostController: UIViewControllerRepresentable {
    let bannerView: MAAdView

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: 320),
            bannerView.heightAnchor.constraint(equalToConstant: 50)
        ])

        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct AppLovinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppLovinView()
        }
    }
}
