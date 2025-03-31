
# AdSter SDK Documentation

## Overview

The AdSter SDK provides integration for multiple ad types, including Banner, Interstitial, Rewarded, and Native Ads. To use the SDK, you need to configure ad requests, initialize the SDK, and conform to the necessary protocols to handle ad events such as loading, impressions, and clicks.

## SDK Initialization

Before requesting any ads, you need to initialize the SDK. This is a one-time setup step that should be done at the start of your application. This framework depends on RealmSwift. Please install RealmSwift via Swift Package Manager - https://github.com/realm/realm-swift.git.

### Installation via CocoaPods

To integrate YourSDK into your Xcode project using CocoaPods, follow these steps:

Open your project's Podfile and add:
```ruby
 pod 'Adster', '~> 1.0.2'
 ```
 
Run the following command in the terminal:
 ```
 pod install
  ```
  
After installation, close Xcode and open the .xcworkspace file instead of .xcodeproj.a


### Example:

```swift
AdSter.sharedInstance().start(completionHandler: { status in
    print("Ad initialized \(status)")
})
```

- `completionHandler`: A callback to confirm whether the initialization was successful.

## Ad Request

To request an ad, you need to initialize the `AdSterAdLoader` and configure it with the required parameters:

```swift
let loader = AdSterAdLoader()
loader.delegate = self
loader.loadAd(adRequestConfiguration: AdRequestConfiguration(placement: key, viewController: self, publisherProvidedId: "Test", customTargetingValues: ["test": "123"]))
```

- `placement`: Unique key for the ad placement.
- `viewController`: ViewController where the ad will be presented.
- `publisherProvidedId`: Identifier for the ad unit.
- `customTargetingValues`: Optional custom targeting values to personalize the ad request.

## Banner Ad

To receive Banner Ads, you need to conform to the `MediationAdDelegate` protocol. This protocol will notify you when the ad is successfully loaded or failed to load.

### Example:

```swift
extension MainViewController: MediationAdDelegate {
    func onAdFailedToLoad(error: AdError) {
        print("Banner Ad request failed with reason \(error.description)")
    }

    func onBannerAdLoaded(bannerAd: MediationBannerAd) {
        guard let bannerview = bannerAd.view else {
            print("Banner Ad request failed with reason banner ad null")
            return
        }
        addBannerViewToView(bannerview)
        bannerAd.eventDelegate = self
    }
}
```

To track click and impression events for Banner Ads, conform to `MediationBannerAdEventDelegate`:

```swift
extension MainViewController: MediationBannerAdEventDelegate {
    func recordClick() {
        // Ad click recorded
    }
    
    func recordImpression() {
        // Ad impression recorded
    }
}
```

## Interstitial Ad

To receive Interstitial Ads, you need to conform to the `MediationAdDelegate` protocol. Once the ad is loaded, it can be presented by calling `presentInterstitial(from:)`.

### Example:

```swift
extension MainViewController: MediationAdDelegate {
    func onInterstitialAdLoaded(interstitialAd: any MediationInterstitialAd) {
        interstitialAd.presentInterstitial(from: self)
        interstitialAd.eventDelegate = self
    }

    func onAdFailedToLoad(error: AdError) {
        print("Interstitial Ad request failed with reason \(error.description)")
    }
}
```

To track click, impression, and fullscreen events, conform to `MediationInterstitialAdEventDelegate`:

```swift
extension MainViewController: MediationInterstitialAdEventDelegate {
    func ad(didFailToPresentFullScreenContentWithError error: AdError) {
        // Handle error when fullscreen content fails to present
    }
    
    func adWillPresentFullScreenContent() {
        // Prepare for the fullscreen content to present
    }
    
    func adDidDismissFullScreenContent() {
        // Handle when fullscreen content is dismissed
    }

    func recordClick() {
        // Ad click recorded
    }
    
    func recordImpression() {
        // Ad impression recorded
    }
}
```

## Rewarded Ad

To receive Rewarded Ads, conform to the `MediationAdDelegate` protocol. Once the ad is loaded, it can be presented by calling `presentRewarded(from:)`.

### Example:

```swift
extension MainViewController: MediationAdDelegate {
    func onRewardedAdLoaded(rewardedAd: any MediationRewardedAd) {
        rewardedAd.presentRewarded(from: self)
        rewardedAd.eventDelegate = self
    }

    func onAdFailedToLoad(error: AdError) {
        print("Rewarded Ad request failed with reason \(error.description)")
    }
}
```

To track rewarded video events, conform to `MediationRewardedAdEventDelegate`:

```swift
extension MainViewController: MediationRewardedAdEventDelegate {
    func didRewardUser() {
        // User rewarded
    }
    
    func didStartVideo() {
        // Video started
    }
    
    func didEndVideo() {
        // Video ended
    }

    func recordClick() {
        // Ad click recorded
    }
    
    func recordImpression() {
        // Ad impression recorded
    }
}
```

## Native Ad

To receive Native Ads, conform to the `MediationAdDelegate` protocol. Once the ad is loaded, you can populate your custom native ad view with the ad's data.

### Example:

```swift
extension MainViewController: MediationAdDelegate {
    func onNativeAdLoaded(nativeAd: any MediationNativeAd) {
        nativeAd.eventDelegate = self
        guard let nibObjects = Bundle.main.loadNibNamed("NativeView", owner: nil, options: nil),
              let adView = nibObjects.first as? MediationNativeAdView else {
            printLog("Could not load nib file for adView")
            return
        }
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.ctaView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (adView.ctaView as? UIButton)?.isUserInteractionEnabled = false
        if let mediaView = nativeAd.mediaView {
            addMediaViewToParentView(childView: mediaView, parentView: adView.mediaView)
        }
        
        adView.setNativeAd(nativeAd: nativeAd)
        viewBanner.addSubview(adView)
    }

    func onAdFailedToLoad(error: AdError) {
        print("Native Ad request failed with reason \(error.description)")
    }
}
```

To track impression and click events for Native Ads, conform to `MediationNativeAdEventDelegate`:

```swift
extension MainViewController: MediationNativeAdEventDelegate {
    func recordClick() {
        // Ad click recorded
    }
    
    func recordImpression() {
        // Ad impression recorded
    }
}
```

## Conclusion

The AdSter SDK offers a powerful and flexible way to integrate various ad types into your app. By initializing the SDK and conforming to the relevant protocols for each ad type, you can easily handle ad loading, presenting, and tracking events such as impressions and clicks.
