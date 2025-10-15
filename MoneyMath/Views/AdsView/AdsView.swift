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
        VStack(spacing: 24) {
            detailsView
            Spacer()
            if let bannerView = viewModel.bannerView {
                bannerView
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            if let mediationNativeAd = viewModel.mediationNativeAd {
                NativeAdView(ad: mediationNativeAd)
                    .frame(alignment: .center)
            }
            Spacer()
        }.frame(maxWidth: .infinity, alignment: .leading)
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
    private var errorView: some View {
        if let error = viewModel.error {
            Text("Error: \(error)")
                .font(.callout)
                .foregroundColor(.red)
        }
    }
}
