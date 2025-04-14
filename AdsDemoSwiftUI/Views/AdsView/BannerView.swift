//
//  BannerView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//

import SwiftUI
import AdsFramework

struct BannerAdView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    let bannerView: UIView
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bannerView)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Set bannerView's size constraints
            bannerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Container view should size to fit the banner view
            containerView.widthAnchor.constraint(equalTo: bannerView.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: bannerView.heightAnchor)
        ])
        
        return containerView
    }
}

struct MediaAdView: UIViewRepresentable {
    let mediationAd: MediationNativeAd
    func makeUIView(context: Context) -> UIView {
        let containerView = NativeAdContainerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        containerView.configure(with: mediationAd)
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
