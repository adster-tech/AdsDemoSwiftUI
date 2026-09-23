# Erelego local SDK demo

Open `MoneyMath.xcodeproj`, select the `AdsDemoSwiftUI` scheme and an iOS device or simulator, then build and run.

The demo builds the local SDK from `../Erelego/erelego-ios-sdk/Erelego.xcodeproj` and links/embeds its `ErelegoKit.framework` product. Keep `AdsDemoSwiftUI/` and `Erelego/` under the same parent directory, with the SDK checkout at `Erelego/erelego-ios-sdk/`. SDK source edits are rebuilt with the demo; no copied XCFramework or published SDK package is required. Xcode still resolves the SDK's third-party Swift package dependencies.

The app uses `import ErelegoKit`, `Erelego.sharedInstance().start(...)`, and `ErelegoAdLoader`. In Settings → Ads, tap **Initialize Erelego SDK**, then choose a network, format, and placement. Ad controls become available when initialization returns a non-nil result; a nil result displays a retry message.

The UI uses Erelego branding, while `SdkType.placementPrefix` preserves the backend's existing placement names. The app bundle identifier remains `com.adster.demoAdsApp` because remote configuration uses it to select this demo's configuration. Network endpoints, ad application IDs, and publisher-provided IDs are unchanged.

To build without device signing:

```sh
xcodebuild -project MoneyMath.xcodeproj -scheme AdsDemoSwiftUI \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```
