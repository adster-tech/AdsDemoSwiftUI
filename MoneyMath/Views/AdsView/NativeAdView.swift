//
//  NativeAdView.swift
//  AdsDemoSwiftUI
//
//  Created by Erelego on 11/03/25.
//

import SwiftUI
import ErelegoKit

struct NativeAdView: View {
    let ad: MediationNativeAd
    
    var body: some View {
        descriptionView
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var headlineView: some View {
        if let headline = ad.headline {
            Text(headline)
                .font(.subheadline)
                .bold()
                .lineLimit(nil)
        }
    }
    
    @ViewBuilder
    private var bodyView: some View {
        if let body = ad.body {
            Text(body)
                .font(.footnote)
                .lineLimit(nil)
        }
    }
    
    @ViewBuilder
    private var ctaView: some View {
        if let cta = ad.callToAction {
            Button(cta) {
                
            }
        }
    }
    
    @ViewBuilder
    private var mediaView: some View {
        if ad.mediaView != nil {
            MediaAdView(mediationAd: ad)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        }
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            headlineView
            bodyView
            ctaView
            mediaView
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
        let app = UIApplication.shared
        
        if app.canOpenURL(url) {
            app.open(url, options: [:], completionHandler: nil)
        } else {
            print("Unable to open URL: \(url.absoluteString)")
        }
    }
}

class NativeAdContainerView: UIView {

    private var mediationNativeAd: MediationNativeAd?

    func configure(with ad: MediationNativeAd) {
        self.mediationNativeAd = ad
        
        if let adView = ad.mediaView {
            ad.registerAdView(adView, clickableAssetViews: [:])
            adView.frame = bounds
            adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(adView)
        }
    }
}
