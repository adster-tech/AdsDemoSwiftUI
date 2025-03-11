//
//  NativeAdView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//

import SwiftUI
import AdsFramework

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
        if let media = ad.mediaView {
            BannerAdView(bannerView: media)
                .background(Color.red)
                .frame(width: 200, height: 200)
        }
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            headlineView
            bodyView
            ctaView
            mediaView
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
