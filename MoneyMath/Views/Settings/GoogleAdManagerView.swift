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
    @State private var bannerView: BannerView?
    @State private var interstitialAd: InterstitialAd?
    @State private var statusMessage = "GAM not initialized"
    @State private var isLoading = false
    @State private var error: String?
    
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
                
                HStack(spacing: 12) {
                    // Load Banner Button
                    Button(action: loadBannerAd) {
                        VStack {
                            Image(systemName: "rectangle.portrait")
                            Text("Load Banner")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isGAMInitialized)
                    
                    // Show Banner Button
                    Button(action: showBannerAd) {
                        VStack {
                            Image(systemName: "eye")
                            Text("Show Banner")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(bannerView == nil)
                }
                
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
        
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "fc2602718c7d7a9da6d46d8f37284938" ]
        
        MobileAds.shared.start { status in
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
        
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = "ca-app-pub-3940256099942544/2435281174" // Test ad unit ID
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }
        
        banner.load(Request())
        
        DispatchQueue.main.async {
            self.bannerView = banner
            self.statusMessage = "Banner ad loaded successfully"
            self.isLoading = false
        }
    }
    
    private func showBannerAd() {
        guard bannerView != nil else { return }
        statusMessage = "Banner ad is now displayed"
    }
    
    private func loadInterstitialAd() {
        guard isGAMInitialized else { return }
        
        isLoading = true
        error = nil
        
        let request = Request()
        InterstitialAd.load(with: "ca-app-pub-3940256099942544/4411468910",
                           request: request) { [self] ad, loadError in
            DispatchQueue.main.async {
                self.isLoading = false
                if let loadError = loadError {
                    self.error = "Failed to load interstitial ad: \(loadError.localizedDescription)"
                    return
                }
                self.interstitialAd = ad
                self.statusMessage = "Interstitial ad loaded successfully"
            }
        }
    }
    
    private func showInterstitialAd() {
        guard let interstitialAd = interstitialAd else { return }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            interstitialAd.present(from: rootViewController)
            statusMessage = "Interstitial ad presented"
            self.interstitialAd = nil // Reset after showing
        }
    }
}

struct GADBannerViewController: UIViewControllerRepresentable {
    let bannerView: BannerView
    
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
