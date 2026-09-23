//
//  CustomNativeAdView.swift
//  AdsDemoSwiftUI
//
//  Renders a `MediationNativeCustomFormatAd` (custom native ad) and wires every
//  tappable asset to `ad.performClick(on:)`. When the placement has
//  `customClickEnabled: true` server-side, each tap is delivered back through
//  `MediationNativeCustomAdEventDelegate.recordNativeCustomClick(ad:, assetName:)`
//  instead of the underlying ad SDK auto-opening a URL.
//

import SwiftUI
import UIKit
import ErelegoKit
import GoogleMobileAds

/// Conventional asset keys used by GAM custom native templates. The actual list of
/// available assets can be discovered at runtime via `ad.getAvailableAssetNames()`.
private enum CustomNativeAsset {
    static let headline = "Headline"
    static let body = "Body"
    static let cta = "Calltoaction"
    static let image = "Image"
    static let logo = "Share"
    static let clickUrl = "clickactionurl"
}

struct CustomNativeAdView: View {
    let ad: MediationNativeCustomFormatAd
    /// Called after every per-asset tap (after `performClick` is invoked on the ad).
    /// Useful for surfacing the asset name in the demo UI for debugging.
    var onAssetTapped: ((String) -> Void)? = nil

    @State private var didRecordImpression = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            assetsView
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .background(CustomNativeViewabilityTracker(ad: ad))
        .padding(.horizontal, 12)
        .onAppear {
            guard !didRecordImpression else { return }
            ad.recordNativeImpression()
            didRecordImpression = true
        }
    }

    // MARK: - Sections

    private var headerView: some View {
        HStack(alignment: .top, spacing: 12) {
            if let logoImage = uiImage(for: CustomNativeAsset.logo) {
                Image(uiImage: logoImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                    .onTapGesture {
                        performClick(on: CustomNativeAsset.clickUrl)
                    }
            }
            if let headline = ad.getText(for: CustomNativeAsset.headline) {
                Text(headline)
                    .font(.headline)
                    .lineLimit(2)
                    .onTapGesture {
                        performClick(on: CustomNativeAsset.clickUrl)
                    }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var assetsView: some View {
        if let bodyText = ad.getText(for: CustomNativeAsset.body) {
            Text(bodyText)
                .font(.footnote)
                .foregroundColor(.primary)
                .lineLimit(nil)
                .onTapGesture {
                    performClick(on: CustomNativeAsset.clickUrl)
                }
        }

        if let mainImage = uiImage(for: CustomNativeAsset.image) {
            Image(uiImage: mainImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
                .onTapGesture {
                    performClick(on: CustomNativeAsset.clickUrl)
                }
        }

        if let ctaText = ad.getText(for: CustomNativeAsset.cta) {
            Button {
                performClick(on: CustomNativeAsset.cta)
            } label: {
                Text(ctaText)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    /// Pulls a `UIImage` out of the ad. The GAM `NativeAdImage` returned by the
    /// `MediationNativeCustomFormatAdGAM` bridge exposes the bitmap through
    /// its `image` property when the asset is loaded in-process.
    private func uiImage(for assetName: String) -> UIImage? {
        guard let gamBridge = ad as? MediationNativeCustomFormatAdGAM else { return nil }
        return gamBridge.getImage(for: assetName)?.image
    }

    /// Triggers a custom click on the named asset. The SDK forwards the call to
    /// `MediationNativeCustomFormatAd.performClick(on:)`, which — when custom click
    /// is enabled on the placement config — routes the event back through
    /// `MediationNativeCustomAdEventDelegate.recordNativeCustomClick(ad:, assetName:)`.
    private func performClick(on assetName: String) {
        ad.performClick(on: assetName)
        onAssetTapped?(assetName)
    }
}

private struct CustomNativeViewabilityTracker: UIViewRepresentable {
    let ad: MediationNativeCustomFormatAd

    func makeUIView(context: Context) -> ViewabilityTrackingView {
        let view = ViewabilityTrackingView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.ad = ad
        return view
    }

    func updateUIView(_ uiView: ViewabilityTrackingView, context: Context) {
        uiView.ad = ad
        uiView.requestTrackingIfReady()
    }
}

private final class ViewabilityTrackingView: UIView {
    weak var ad: MediationNativeCustomFormatAd?
    private var hasRequestedTracking = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        requestTrackingIfReady()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        requestTrackingIfReady()
    }

    func requestTrackingIfReady() {
        guard !hasRequestedTracking, window != nil, bounds.width > 0, bounds.height > 0 else { return }
        hasRequestedTracking = true
        ad?.trackViewability(self)
    }
}
