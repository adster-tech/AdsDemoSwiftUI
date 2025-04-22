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
        let screenWidth = UIScreen.main.bounds.width
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: screenWidth),
            // Center bannerView inside containerView
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Set bannerView’s size explicitly or rely on its intrinsic size
            bannerView.widthAnchor.constraint(equalToConstant: bannerView.frame.size.width),
            bannerView.heightAnchor.constraint(equalToConstant: bannerView.frame.size.height),
            
            // Make containerView match bannerView’s size
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
