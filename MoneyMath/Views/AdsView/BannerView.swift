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
    let fillsAvailableWidth: Bool

    init(bannerView: UIView, fillsAvailableWidth: Bool = true) {
        self.bannerView = bannerView
        self.fillsAvailableWidth = fillsAvailableWidth
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        containerView.addSubview(bannerView)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.clipsToBounds = true
        let bannerSize = resolvedBannerSize
        let containerWidth = fillsAvailableWidth ? UIScreen.main.bounds.width : bannerSize.width
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: containerWidth),
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: bannerSize.width),
            bannerView.heightAnchor.constraint(equalToConstant: bannerSize.height),
            containerView.heightAnchor.constraint(equalTo: bannerView.heightAnchor)
        ])
        
        return containerView
    }

    private var resolvedBannerSize: CGSize {
        let intrinsicSize = bannerView.intrinsicContentSize
        if intrinsicSize.width > 0, intrinsicSize.height > 0 {
            return intrinsicSize
        }

        let frameSize = bannerView.frame.size
        if frameSize.width > 0, frameSize.height > 0 {
            return frameSize
        }

        return CGSize(width: 300, height: 250)
    }
}
