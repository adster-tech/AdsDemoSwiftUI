//
//  GoogleAdManagerView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 09/09/25.
//

import SwiftUI
import GoogleMobileAds

struct GoogleAdManagerView: View {
    @State private var isGAMInitialized = false
    @State private var bannerView: GAMBannerView?
    @State private var interstitialAd: GAMInterstitialAd?
    @State private var statusMessage = "GAM not initialized"
    @State private var isLoading = false
    @State private var error: String?
    @State private var bannerDelegate: GAMBannerDelegate?
    
    var body: some View {
        VStack(spacing: 24) {
            detailsView
            Spacer()
            if let bannerView = bannerView {
                GADBannerViewController(bannerView: bannerView)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationTitle("Google Ad Manager")
        .navigationBarTitleDisplayMode(.inline)
    }
    
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
                // Initialize Button
                Button(action: initializeGAM) {
                    HStack {
                        Image(systemName: "power")
                        Text("Initialize GAM")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGAMInitialized)
                
                // Load Banner Button
                Button(action: loadBannerAd) {
                    HStack {
                        Image(systemName: "rectangle.portrait")
                        Text("Load Banner")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isGAMInitialized)
                
                HStack(spacing: 12) {
                    // Load Interstitial Button
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
                    
                    // Show Interstitial Button
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
                
                // Ad Inspector Button
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
    
    // MARK: GAM Functions
    private func initializeGAM() {
        isLoading = true
        error = nil
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "7641046A05914CBCBAFA838FAEB7295A" ]
        
        GADMobileAds.sharedInstance().start { status in
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGAMInitialized = true
                self.statusMessage = "GAM initialized successfully"
            }
        }
    }
    
    private func loadBannerAd() {
        guard isGAMInitialized else { return }
        
        isLoading = true
        error = nil
        
        // Create banner view similar to SDK implementation
        bannerView = GAMBannerView(adSize: GADAdSizeBanner)
        bannerView?.adUnitID = "/23104024203/custom_event_banner_ios" // Google test banner ad unit ID
        
        // Set root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView?.rootViewController = rootViewController
        }
        
        // Create and set delegate
        let delegate = GAMBannerDelegate(
            onSuccess: {
                DispatchQueue.main.async {
                    self.statusMessage = "Banner ad loaded and displayed successfully"
                    self.isLoading = false
                }
            },
            onFailure: { error in
                DispatchQueue.main.async {
                    self.error = "Failed to load banner ad: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        )
        self.bannerDelegate = delegate
        bannerView?.delegate = delegate
        
        // Set up paid event handler for banner
        bannerView?.paidEventHandler = { adValue in
            DispatchQueue.main.async {
                self.handlePaidEvent(adValue: adValue, adType: "Banner")
            }
        }
        
        // Load ad with GAM request for Google Ad Manager
        let request = GAMRequest()
        
        // Test devices are already configured globally
        
        bannerView?.load(request)
        
        // Add timeout handling
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
        
        let request = GAMRequest()
        
        GAMInterstitialAd.load(withAdManagerAdUnitID: "ca-app-pub-3940256099942544/4411468910",
                               request: request) { [self] ad, loadError in
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
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            interstitialAd.present(fromRootViewController: rootViewController)
            statusMessage = "Interstitial ad presented"
            self.interstitialAd = nil // Reset after showing
        }
    }
    
    private func launchAdInspector() {
        guard isGAMInitialized else { return }
        
        error = nil
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            GADMobileAds.sharedInstance().presentAdInspector(from: rootViewController) { [self] (error: Error?) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.error = "Ad Inspector failed to launch: \(error.localizedDescription)"
                    } else {
                        self.statusMessage = "Ad Inspector launched successfully"
                    }
                }
            }
        } else {
            error = "Could not find root view controller"
        }
    }
    
    // MARK: - Paid Event Handler
    private func handlePaidEvent(adValue: GADAdValue, adType: String) {
        let value = adValue.value
        let currencyCode = adValue.currencyCode
        let precision = adValue.precision.rawValue
        
        print("=== PAID EVENT - \(adType) ===")
        print("Value: \(value)")
        print("Currency Code: \(currencyCode)")
        print("Precision: \(precision)")
        print("Value in USD: \(value.doubleValue / 1_000_000)") // Convert from micros to actual currency
        print("========================")
        
        // Update status message to show revenue
        statusMessage = "\(adType) ad generated revenue: \(value.doubleValue / 1_000_000) \(currencyCode)"
    }
}

class GAMBannerDelegate: NSObject, GADBannerViewDelegate {
    private let onSuccess: () -> Void
    private let onFailure: (Error) -> Void
    
    init(onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        onSuccess()
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        onFailure(error)
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        print("Banner ad clicked")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("Banner ad impression recorded")
    }
}

struct GADBannerViewController: UIViewControllerRepresentable {
    let bannerView: GAMBannerView
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return viewController
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
