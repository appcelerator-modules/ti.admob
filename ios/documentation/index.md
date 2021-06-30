# Ti.Admob Module

## Description

Shows ads from Admob.

## Getting Started

View the [Using Titanium Modules](http://docs.appcelerator.com/platform/latest/#!/guide/Using_Titanium_Modules) document for instructions on getting
started with using this module in your application.

## Requirements

The Google AdMob Ads SDK has the following requirements:

* An AdMob site ID.
* Xcode 6.4 or later.
* Runtime of iOS 7.1 or later.
* If using module 2.5.0+, add following key in tiapp.xml, inside ios plist  section.   
    <key>GADIsAdManagerApp</key>
    <true/>
## Accessing the Ti.Admob Module

To access this module from JavaScript, you would do the following:

```js
var Admob = require('ti.admob');
```

## Doubleclick for Publishers Developer Docs
<https://developers.google.com/mobile-ads-sdk/>

## Methods

### `Ti.Admob.createView(args)`

Creates and returns a [Ti.Admob.View][] object which displays ads. See the [AdView docs](./view.md) for details.

#### Arguments

parameters[object]: a dictionary object of properties defined in [Ti.Admob.View][].

#### Example:

```js
  var ad = Admob.createView({
    bottom: 0,
    width: 320, // Will calculate the width internally to fit its container if not specified
    height: 50,
    debugEnabled: true, // If enabled, a dummy value for `adUnitId` will be used to test
    adType: Admob.AD_TYPE_BANNER, // One of `AD_TYPE_BANNER` (default) or `AD_TYPE_INTERSTITIAL`
    adUnitId: '<<YOUR ADD UNIT ID HERE>>', // You can get your own at http: //www.admob.com/
    adBackgroundColor: 'black',
    testDevices: [Admob.SIMULATOR_ID], // You can get your device's id by looking in the console log
    contentURL: 'https://admob.com', // URL string for a webpage whose content matches the app content.
    requestAgent: 'Titanium Mobile App', // String that identifies the ad request's origin.
    extras: { 'npa': "1", 'version': 1.0, 'name': 'My App' }, // Object of additional infos. NOTE: npa=1 disables personalized ads (!)
    tagForChildDirectedTreatment: false, // http:///business.ftc.gov/privacy-and-security/childrens-privacy for more infos
    keywords: ['keyword1', 'keyword2']
  });
```

### `disableSDKCrashReporting()`

Disables automated SDK crash reporting. If not called, the SDK records the original exception
handler if available and registers a new exception handler. The new exception handler only
reports SDK related exceptions and calls the recorded original exception handler.

### `disableAutomatedInAppPurchaseReporting()`

Disables automated in app purchase (IAP) reporting. Must be called before any IAP transaction is
initiated. IAP reporting is used to track IAP ad conversions. Do not disable reporting if you use IAP ads.

### `requestConsentInfoUpdateForPublisherIdentifiers(args)`

Requests consent information update for the provided publisher identifiers. All publisher
identifiers used in the application should be specified in this call. Consent status is reset to
unknown when the ad provider list changes.

- `publisherIdentifiers` (Array<String>)
- `callback` (Function)

### `showConsentForm(args)`

Shows a consent modal form. Arguments:

- `shouldOfferPersonalizedAds` (Boolean)
Indicates whether the consent form should show a personalized ad option. Defaults to `true`.
- `shouldOfferNonPersonalizedAds` (Boolean)
Indicates whether the consent form should show a non-personalized ad option. Defaults to `true`.
- `shouldOfferAdFree` (Boolean)
Indicates whether the consent form should show an ad-free app option. Defaults to `false`.
- `callback` (Function)
Callback to be triggered once the form completes.

### `resetConsent()`

Resets consent information to default state and clears ad providers.

### `setTagForUnderAgeOfConsent(true|false)`

Sets whether the user is tagged for under age of consent.

### `isTaggedForUnderAgeOfConsent()` (Boolean)

Indicates whether the user is tagged for under age of consent.

## Properties

### `consentStatus` (`CONSENT_STATUS_UNKNOWN`, `CONSENT_STATUS_NON_PERSONALIZED` or `CONSENT_STATUS_PERSONALIZED`)

### `adProviders` (Array)

Array of ad providers.

### `debugIdentifiers` (Array)

Array of advertising identifier UUID strings. Debug features are enabled for devices with these
identifiers. Debug features are always enabled for simulators.

### `debugGeography` (`DEBUG_GEOGRAPHY_DISABLED`, `DEBUG_GEOGRAPHY_EEA` or `DEBUG_GEOGRAPHY_NOT_EEA`)

Debug geography. Used for debug devices only.

## Supported Ads

Other than the default banner ad, ti.admob has support for the following ad types and features:

### Interstitials

To receive an interstitional ad, you need to call `ad.receive()` instead of adding it to the viewe hierarchy.
It fires the `didReceiveAd` event if the  ad was successfully received, the `didFailToReceiveAd` event otherwise. Please check
the example for a detailed example of different banner types.

### Rewarded Video

Since version 2.4.2 you can use Admob Rewarded Video ads. This is similar to interstitials with the addition of getting a reward after watching an ad video.

You create a rewarded video ad by specifying `Admob.AD_TYPE_REWARDED_VIDEO` as the `adType`. The first video will be automatically pre-loaded after creating the view and calling `receive`. To know when a video is completely loaded you can use the `adloaded` event. To show a rewarded video add call the `showRewardedVideo` method. Loading another video can be started with the `loadRewardedVideo(adUnitId)` method on the same instance.

```js
var rewardedVideo = Admob.createView({
  adType: Admob.AD_TYPE_REWARDED_VIDEO,
  adUnitId: '<<YOUR ADD UNIT ID HERE>>', // You can get your own at http: //www.admob.com/
});
rewardedVideo.receive()
rewardedVideo.addEventListener('adloaded', function(e) {
  rewardedVideo.showRewardedVideo();
});
rewardedVideo.addEventListener('adrewarded', function (reward) {
  Ti.API.debug(`Received reward! type: ${reward.type}, amount: ${reward.amount}`);
  // pre load next rewarded video
  // rewardedVideo.loadRewardedVideo('add-unit-id');
});
rewardedVideo.addEventListener('adclosed', function(e) {
  Ti.API.debug('No gold for you!');
});
```

Please see the examples for a complete implementation.

### iAd

⚠️ Removed by the Admob SDK 7.x and Ti.Admob 2.2.0

Starting in 2.1.0 you can use the included iAd adapter to turn on the iAd mediation in your Admob account.

### Support the Facebook Audience Network adapter

Starting in 2.4.0 you can use the included Facebook Audience Network adapter to turn on the mediation in your Admob account. Here you do not have to do anything :) You only need to configure mediation in your AdMob and Facebbok accounts by following the official guide: https://developers.google.com/admob/ios/mediation/facebook

