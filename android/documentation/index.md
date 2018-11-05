# Admob Module

## Description

Allows for the display of AdMob in Titanium Android applications.

Please note that if your androidManifest has screen support set to: android:anyDensity="false", any banner ads will 
display too small on high density devices.
It is not clear at this point if this is a bug with AdMob or Titanium.
In any event, you will either need to NOT set your screen support -- or set android:anyDensity="true" and adjust your app layout accordingly

## Getting Started

View the [Using Titanium Modules](http://docs.appcelerator.com/platform/latest/#!/guide/Using_Titanium_Modules) document 
for instructions on getting started with using this module in your application.

## Requirements

- [x] Titanium SDK 7.0.0+
- [x] [Ti.PlayServices](https://github.com/appcelerator-modules/ti.playservices) module

## Accessing the Admob Module

To access this module from JavaScript, you would do the following (recommended):

```js
var Admob = require('ti.admob');
```

The "Admob" variable is now a reference to the Module object.

## Doubleclick for Publishers Developer Docs

<https://developers.google.com/mobile-ads-sdk/>

## Functions

### Number isGooglePlayServicesAvailable()

Returns a number value indicating the availability of Google Play Services which are for push notifications.

Possible values include `SUCCESS`, `SERVICE_MISSING`, `SERVICE_VERSION_UPDATE_REQUIRED`, `SERVICE_DISABLED`,
and `SERVICE_INVALID`.

### `createAdMobView(args)`

Returns a view with an ad initialized by default.

#### Arguments

parameters[object]: a dictionary object of properties.

#### Example:

	var adMobView = Admob.createView({
	    adUnitId: 'ENTER_YOUR_AD_UNIT_ID_HERE',
	    testing:false, // default is false
	    top: 0, // optional
	    left: 0, // optional
	    right: 0, // optional
	    bottom: 0 // optional
	    adBackgroundColor: '#FF8800', // optional
	    backgroundColorTop: '#738000', // optional - Gradient background color at top
	    borderColor: '#000000', // optional - Border color
	    textColor: '#000000', // optional - Text color
	    urlColor: '#00FF00', // optional - URL color
	    linkColor: '#0000FF' // optional -  Link text color
	});

### `Admob.AD_RECEIVED`

returns the constant for AD_RECEIVED -- for use in an event listener

#### Example:

	adMobView.addEventListener(Admob.AD_RECEIVED, function () {
	    alert('ad was just received');
	});

### `Admob.AD_NOT_RECEIVED`

returns whenever the ad was not successfully loaded. The callback contains the
error code in its parameter under the key `errorCode`
Error codes for Android can be checked here:
https://developers.google.com/android/reference/com/google/android/gms/ads/AdRequest#ERROR_CODE_INTERNAL_ERROR

#### Example:

	adMobView.addEventListener(Admob.AD_NOT_RECEIVED, function (e) {
	    alert('ad was not received. error code is ' + e.errorCode);
	});

### `Admob.AD_OPENED`

returns the constant for AD_OPENED -- for use in an event listener

#### Example:

	adMobView.addEventListener(Admob.AD_OPENED, function () {
	    alert('ad was just opened');
	});

### `Admob.AD_CLOSED`

#### Example:

	adMobView.addEventListener(Admob.AD_CLOSED, function () {
	    alert('ad was just closed');
	});

### `Admob.AD_LEFT_APPLICATION`

#### Example:

	adMobView.addEventListener(Admob.AD_LEFT_APPLICATION, function () {
	    alert('user just left the application through the ad');
	});

### `AdMobView.requestAd(args)`

Calls for a new ad if needed. Pass optional `args` to configure extras.

#### Example:

```js
adMobView.requestAd({
    extras: {
        'npa': '1' // Disable personalized ads (GDPR)
    }
});
```

### `AdMobView.requestTestAd()`

Calls for a test ad if needed. This works independently from the testing flag above.

#### Example:

```js
adMobView.requestTestAd();
```

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

### `debugGeography` (`DEBUG_GEOGRAPHY_DISABLED`, `DEBUG_GEOGRAPHY_EEA` or `DEBUG_GEOGRAPHY_NOT_EEA`)

Debug geography. Used for debug devices only.

### getAndroidAdId(callback)

Gets the user Android Advertising ID. Since this works in a background thread in native
Android a callback is called when the value is fetched. The callback parameter is a key/value
pair with key `androidAdId` and a String value with the id.

#### Example:

	Admob.getAndroidAdId(function (data) {
		Ti.API.info('AAID is ' + data.aaID);
	});

### isLimitAdTrackingEnabled(callback)

Checks whether the user has opted out from ad tracking in the device's settings. Since
this works in a background thread in native Android a callback is called when the value
is fetched. The callback parameter is a key/value pair with key `isLimitAdTrackingEnabled`
and a boolean value for the user's setting.

#### Example:

	Admob.isLimitAdTrackingEnabled(function (data) {
		Ti.API.info('Ad tracking is limited: ' + data.isLimitAdTrackingEnabled);
	});

### Support the Facebook Audience Network adapter

Starting in 4.3.0 you can use the included Facebook Audience Network adapter to turn on the mediation in your AdMob account.
Here you do not have to do anything 😙. You only need to configure mediation in your AdMob and Facebook accounts by 
following the [official guide](https://developers.google.com/admob/android/mediation/facebook).

## Constants

### Number `SUCCESS`
Returned by `isGooglePlayServicesAvailable()` if the connection to Google Play Services was successful.

### Number `SERVICE_MISSING`
Returned by `isGooglePlayServicesAvailable()` if Google Play Services is missing on this device.

### Number `SERVICE_VERSION_UPDATE_REQUIRED`
Returned by `isGooglePlayServicesAvailable()` if the installed version of Google Play Services is out of date.

### Number `SERVICE_DISABLED`
Returned by `isGooglePlayServicesAvailable()` if the installed version of Google Play Services has been disabled on this device.

### Number `SERVICE_INVALID`
Returned by `isGooglePlayServicesAvailable()` if the version of the Google Play Services installed on this device is not authentic.

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

## Module History

View the [change log](changelog.html) for this module.

## Feedback and Support

Please direct all questions, feedback, and concerns to [info@appcelerator.com](mailto:info@appcelerator.com?subject=Android%20Admob%20Module).

### Interstitial ads

Starting from 4.4.0 this module now supports Interstitial ads for Android.

Interstitial ads are full screen ads that are usually shown between natural steps of an application's interface flow.
For instance doing different tasks in your application or between reading different articles.

For best user experience Interstitial ads should be loaded prior showing the to the user. Interstitial ad instances can
be used for showing one ad per loading, but they can be used multiple times. A good way of reusing an Interstitial ad is
to show an ad, load a new after it has been closed one, and await for the proper time to show the recently loaded. 

#### Properties

##### adUnitId

Id for this add. This property can be set in the creation dictionary or after creating the Interstitial ad instance.

#### Methods

##### setAdUnitId(String id)

Sets the adUnitId property.

##### getAdUnitId()

Gets the adUnitId property.

##### load()

Loads an ad for this Interstitial ad instance.

##### show()

Shows an Interstitial ad if there is one successfully loaded. 

#### Example:

	// Create an Interstitial ad with a testing AdUnitId
	var interstitialAd = Admob.createInterstitialAd({ adUnitId:"ca-app-pub-3940256099942544/1033173712" });

	// Add all listeners for the add.
	interstitialAd.addEventListener(Admob.AD_CLOSED, function () {
	    Ti.API.info('Interstitial Ad closed!');
	});
	interstitialAd.addEventListener(Admob.AD_RECEIVED, function () {
	    // When a new Interstitial ad is loaded, show it.
	    Ti.API.info('Interstitial Ad loaded!');
	    interstitialAd.show();
	});
	interstitialAd.addEventListener(Admob.AD_CLICKED, function () {
	    Ti.API.info('Interstitial Ad clicked!');
	});
	interstitialAd.addEventListener(Admob.AD_NOT_RECEIVED, function (e) {
	    Ti.API.info('Interstitial Ad not received! Error code = ' + e.errorCode);
	});
	interstitialAd.addEventListener(Admob.AD_OPENED, function () {
	    Ti.API.info('Interstitial Ad opened!');
	});
	interstitialAd.addEventListener(Admob.AD_LEFT_APPLICATION, function () {
	    Ti.API.info('Interstitial Ad left application!');
	});
	interstitialAd.load();

## Author

Brian Kurzius | bkurzius@gmail.com
Axway Appcelerator

## License
Copyright 2011, Brian Kurzius, Studio Classics.
Copyright 2014 - Present, Appcelerator.

Please see the LICENSE file included in the distribution for further details.
