//
//  CarouselView.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 18/12/25.
//

import SwiftUI
import AdsFramework

struct CarouselView: View {
    @StateObject private var viewModel = CarouselViewModel()
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Text("Image Carousel")
                .font(.title2)
                .bold()
                .padding()

            TabView(selection: $currentIndex) {
                ForEach(0..<viewModel.items.count, id: \.self) { index in
                    itemView(for: viewModel.items[index], index: index)
                        .frame(width: 300, height: 250)
                        .tag(index)
                }
            }
            .frame(height: 300)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onChange(of: currentIndex) { newValue in
                viewModel.loadAdIfNeeded(for: newValue)
            }
            .onAppear {
                viewModel.loadAdIfNeeded(for: currentIndex)
            }
        }
    }

    @ViewBuilder
    private func itemView(for item: CarouselItem, index: Int) -> some View {
        switch item {
        case .image(let imageName):
            randomImageView(imageName: imageName)
        case .banner(let bannerView):
            if let bannerView = bannerView {
                VStack(spacing: 8) {
                    Text("Advertisement")
                        .font(.caption)
                        .foregroundColor(.gray)

                    bannerView
                        .frame(width: 300, height: 250)
                }
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.blue)
                        .frame(width: 50, height: 50)
                    Text("Loading ad...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(width: 300, height: 250)
            }
        }
    }

    private func randomImageView(imageName: String) -> some View {
        ZStack {
            // Random gradient background
            LinearGradient(
                colors: [
                    Color(red: .random(in: 0.3...0.9),
                          green: .random(in: 0.3...0.9),
                          blue: .random(in: 0.3...0.9)),
                    Color(red: .random(in: 0.3...0.9),
                          green: .random(in: 0.3...0.9),
                          blue: .random(in: 0.3...0.9))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)

                Text("Random Image")
                    .font(.callout)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .frame(width: 300, height: 250)
        .cornerRadius(8)
    }
}

#Preview {
    CarouselView()
}
