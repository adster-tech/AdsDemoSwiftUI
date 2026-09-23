//
//  MainView.swift
//  AdsDemoSwiftUI
//
//  Created by Erelego on 10/03/25.
//

import SwiftUI
import ErelegoKit

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isErelegoInitialized = false
    @State private var erelegoStatusMessage = "Erelego SDK not initialized"
    @State private var isInitializing = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            erelegoStatusView
            selectionView
            keyListView
        }
        .navigationDestination(
            isPresented: $viewModel.isLinkClicked,
            destination: {
                if let key = viewModel.selectedKey {
                    if viewModel.selectedAdType == .nativeReward {
                        NativeRewardScratchView(viewModel: .init(key: key, isErelegoInitialized: isErelegoInitialized))
                    } else {
                        AdView(viewModel: .init(key: key, isErelegoInitialized: isErelegoInitialized))
                    }
                }
            }
        )
    }
    
    private var erelegoStatusView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Erelego SDK Status")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(erelegoStatusMessage)
                    .font(.subheadline)
                    .foregroundColor(isErelegoInitialized ? .green : .orange)
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
            
            Button(action: initializeErelego) {
                HStack {
                    Image(systemName: "power")
                    Text("Initialize Erelego SDK")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isErelegoInitialized || isInitializing)
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
        .background(Color.gray.opacity(isErelegoInitialized ? 0.5 : 0.2))
        .disabled(!isErelegoInitialized)
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
                let placement = "\(viewModel.selectedSdkType.placementPrefix)-\(viewModel.selectedAdType.rawValue)-\(count)"
                Text(text)
                    .font(.body)
                    .foregroundColor(isErelegoInitialized ? .primary : .secondary)
                    .onTapGesture {
                        if isErelegoInitialized {
                            viewModel.select(placement)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
    
    // MARK: Erelego SDK Functions
    private func initializeErelego() {
        isInitializing = true
        erelegoStatusMessage = "Initializing Erelego SDK..."
        
        Erelego.sharedInstance().start { status in
            print("Erelego initialization: \(String(describing: status))")
            DispatchQueue.main.async {
                self.isInitializing = false
                self.isErelegoInitialized = status != nil
                self.erelegoStatusMessage = status != nil
                    ? "Erelego SDK initialization completed"
                    : "Erelego SDK initialization failed. Please try again."
            }
        }
    }
}

#Preview {
    MainView(viewModel: .init())
}
