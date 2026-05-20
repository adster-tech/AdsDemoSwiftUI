//
//  MainView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 10/03/25.
//

import SwiftUI
import AdsFramework

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isAdsterInitialized = false
    @State private var adsterStatusMessage = "Adster SDK not initialized"
    @State private var isInitializing = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            adsterStatusView
            selectionView
            keyListView
        }
        .navigationDestination(
            isPresented: $viewModel.isLinkClicked,
            destination: {
                if let key = viewModel.selectedKey {
                    AdView(viewModel: .init(key: key, isAdsterInitialized: isAdsterInitialized))
                }
            }
        )
    }
    
    private var adsterStatusView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Adster SDK Status")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(adsterStatusMessage)
                    .font(.subheadline)
                    .foregroundColor(isAdsterInitialized ? .green : .orange)
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
            
            Button(action: initializeAdsterSDK) {
                HStack {
                    Image(systemName: "power")
                    Text("Initialize Adster SDK")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAdsterInitialized || isInitializing)
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
        .background(Color.gray.opacity(isAdsterInitialized ? 0.5 : 0.2))
        .disabled(!isAdsterInitialized)
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
            ForEach(0..<10) { count in
                let text = viewModel.displayName(index: count)
                Text(text)
                    .font(.body)
                    .foregroundColor(isAdsterInitialized ? .primary : .secondary)
                    .onTapGesture {
                        if isAdsterInitialized {
                            viewModel.select(viewModel.placementKey(index: count))
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
    
    // MARK: Adster SDK Functions
    private func initializeAdsterSDK() {
        isInitializing = true
        adsterStatusMessage = "Initializing Adster SDK..."
        
        // Simulate SDK initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            AdSter.sharedInstance().start() // Initialize the Adster SDK
            self.isInitializing = false
            self.isAdsterInitialized = true
            self.adsterStatusMessage = "Adster SDK initialized successfully"
        }
    }
}

#Preview {
    MainView(viewModel: .init())
}
