//
//  AdView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 10/03/25.
//
import SwiftUI
import AdsFramework
struct AdView: View {
    @StateObject var viewModel: AdsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if viewModel.nativeAdSize == .fullscreen {
                fullscreenNativeContent
            } else {
                inlineContent
            }
        }
        .toolbar(viewModel.nativeAdSize == .fullscreen ? .hidden : .automatic, for: .tabBar)
        .toolbar(viewModel.nativeAdSize == .fullscreen ? .hidden : .automatic, for: .navigationBar)
        .onDisappear {
            viewModel.releaseAds()
            viewModel.didAppear = false
        }
        .onAppear {
            guard !viewModel.didAppear else { return }
            viewModel.didAppear = true
            viewModel.loadAdActivity()
        }
    }

    private var fullscreenNativeContent: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Native ad · Fullscreen").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Button { dismiss() } label: { Label("Close ad", systemImage: "xmark") }
                    .buttonStyle(.bordered)
            }
            .padding(.horizontal, 12)
            if let ad = viewModel.mediationNativeAd {
                NativeAdView(ad: ad, size: .fullscreen)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let ad = viewModel.mediationCustomNativeAd {
                CustomNativeAdView(ad: ad, size: .fullscreen)
                    .id(ObjectIdentifier(ad))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView { detailsView }
                    .frame(maxHeight: .infinity)
            }
        }
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
    }

    private var inlineContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                detailsView
                if let bannerView = viewModel.bannerView {
                    bannerView
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                if !viewModel.carouselBannerViews.isEmpty {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.carouselBannerViews.enumerated()), id: \.offset) { _, bannerView in
                                bannerView
                                    .frame(width: 300, height: 250)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                if let mediationNativeAd = viewModel.mediationNativeAd {
                    NativeAdView(ad: mediationNativeAd, size: viewModel.nativeAdSize)
                        .frame(alignment: .center)
                }
                if !viewModel.carouselNativeAds.isEmpty {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.carouselNativeAds.enumerated()), id: \.offset) { _, nativeAd in
                                NativeAdView(ad: nativeAd)
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .topLeading)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                if let nativeRewardAd = viewModel.mediationNativeRewardAd {
                    NativeRewardOfferView(ad: nativeRewardAd)
                        .id(ObjectIdentifier(nativeRewardAd))
                        .frame(height: 430)
                }
                if !viewModel.carouselNativeRewardAds.isEmpty {
                    NativeRewardCarouselView(ads: viewModel.carouselNativeRewardAds)
                }
                if let customNativeAd = viewModel.mediationCustomNativeAd {
                    CustomNativeAdView(ad: customNativeAd, size: viewModel.nativeAdSize)
                        .id(ObjectIdentifier(customNativeAd))
                        .frame(maxWidth: .infinity, alignment: .top)
                    if let clickMessage = viewModel.lastCustomNativeClickMessage {
                        Text(clickMessage)
                            .font(.footnote)
                            .foregroundColor(.green)
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                            .padding(.horizontal, 12)
                    }
                }
                if !viewModel.carouselCustomNativeAds.isEmpty {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.carouselCustomNativeAds.enumerated()), id: \.offset) { _, ad in
                                CustomNativeAdView(ad: ad)
                                    .id(ObjectIdentifier(ad))
                                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .topLeading)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    if let message = viewModel.lastCustomNativeClickMessage {
                        Text(message).font(.footnote).foregroundColor(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.bottom, 24)
        }
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            initializationStatusView
            selectedKeyView
                .onTapGesture {
                    viewModel.loadAdActivity()
                }
            revenueView
            adInspectorButton
            if viewModel.isLoading {
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
    
    private var initializationStatusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SDK Status")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(viewModel.isAdsterInitialized ? "Adster SDK is initialized" : "Adster SDK not initialized")
                .font(.subheadline)
                .foregroundColor(viewModel.isAdsterInitialized ? .green : .red)
                .padding(8)
                .background(viewModel.isAdsterInitialized ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(6)
        }
    }
    
    private var selectedKeyView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Selected key: \(viewModel.displayKey)")
                .font(.callout)
                .bold()
                .underline()
                .foregroundColor(.brown)
            if let size = viewModel.nativeAdSize {
                Text("Native size: \(size.title)").font(.footnote).foregroundColor(.secondary)
            }
            Text("Placement: \(viewModel.placementKey)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var revenueView: some View {
        if let revenueMessage = viewModel.revenueMessage {
            Text(revenueMessage)
                .font(.footnote)
                .foregroundColor(.purple)
                .padding(8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
        }
    }
    
    private var adInspectorButton: some View {
        Button(action: {
            viewModel.launchAdInspector()
        }) {
            Text("Launch Ad Inspector")
                .font(.callout)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .disabled(!viewModel.isAdsterInitialized)
    }
    
    @ViewBuilder
    private var errorView: some View {
        if let error = viewModel.error {
            Text("Error: \(error)")
                .font(.callout)
                .foregroundColor(.red)
        }
    }
}
