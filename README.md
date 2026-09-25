# Adverge SwiftUI demo

Open `MoneyMath.xcodeproj` and run the `AdsDemoSwiftUI` scheme. The app displays as **Adverge Demo** and builds/embeds the local `AdvergeAdsSdk` source project at `../Adverge/ios-sdk/AdvergeAdsSdk/AdvergeAdsSdk.xcodeproj`.

The SDK screen uses `Adverge.sharedInstance()` and `AdvergeAdLoader`, and enables ad loading after the initialization callback. Adapter choices use Adverge placement keys (`Adverge-*` and `Adverge-Direct-*`). The application bundle ID is `com.adverge.demoAdsApp`.

Config, targeting, ad requests and analytics use the Adverge endpoints (`*.adverge.tech`); legacy config filenames use `com_adverge_usdk`. The backend must provide matching bundle and placement configuration.

Build without signing:

```sh
xcodebuild -project MoneyMath.xcodeproj -scheme AdsDemoSwiftUI \
  -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```
