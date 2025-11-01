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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            selectionView
            keyListView
        }
        .navigationDestination(
            isPresented: $viewModel.isLinkClicked,
            destination: {
                if let key = viewModel.selectedKey {
                    AdView(viewModel: .init(key: key))
                }
            }
        )
    }
    
    private var selectionView: some View {
        VStack(spacing: 32) {
            sdkView
            adTypesView
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.5))
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
                let text = "\(viewModel.selectedSdkType.rawValue)-\(viewModel.selectedAdType.rawValue)-\(count)"
                Text(text)
                    .font(.body)
                    .onTapGesture {
                        viewModel.select(text)
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }
}

#Preview {
    MainView(viewModel: .init())
}
