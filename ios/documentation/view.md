# Ti.Admob.View

## Description

A view for displaying ads delivered through Admob.

You should explicitly size the ad to one of the following predefined sizes (width x height). An appropriate
ad will be loaded from the server automatically:

* 320x50
* 300x250
* 468x60
* 728x90

Note: Starting in 2.0.0, you just need to specify a height and an appropriate ad is selected by the Admob SDK.
See the example.js for more infos.

## Properties

### string adUnitId

The ad Unit ID for Admob.

### string adBackgroundColor

The background color used for the ad.

### Array[String] testDevices

An array of test device ids. Adding the id of a test device to this array 
will allow that device to be served test ads. 

Use the module constant `SIMULATOR_ID` to use the simulator as a test device. 
If you do not know the id for your device, launch your app and request an ad 
like you normally would, then look in the console for the id. 

eg. <Google> To get test ads on this device, set the property `debugEnabled` to true

Add the id to the array passed to `testDevices`.

### Date dateOfBirth

**Deprecated as part of the AdMob SDK**

A date object representing the user's date of birth that should be used
for determining ad delivery. 

### string gender

**Deprecated as part of the AdMob SDK**

The user's gender for the purpose of determining ad delivery. This should be one of the constants `GENDER_MALE`, `GENDER_FEMALE` or `GENDER_UNKNOWN`.

### Array[String] keywords

An array of keywords used to determine ad delivery.

### object location

A dictionary with the location of the user for location-based ads:

* float latitude
* float longitude
* float accuracy

### object extras

Ad networks may have additional parameters they accept. To pass these parameters to them, create the ad network extras 
object for that network, fill in the parameters, and register it here. The ad network should have a header defining the 
interface for the `extras` object to create. All networks will have access to the basic settings you've set in this 
GADRequest (gender, birthday, testing mode, etc.). If you register an extras object that is the same class as one you have.

**Important**: You can pass `{ 'npa: '1' }` to disable personalized ads. This is required to conform to [GDPR](https://www.eugdpr.org/).

### String contentURL

URL string for a webpage whose content matches the app content. This webpage content is used for targeting purposes.

### String requestAgent

String that identifies the ad request's origin. Third party libraries that reference the Mobile. Ads SDK should set this property 
to denote the platform from which the ad request originated. For example, a third party ad network called "CoolAds network" that 
is mediating requests to the Mobile Ads SDK should set this property as "CoolAds".

### Boolean tagForChildDirectedTreatment

This property allows you to specify whether you would like your app to be treated as child-directed for purposes of the 
Children's Online Privacy Protection Act (COPPA), http:///business.ftc.gov/privacy-and-security/childrens-privacy.

If you call this method with YES, you are indicating that your app should be treated as child-directed for purposes of the 
Children's Online Privacy Protection Act (COPPA). If you call this method with NO, you are indicating that your app should 
not be treated as child-directed for purposes of the Children's Online Privacy Protection Act (COPPA). If you do not call this 
method, ad requests will include no indication of how you would like your app treated with respect to COPPA.

By setting this method, you certify that this notification is accurate and you are authorized to act on behalf of the owner of 
the app. You understand that abuse of this setting may result in termination of your Google account.

It may take some time for this designation to be fully implemented in applicable Google services. This designation will 
only apply to ad requests for which you have set this method.

### Boolean debugEnabled

Sets a testing value for `adUnitId` to test ads without an admob account.

## Events

### didReceiveAd

 Sent when an ad request loaded an ad. This is a good opportunity to add this
 view to the hierarchy if it has not yet been added. If the ad was received
 as a part of the server-side auto refreshing, you can examine the
 hasAutoRefreshed property of the view. Use the `adUnitId` property of the callback
 to identify the ad that was loaded.

### didFailToReceiveAd

 Sent when an ad request failed. Normally this is because no network
 connection was available or no ads were available (i.e. no fill).

### willPresentScreen

Sent just before presenting the user a full screen view, such as a browser,
in response to clicking on an ad. Use this opportunity to stop animations,
time sensitive interactions, etc.

Normally the user looks at the ad, dismisses it, and control returns to your
application by firing off `didDismissScreen`: However if the user hits the
Home button or clicks on an App Store link your application will end. In that case,
`willLeaveApplication` would fire.

### willDismissScreen

Sent just before dismissing a full screen view.

### didDismissScreen

Sent just after dismissing a full screen view. Use this opportunity to
restart anything you may have stopped as part of `willPresentScreen`.

### willLeaveApplication

Sent just before the application will background or terminate because the
user clicked on an ad that will launch another application (such as the App
Store).

### didReceiveInAppPurchase

⚠️ Deprecated by the Admob SDK 7.x and Ti.Admob 2.2.0

Called when the user clicks on the buy button of an in-app purchase ad. After the receiver handles the purchase, it must 
call the GADInAppPurchase object's reportPurchaseStatus: method.

### adrewarded

Fired when the reward based video ad has rewarded the user.

#### Parameters

| Name | Type | Description |
| --- | --- | --- |
| `reward` | `Object` | Reward information for rewarded video ads. |
| `reward.type` | `String` | Type of the reward. |
| `reward.amount` | `Number` | Amount rewarded to the user. |

### adloaded

Fired when a reward based video ad was received. From this point on you can open the video using `showRewardedVideo()`.

### adopened

Fired when the reward based video ad opened.

### videostarted

Fired when the reward based video ad started playing.

### videocompleted

Fired when the reward based video ad completed playing.

### adclosed

Fired when the reward based video ad closed.

### adleftapplication

Fires when the reward based video ad will leave the application.

### adfailedtoload

Fired when the reward based video ad failed to load.
