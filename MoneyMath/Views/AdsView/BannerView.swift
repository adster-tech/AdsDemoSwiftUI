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
        let resolvedSize = resolvedBannerSize(for: bannerView)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: screenWidth),
            // Center bannerView inside containerView
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            bannerView.widthAnchor.constraint(equalToConstant: resolvedSize.width),
            bannerView.heightAnchor.constraint(equalToConstant: resolvedSize.height),
            
            // Make containerView match bannerView’s size
            containerView.heightAnchor.constraint(equalTo: bannerView.heightAnchor)
        ])
        
        return containerView
    }

    private func resolvedBannerSize(for view: UIView) -> CGSize {
        let frameSize = view.frame.size
        if frameSize.width > 0, frameSize.height > 0 {
            return frameSize
        }

        let intrinsicSize = view.intrinsicContentSize
        let width = intrinsicSize.width > 0 && intrinsicSize.width != UIView.noIntrinsicMetric
            ? intrinsicSize.width
            : 300
        let height = intrinsicSize.height > 0 && intrinsicSize.height != UIView.noIntrinsicMetric
            ? intrinsicSize.height
            : 250
        return CGSize(width: width, height: height)
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
