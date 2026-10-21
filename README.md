# TGM Ads Demo

SwiftUI demo for the local TGM iOS SDK. Open **TGMAdsDemo.xcodeproj** and select the **TGMAdsDemo** scheme.

The project builds and embeds `TGMAdsFramework` from this relative path:

```text
../Clients/TGM/tgm-ios-sdk/TGMAdsFramework/TGMAdsFramework.xcodeproj
```

Expected checkout layout:

```text
Github/
  AdsDemoSwiftUI/
  Clients/TGM/tgm-ios-sdk/
```

The app bundle identifier is `com.tgm.demoAdsApp`. Device builds require a signing profile for that identifier. Existing Google application ID and ad configuration are retained; configure the TGM app/placements in your backend before testing client-specific ad serving.

The demo imports `TGMAdsFramework`; its SDK initialization and loader APIs remain named `AdSter` and `AdSterAdLoader`. For Google custom-event mediation, configure the class as **TGMAdsFramework.MediationCustomEvent**.

The UI uses TGM and TGM-Direct labels. Those labels map to the existing `adster_*` and `adster_direct_*` backend placement keys to preserve the current test inventory.

## Build

```sh
xcodebuild -project TGMAdsDemo.xcodeproj -scheme TGMAdsDemo \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/TGMAdsDemo-build CODE_SIGNING_ALLOWED=NO build
```

For manual testing, launch the app, open Settings → Ads, initialize the TGM SDK, select a network and format, then load a configured placement. Test ad serving with the intended backend settings and Google mediation custom-event name.
