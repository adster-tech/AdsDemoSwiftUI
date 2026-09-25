# Adverge SwiftUI demo

Open `MoneyMath.xcodeproj` and run the `AdsDemoSwiftUI` scheme. The app displays as **Adverge Demo** and builds/embeds the local `AdvergeAdsSdk` source project at `../Adverge/ios-sdk/AdvergeAdsSdk/AdvergeAdsSdk.xcodeproj`.

The SDK screen uses `Adverge.sharedInstance()` and `AdvergeAdLoader`, and enables ad loading after the initialization callback. Adverge-branded adapter choices retain the existing service placement keys (`Adster-*` and `Adster-Direct-*`). The application bundle ID remains `com.adster.demoAdsApp`, matching its current service configuration.

The SDK currently uses the existing Adster backend. Update SDK endpoints and provision matching bundle/placement configuration before switching to an Adverge-specific backend.

Build without signing:

```sh
xcodebuild -project MoneyMath.xcodeproj -scheme AdsDemoSwiftUI \
  -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```
