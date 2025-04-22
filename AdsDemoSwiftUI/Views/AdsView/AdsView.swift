//
//  AdView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 10/03/25.
//
import SwiftUI

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
            selectedKeyView
                .onTapGesture {
                    viewModel.loadAdActivity()
                }
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
    
    private var selectedKeyView: some View {
        Text("Selected key: \(viewModel.displayKey)")
            .font(.callout)
            .bold()
            .underline()
            .foregroundColor(.brown)
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
