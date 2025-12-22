//
//  CarouselViewModel.swift
//  AdsDemoSwiftUI
//
//  Created by Adster on 18/12/25.
//

import Combine
import AdsFramework
import SwiftUI

enum CarouselItem {
    case image(String)
    case banner(BannerAdView?)
}

class CarouselViewModel: ObservableObject {
    @Published var items: [CarouselItem] = []
    private let placementId = "gam_banner_0"
    private var loadedAdIndices: Set<Int> = []
    private var adLoaders: [Int: AdSterAdLoader] = [:] // Keep loaders alive
    private var adDelegates: [Int: BannerAdLoaderDelegate] = [:] // Keep delegates alive

    // Random SF Symbol names for images
    private let imageNames = [
        "photo.fill", "star.fill", "heart.fill", "cloud.fill",
        "sun.max.fill", "moon.fill", "leaf.fill", "flame.fill",
        "drop.fill", "snowflake", "bolt.fill", "tornado",
        "sparkles", "camera.fill", "music.note", "book.fill",
        "pencil", "paintbrush.fill", "hammer.fill", "wrench.fill"
    ]

    init() {
        setupItems()
    }

    private func setupItems() {
        var itemsArray: [CarouselItem] = []
        var imageCount = 0

        // Create carousel with images and ad placeholders
        // Total of 12 images with 4 banner ad slots (after every 3 images)
        for i in 0..<16 {
            if (i + 1) % 4 == 0 {
                // Every 4th position is a banner ad (after 3 images)
                itemsArray.append(.banner(nil))
            } else {
                // Add random image
                let randomImageName = imageNames.randomElement() ?? "photo.fill"
                itemsArray.append(.image(randomImageName))
                imageCount += 1
            }
        }

        self.items = itemsArray
    }

    func loadAdIfNeeded(for index: Int) {
        // Check if this index is a banner and hasn't been loaded yet
        guard index < items.count else { return }

        if case .banner(let existingBanner) = items[index], existingBanner == nil {
            // Only load if we haven't loaded this ad yet
            guard !loadedAdIndices.contains(index) else { return }
            loadedAdIndices.insert(index)

            loadBannerAd(at: index)
        }
    }

    private func loadBannerAd(at index: Int) {
        Task { @MainActor in
            // Get the current view controller properly
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("Failed to get root view controller at index \(index)")
                return
            }

            let loader = AdSterAdLoader()
            let delegate = BannerAdLoaderDelegate(viewModel: self, index: index)
            loader.delegate = delegate

            // Store loader and delegate to keep them alive
            adLoaders[index] = loader
            adDelegates[index] = delegate

            print("Loading banner ad at index \(index) with placement: \(placementId)")
            loader.loadAd(
                adRequestConfiguration: AdRequestConfiguration(
                    placement: placementId,
                    viewController: rootViewController,
                    publisherProvidedId: "carousel_banner",
                    customTargetingValues: ["position": "\(index)"]
                )
            )
        }
    }

    func updateBannerAd(at index: Int, with bannerView: UIView) {
        Task { @MainActor in
            guard index < items.count else { return }
            items[index] = .banner(BannerAdView(bannerView: bannerView))
        }
    }
}

// Separate delegate class to handle ad loading callbacks
class BannerAdLoaderDelegate: NSObject, MediationAdDelegate {
    weak var viewModel: CarouselViewModel?
    let index: Int

    init(viewModel: CarouselViewModel, index: Int) {
        self.viewModel = viewModel
        self.index = index
    }

    func onBannerAdLoaded(bannerAd: MediationBannerAd) {
        Task { @MainActor in
            print("✅ Banner ad loaded successfully at index \(index)")
            guard let bannerView = bannerAd.view else {
                print("❌ Banner Ad view is null at index \(index)")
                return
            }
            print("✅ Banner view obtained, updating carousel at index \(index)")
            viewModel?.updateBannerAd(at: index, with: bannerView)
        }
    }

    func onInterstitialAdLoaded(interstitialAd: MediationInterstitialAd) {
        // Not needed for carousel
    }

    func onRewardedAdLoaded(rewardedAd: MediationRewardedAd) {
        // Not needed for carousel
    }

    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: MediationRewardedInterstitialAd) {
        // Not needed for carousel
    }

    func onNativeAdLoaded(nativeAd: MediationNativeAd) {
        // Not needed for carousel
    }

    func onCustomNativeAdLoaded(customNativeAd: any MediationNativeCustomFormatAd) {
        // Not needed for carousel
    }

    func onAdFailedToLoad(error: AdError) {
        Task { @MainActor in
            print("❌ Failed to load banner ad at index \(index)")
            print("   Error: \(error.description)")
        }
    }
}
