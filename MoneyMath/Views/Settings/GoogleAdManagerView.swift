//
//  GoogleAdManagerView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 09/09/25.
//

import SwiftUI
import GoogleMobileAds
import UIKit

private func nsValue(from size: AdSize) -> NSValue {
    return nsValue(for: size)
}

struct GoogleAdManagerView: View {
    @State private var isGAMInitialized = false
    @State private var bannerView: BannerView?
    @State private var interstitialAd: InterstitialAd?
    @State private var rewardedAd: RewardedAd?
    @State private var statusMessage = "GAM not initialized"
    @State private var isLoading = false
    @State private var error: String?
    @State private var bannerDelegate: BannerDelegate?  // strong ref so delegate isn't deallocated
    
    var body: some View {
        VStack(spacing: 24) {
            detailsView
            
            Spacer()
            
            if let bannerView = bannerView {
                // This VC host will attach bannerView and set its rootVC
                BannerHostController(bannerView: bannerView)
                    .frame(height: bannerView.adSize.size.height) // dynamic height
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
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
        
        let newBanner = BannerView(adSize: AdSize(size: CGSize(width: 320, height: 50), flags: 0))
        
        newBanner.adUnitID = "ca-app-pub-6531459688090879/6838876712"
        
        let delegate = BannerDelegate(
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
        
        // Set rootViewController before calling load()
        if let rootVC = topViewController() {
            newBanner.rootViewController = rootVC
        }
        
        let request = Request()
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
        
        let request = Request()
        
        InterstitialAd.load(
            with: "ca-app-pub-6531459688090879/7994786539",
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
        
        let request = Request()
        
        RewardedAd.load(
            with: "ca-app-pub-6531459688090879/2718409128",
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

class BannerDelegate: NSObject, BannerViewDelegate {
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

struct BannerHostController: UIViewControllerRepresentable {
    let bannerView: BannerView
    
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
