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
import RazorpayAdsSdk
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
    var size: NativeAdSize? = nil
    /// Called after every per-asset tap (after `performClick` is invoked on the ad).
    /// Useful for surfacing the asset name in the demo UI for debugging.
    var onAssetTapped: ((String) -> Void)? = nil

    @State private var didRecordImpression = false

    var body: some View {
        cardLayout {
            mediaView
            detailLayout {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ad").font(.caption2).foregroundStyle(.secondary)
                    if let headline = ad.getText(for: CustomNativeAsset.headline), !headline.isEmpty {
                        Text(headline)
                            .font(.headline)
                            .lineLimit(size == nil ? nil : 2)
                            .fixedSize(horizontal: false, vertical: true)
                            .onTapGesture { performClick(on: CustomNativeAsset.clickUrl) }
                    }
                    if let text = ad.getText(for: "Attribution") ?? ad.getText(for: CustomNativeAsset.body), !text.isEmpty {
                        Text(text)
                            .font(.footnote)
                            .lineLimit(size == nil ? nil : 2)
                            .fixedSize(horizontal: false, vertical: true)
                            .onTapGesture { performClick(on: CustomNativeAsset.clickUrl) }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let logo = gamBridge?.getImage(for: CustomNativeAsset.logo) {
                    Group {
                        if let bitmap = logo.image {
                            Image(uiImage: bitmap).resizable().scaledToFit()
                        } else if let url = logo.imageURL {
                            AsyncImage(url: url) { image in image.resizable().scaledToFit() }
                                placeholder: { Color.clear }
                        }
                    }
                    .frame(width: 32, height: 32)
                    .onTapGesture { performClick(on: CustomNativeAsset.clickUrl) }
                }
                if let cta = ad.getText(for: CustomNativeAsset.cta), !cta.isEmpty {
                    Button { performClick(on: CustomNativeAsset.cta) } label: {
                        Text(cta)
                            .font(.subheadline.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: size == nil ? nil : .infinity)
                            .foregroundStyle(.white)
                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: size == nil ? 140 : .infinity)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .padding(.top, hasMedia && size != .small ? 0 : 12)
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
        .background(CustomNativeViewabilityTracker(ad: ad))
        .padding(.horizontal, 12)
        .onAppear {
            guard !didRecordImpression else { return }
            ad.recordNativeImpression()
            didRecordImpression = true
        }
    }

    private var cardLayout: AnyLayout {
        size == .small ? AnyLayout(NativeCompactLayout()) : AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
    }
    private var detailLayout: AnyLayout {
        size == nil ? AnyLayout(HStackLayout(alignment: .center, spacing: 12)) : AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
    }

    private var gamBridge: MediationNativeCustomFormatAdGAM? { ad as? MediationNativeCustomFormatAdGAM }
    private var hasMedia: Bool {
        ad.mediaView != nil || gamBridge?.getMediaContent() != nil || gamBridge?.getImage(for: CustomNativeAsset.image) != nil
    }

    @ViewBuilder
    private var mediaView: some View {
        if hasMedia {
            rawMediaView
                .modifier(NativeMediaSizing(size: size, defaultRatio: mediaRatio))
                .clipped()
        }
    }

    private var mediaRatio: CGFloat {
        let ratio = gamBridge?.getMediaContent()?.aspectRatio ?? 0
        return ratio.isFinite && ratio > 0 ? CGFloat(ratio) : 16.0 / 9.0
    }

    @ViewBuilder
    private var rawMediaView: some View {
        if let media = ad.mediaView {
            // No enclosing tap gesture: playback, mute and skip belong to the SDK.
            EmbeddedAdMediaView(media: media)
        } else if let content = gamBridge?.getMediaContent() {
            GoogleCustomNativeMedia(content: content)
        } else if let asset = gamBridge?.getImage(for: CustomNativeAsset.image) {
            Group {
                if let bitmap = asset.image {
                    Image(uiImage: bitmap).resizable().scaledToFit()
                } else if let url = asset.imageURL {
                    // Razorpay exposes image assets by URL; a nil bitmap is not a missing asset.
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.gray.opacity(0.08).overlay(ProgressView())
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
            .onTapGesture { performClick(on: CustomNativeAsset.clickUrl) }
        }
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

private struct GoogleCustomNativeMedia: UIViewRepresentable {
    let content: GoogleMobileAds.MediaContent
    func makeUIView(context: Context) -> GoogleMobileAds.MediaView {
        let view = GoogleMobileAds.MediaView()
        view.mediaContent = content
        return view
    }
    func updateUIView(_ uiView: GoogleMobileAds.MediaView, context: Context) {}
}
