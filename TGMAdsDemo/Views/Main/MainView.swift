//
//  MainView.swift
//  TGMAdsDemo
//
//  Created by TGM on 10/03/25.
//

import SwiftUI
import TGMAdsFramework

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isTGMInitialized = false
    @State private var tgmStatusMessage = "TGM SDK not initialized"
    @State private var isInitializing = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            tgmStatusView
            selectionView
            keyListView
        }
        .navigationDestination(
            isPresented: $viewModel.isLinkClicked,
            destination: {
                if let key = viewModel.selectedKey {
                    if viewModel.selectedAdType == .nativeReward || viewModel.selectedAdType == .carouselNativeReward {
                        NativeRewardScratchView(viewModel: .init(key: key, isTGMInitialized: isTGMInitialized))
                    } else {
                        AdView(viewModel: .init(key: key, isTGMInitialized: isTGMInitialized))
                    }
                }
            }
        )
    }
    
    private var tgmStatusView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("TGM SDK Status")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(tgmStatusMessage)
                    .font(.subheadline)
                    .foregroundColor(isTGMInitialized ? .green : .orange)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if isInitializing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.blue)
                    .frame(width: 50, height: 50)
                    .padding(16)
            }
            
            Button(action: initializeTGMSDK) {
                HStack {
                    Image(systemName: "power")
                    Text("Initialize TGM SDK")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isTGMInitialized || isInitializing)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var selectionView: some View {
        VStack(spacing: 32) {
            sdkView
            adTypesView
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(isTGMInitialized ? 0.5 : 0.2))
        .disabled(!isTGMInitialized)
    }
    
    private var sdkView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.sdkTypes, id: \.self) { list in
                HStack(alignment: .center, spacing: .zero) {
                    ForEach(list) { type in
                        Text(type.rawValue)
                            .font(.footnote)
                            .foregroundColor(
                                viewModel.selectedSdkType == type
                                ? .blue
                                : .black
                            )
                            .fontWeight(.semibold)
                            .underline(viewModel.selectedSdkType == type, color: .blue)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                viewModel.update(type)
                            }
                    }
                }
            }
        }
        .padding(8)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1)
        }
    }
    
    private var adTypesView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.sdkAdTypes, id: \.self) { list in
                HStack(alignment: .center, spacing: .zero) {
                    ForEach(list) { type in
                        Text(type.rawValue)
                            .font(.footnote)
                            .foregroundColor(
                                viewModel.selectedAdType == type
                                ? .blue
                                : .black
                            )
                            .fontWeight(.semibold)
                            .underline(viewModel.selectedAdType == type, color: .blue)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                viewModel.update(type)
                            }
                    }
                }
            }
        }
        .padding(8)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1)
        }
    }
    
    private var keyListView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.selectedKeyIndexes, id: \.self) { count in
                let text = "\(viewModel.selectedSdkType.rawValue)-\(viewModel.selectedAdType.rawValue)-\(count)"
                Text(text)
                    .font(.body)
                    .foregroundColor(isTGMInitialized ? .primary : .secondary)
                    .onTapGesture {
                        if isTGMInitialized {
                            viewModel.select(text)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
    
    // MARK: TGM SDK Functions
    private func initializeTGMSDK() {
        isInitializing = true
        tgmStatusMessage = "Initializing TGM SDK..."
        
        // Simulate SDK initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            AdSter.sharedInstance().start()  Initialize the TGM SDK
            AdSter.sharedInstance().start(completionHandler: { status in
                print("Ad initialized \(status)")
            })
            self.isInitializing = false
            self.isTGMInitialized = true
            self.tgmStatusMessage = "TGM SDK initialized successfully"
        }
    }
}

#Preview {
    MainView(viewModel: .init())
}
