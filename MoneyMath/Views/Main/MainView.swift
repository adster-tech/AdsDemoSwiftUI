//
//  MainView.swift
//  AdsDemoSwiftUI
//
//  Created by Adverge on 10/03/25.
//

import SwiftUI
import AdvergeAdsSdk

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isAdvergeInitialized = false
    @State private var advergeStatusMessage = "Adverge SDK not initialized"
    @State private var isInitializing = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            advergeStatusView
            selectionView
            keyListView
        }
        .navigationDestination(
            isPresented: $viewModel.isLinkClicked,
            destination: {
                if let key = viewModel.selectedKey {
                    if viewModel.selectedAdType == .nativeReward {
                        NativeRewardScratchView(viewModel: .init(key: key, isAdvergeInitialized: isAdvergeInitialized))
                    } else {
                        AdView(viewModel: .init(key: key, isAdvergeInitialized: isAdvergeInitialized))
                    }
                }
            }
        )
    }
    
    private var advergeStatusView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Adverge SDK Status")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(advergeStatusMessage)
                    .font(.subheadline)
                    .foregroundColor(isAdvergeInitialized ? .green : .orange)
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
            
            Button(action: initializeAdvergeSDK) {
                HStack {
                    Image(systemName: "power")
                    Text("Initialize Adverge SDK")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAdvergeInitialized || isInitializing)
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
        .background(Color.gray.opacity(isAdvergeInitialized ? 0.5 : 0.2))
        .disabled(!isAdvergeInitialized)
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
                let text = "\(viewModel.selectedSdkType.placementPrefix)-\(viewModel.selectedAdType.rawValue)-\(count)"
                Text(text)
                    .font(.body)
                    .foregroundColor(isAdvergeInitialized ? .primary : .secondary)
                    .onTapGesture {
                        if isAdvergeInitialized {
                            viewModel.select(text)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
    
    // MARK: Adverge SDK Functions
    private func initializeAdvergeSDK() {
        isInitializing = true
        advergeStatusMessage = "Initializing Adverge SDK..."
        
        Adverge.sharedInstance().start { status in
            DispatchQueue.main.async {
                self.isInitializing = false
                self.isAdvergeInitialized = status != nil
                self.advergeStatusMessage = status != nil
                    ? "Adverge SDK initialized successfully"
                    : "Adverge SDK initialization failed. Please try again."
            }
        }
    }
}

#Preview {
    MainView(viewModel: .init())
}
