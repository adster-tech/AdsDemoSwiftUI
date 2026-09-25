//
//  AdView.swift
//  AdsDemoSwiftUI
//
//  Created by Adverge on 10/03/25.
//
import SwiftUI
import AdvergeAdsSdk
struct AdView: View {
    @StateObject var viewModel: AdsViewModel
    
    var body: some View {
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
                NativeAdView(ad: mediationNativeAd)
                    .frame(alignment: .center)
            }
            if !viewModel.carouselNativeAds.isEmpty {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.carouselNativeAds.enumerated()), id: \.offset) { _, nativeAd in
                            NativeAdView(ad: nativeAd)
                                .frame(width: UIScreen.main.bounds.width * 0.8, height: 260, alignment: .topLeading)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            if let customNativeAd = viewModel.mediationCustomNativeAd {
                CustomNativeAdView(ad: customNativeAd)
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
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            
            Text(viewModel.isAdvergeInitialized ? "Adverge SDK is initialized" : "Adverge SDK not initialized")
                .font(.subheadline)
                .foregroundColor(viewModel.isAdvergeInitialized ? .green : .red)
                .padding(8)
                .background(viewModel.isAdvergeInitialized ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
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
        .disabled(!viewModel.isAdvergeInitialized)
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
