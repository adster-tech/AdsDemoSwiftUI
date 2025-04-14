//
//  BannerView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 11/03/25.
//

import SwiftUI

struct BannerAdView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    let bannerView: UIView
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bannerView)
        
        // Ensure containerView has its own size constraints
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: bannerView.frame.width),
            containerView.heightAnchor.constraint(equalToConstant: bannerView.frame.height)
        ])
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: 80),
            containerView.topAnchor.constraint(equalTo: bannerView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
        ])
        return containerView
    }
}

struct MediaAdView: UIViewRepresentable {
    let bannerView: UIView
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
              containerView.translatesAutoresizingMaskIntoConstraints = false
              containerView.addSubview(bannerView)

              bannerView.translatesAutoresizingMaskIntoConstraints = false

              NSLayoutConstraint.activate([
                  bannerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                  bannerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                  bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
                  bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
              ])
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Ensure updates are handled correctly
    }
}
