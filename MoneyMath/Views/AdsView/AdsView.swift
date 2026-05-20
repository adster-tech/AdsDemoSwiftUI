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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                detailsView
                if let bannerView = viewModel.bannerView {
                    bannerView
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                carouselBannerView
                if let mediationNativeAd = viewModel.mediationNativeAd {
                    NativeAdView(ad: mediationNativeAd)
                        .frame(alignment: .center)
                }
                carouselNativeView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            guard !viewModel.didAppear else { return }
            viewModel.didAppear = true
            viewModel.loadAdActivity()
        }
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            initializationStatusView
            selectedKeyView
                .onTapGesture {
                    viewModel.loadAdActivity()
                }
            adInspectorButton
            eventLogView
            revenueLogView
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
        Text("Selected key: \(viewModel.displayKey)")
            .font(.callout)
            .bold()
            .underline()
            .foregroundColor(.brown)
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
    private var carouselBannerView: some View {
        if !viewModel.carouselBannerViews.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Carousel Banner Ads")
                    .font(.headline)
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(viewModel.carouselBannerViews) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Child \(item.index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                BannerAdView(bannerView: item.view)
                                    .frame(width: max(item.size.width, 320), height: max(item.size.height, 50), alignment: .center)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(6)
                            }
                            .frame(width: max(item.size.width, 320), alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
                .frame(height: carouselBannerHeight)
            }
        }
    }

    private var carouselBannerHeight: CGFloat {
        let maxHeight = viewModel.carouselBannerViews.map { max($0.size.height, 50) }.max() ?? 50
        return maxHeight + 36
    }

    @ViewBuilder
    private var carouselNativeView: some View {
        if !viewModel.carouselNativeAds.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Carousel Native Ads")
                    .font(.headline)
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(Array(viewModel.carouselNativeAds.enumerated()), id: \.offset) { _, nativeAd in
                            NativeAdView(ad: nativeAd)
                                .frame(width: UIScreen.main.bounds.width - 48, height: 320, alignment: .topLeading)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private var eventLogView: some View {
        if !viewModel.eventMessages.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ad Events")
                    .font(.headline)
                ForEach(Array(viewModel.eventMessages.prefix(5).enumerated()), id: \.offset) { _, message in
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var revenueLogView: some View {
        if !viewModel.revenueEvents.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Revenue Events")
                    .font(.headline)
                ForEach(Array(viewModel.revenueEvents.enumerated()), id: \.offset) { _, event in
                    Text(event)
                        .font(.caption)
                        .foregroundColor(.green)
                        .lineLimit(nil)
                }
            }
        }
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