### How to update PersonalizedAdConsent

Starting in 2.4.4 iOS ti.admob use PersonalizedAdConsent framework Version 1.0.5 (removed all references to the deprecated **UIWebView** by using new **WKWebView**).
The new realeases are available on https://github.com/googleads/googleads-consent-sdk-ios/releases.
To add a new version of PersonalizedAdConsent you need to:
1) Download the release zip file (e.g. https://github.com/googleads/googleads-consent-sdk-ios/archive/v1.0.5.zip)
2) Open the ti.admob project https://github.com/astrovic/ti.admob/tree/master/ios/admob.xcodeproj with Xcode
3) Unpack the googleads-consent-sdk-ios-X-X-X.zip file and drag the PersonalizedAdConsent.xcodeproj file to Xcode, inside "admob"
4) In the Build Phases tab, go to Link Binary With Libraries, and click on the + button.
5) Select PersonalizedAdConsent.framework and click on the Add button.
6) On Link Binary With Libraries, right click PersonalizedAdConsent.framework and go to Show in finder.
7) Copy the entire PersonalizedAdConsent.framework folder into the ti.admob project in https://github.com/astrovic/ti.admob/tree/master/ios/platform (replacing the existing one)
8) Now you can build the module :)

<img src="http://astrovicapps.com/git_source/tiadmob/PersonalizedAdConsent.png" width="300px" style="float:left; margin-right:1em;">

## Constants

### Number `CONSENT_STATUS_UNKNOWN`

Returned by `consentStatus` if the consent status is unknown.

### Number `CONSENT_STATUS_NON_PERSONALIZED`

Returned by `consentStatus` if the consent status is not personalized.

### Number `CONSENT_STATUS_PERSONALIZED`

Returned by `consentStatus` if the consent status is personalized.

### Number `DEBUG_GEOGRAPHY_DISABLED`

Returned by `debugGeography` if geography debugging is disabled.

### Number `DEBUG_GEOGRAPHY_EEA`

Returned by `debugGeography` if geography appears as in EEA for debug devices.

### Number `DEBUG_GEOGRAPHY_NOT_EEA`

Returned by `debugGeography` if geography appears as not in EEA for debug devices.

### String `SIMULATOR_ID`

A constant to be passed in an array to the `testDevices` property to get test ads on the simulator.

### Number `GENDER_MALE`

A constant to be passed to the `gender` property to specify a gender if used. **Deprecated by the AdMob SDK**.

### Number `GENDER_FEMALE`

A constant to be passed to the `gender` property to specify a gender if used. **Deprecated by the AdMob SDK**.

### Number `GENDER_UNKNOWN`

A constant to be passed to the `gender` property to specify a gender if used. **Deprecated by the AdMob SDK**.

## Usage

See example.

## Author

Jeff Haynie, Stephen Tramer, Jasper Kennis, Jon Alter, Hans Knoechel

## Module History

View the [change log](changelog.html) for this module.

## Feedback and Support

Please direct all questions, feedback, and concerns to [info@appcelerator.com](mailto:info@appcelerator.com?subject=iOS%20Admob%20Module).

## License

Copyright(c) 2010-Present by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[Ti.Admob.View]: view.html