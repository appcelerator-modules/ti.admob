/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2010-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAdmobView.h"
#import "TiAdmobTypes.h"
#import "TiApp.h"
#import "TiUtils.h"

@implementation TiAdmobView

#pragma mark - Ad Lifecycle

- (GADRequest *)request
{
  if (request == nil) {
    request = [[GADRequest request] retain];
  }

  return request;
}

- (GADInterstitial *)interstitial
{
  if (interstitial == nil) {
    id debugEnabled = [[self proxy] valueForKey:@"debugEnabled"];
    id adUnitId = [[self proxy] valueForKey:@"adUnitId"];

    if (debugEnabled != nil && [TiUtils boolValue:debugEnabled def:NO]) {
      adUnitId = [self exampleAdId];
    }

    interstitial = [[GADInterstitial alloc] initWithAdUnitID:[TiUtils stringValue:adUnitId]];
    [interstitial setDelegate:self];
    [interstitial setInAppPurchaseDelegate:self];
  }

  return interstitial;
}

- (GADBannerView *)bannerView
{
  if (bannerView == nil) {
    // Create the view with dynamic width and height specification.
    bannerView = [[GADBannerView alloc] initWithAdSize:[self generateHeight]];

    // Set the delegate to receive the internal events
    [bannerView setDelegate:self];
    [bannerView setInAppPurchaseDelegate:self];

    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    [bannerView setRootViewController:[[TiApp app] controller]];

    // Add the view to the view hirarchie
    [self addSubview:[self bannerView]];
  }

  return bannerView;
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
  id adType = [[self proxy] valueForKey:@"adType"];
  ENSURE_TYPE_OR_NIL(adType, NSNumber);

  if ([TiUtils intValue:adType def:TiAdmobAdTypeBanner] == TiAdmobAdTypeBanner) {
    [[self bannerView] setAdSize:GADAdSizeFromCGSize(bounds.size)];
  }

  [self initialize];
}

- (void)dealloc
{
  if (bannerView != nil) {
    [bannerView removeFromSuperview];
  }

  RELEASE_TO_NIL(request);
  RELEASE_TO_NIL(bannerView);
  RELEASE_TO_NIL(interstitial);

  [super dealloc];
}

#pragma mark - Public API's

- (void)initialize
{
  ENSURE_UI_THREAD_0_ARGS
  id adType = [[self proxy] valueForKey:@"adType"];
  ENSURE_TYPE_OR_NIL(adType, NSNumber);

  if ([TiUtils intValue:adType def:TiAdmobAdTypeBanner] == TiAdmobAdTypeBanner) {
    [[self bannerView] loadRequest:[self request]];
  } else if ([TiUtils intValue:adType] == TiAdmobAdTypeInterstitial) {
    [[self interstitial] loadRequest:[self request]];
  } else if ([TiUtils intValue:adType] == TiAdmobAdTypeRewardedVideo) {
    id debugEnabled = [self.proxy valueForKey:@"debugEnabled"];
    id adUnitId = [self.proxy valueForKey:@"adUnitId"];
    if (debugEnabled != nil && [TiUtils boolValue:debugEnabled def:NO]) {
      adUnitId = self.exampleAdId;
    }
    GADRewardBasedVideoAd.sharedInstance.delegate = self;
    [GADRewardBasedVideoAd.sharedInstance loadRequest:self.request withAdUnitID:adUnitId];
  }
}

- (void)setAdUnitId_:(id)value
{
  ENSURE_TYPE(value, NSString);

  id adType = [[self proxy] valueForKey:@"adType"];
  id debugEnabled = [[self proxy] valueForKey:@"debugEnabled"];

  if (adType != nil && [TiUtils boolValue:adType def:TiAdmobAdTypeBanner] == TiAdmobAdTypeInterstitial) {
    return;
  }

  if (debugEnabled != nil && [TiUtils boolValue:debugEnabled] == YES) {
    value = [self exampleAdId];
  }

  [[self bannerView] setAdUnitID:[TiUtils stringValue:value]];
}

- (void)setKeywords_:(id)value
{
  if ([value isKindOfClass:[NSString class]]) {
    [[self request] setKeywords:@[ [TiUtils stringValue:value] ]];
    NSLog(@"[WARN] Ti.AdMob: The property `keywords` with string values is deprecated. Please use an array of string values instead.");
  } else if ([value isKindOfClass:[NSArray class]]) {
    [[self request] setKeywords:value];
  } else {
    NSLog(@"[ERROR] Ti.AdMob: The property `keywords` must be either a String or an Array.");
  }
}

- (void)setDateOfBirth_:(id)value
{
  NSLog(@"[WARN] Ti.AdMmob: The \"birthday\" property has been deprecated by AdMob.");

  ENSURE_TYPE(value, NSDate);
  [[self request] setBirthday:value];
}

- (void)setTestDevices_:(id)value
{
  ENSURE_TYPE(value, NSArray);
  [[self request] setTestDevices:value];
}

- (void)setAdBackgroundColor_:(id)value
{
  id adType = [[self proxy] valueForKey:@"adType"];
  if (adType != nil && [TiUtils boolValue:adType def:TiAdmobAdTypeBanner] != TiAdmobAdTypeBanner) {
    return;
  }

  [[self bannerView] setBackgroundColor:[[TiUtils colorValue:value] _color]];
}

- (void)setTagForChildDirectedTreatment_:(id)value
{
  ENSURE_TYPE(value, NSNumber);
  [[self request] tagForChildDirectedTreatment:[TiUtils boolValue:value]];
}

- (void)setRequestAgent_:(id)value
{
  ENSURE_TYPE(value, NSString);
  [[self request] setRequestAgent:[TiUtils stringValue:value]];
}

- (void)setContentURL_:(id)value
{
  ENSURE_TYPE(value, NSString);

  if ([self validateUrl:value] == NO) {
    NSLog(@"[WARN] Ti.AdMob: The value of the property `contentURL` looks invalid.");
  }

  [[self request] setContentURL:[TiUtils stringValue:value]];
}

- (void)setExtras_:(id)args
{
  ENSURE_TYPE(args, NSDictionary);

  GADExtras *extras = [[GADExtras alloc] init];
  [extras setAdditionalParameters:args];
  [[self request] registerAdNetworkExtras:extras];

  RELEASE_TO_NIL(extras);
}

- (void)setGender_:(id)value
{
  NSLog(@"[WARN] Ti.AdMob: The \"gender\" property has been deprecated by AdMob.");

  if ([value isKindOfClass:[NSString class]]) {
    if ([value isEqualToString:@"male"]) {
      [[self request] setGender:kGADGenderMale];
    } else if ([value isEqualToString:@"female"]) {
      [[self request] setGender:kGADGenderFemale];
    } else if ([value isEqualToString:@"unknown"]) {
      [[self request] setGender:kGADGenderUnknown];
    }

    return;
  }

  ENSURE_TYPE(value, NSNumber);
  [[self request] setGender:[TiUtils intValue:value def:kGADGenderUnknown]];
}

- (void)setLocation_:(id)args
{
  ENSURE_TYPE(args, NSDictionary);

  [[self request] setLocationWithLatitude:[[args valueForKey:@"latitude"] floatValue]
                                longitude:[[args valueForKey:@"longitude"] floatValue]
                                 accuracy:[[args valueForKey:@"accuracy"] floatValue]];
}

- (void)showInterstitial
{
  if ([[self interstitial] isReady]) {
    [[self interstitial] presentFromRootViewController:[[[TiApp app] controller] topPresentedController]];
  }
}

#pragma mark - Deprecated / removed API's

- (void)setPublisherId_:(id)value
{
  NSLog(@"[ERROR] Ti.AdMob: The property `publisherId` has been removed in 2.0.0, use `adUnitId` instead.");
}

- (void)setTesting_:(id)value
{
  NSLog(@"[ERROR] Ti.AdMob: The property `testing` has been removed in 2.0.0, use `testDevices` instead.");
}

#pragma mark - Utilities

// http://stackoverflow.com/a/3819561/5537752
- (BOOL)validateUrl:(NSString *)candidate
{
  NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
  NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
  return [urlTest evaluateWithObject:candidate];
}

- (GADAdSize)generateHeight
{
  id height = [[self proxy] valueForKey:@"height"];

  if (height != nil) {
    return GADAdSizeFullWidthPortraitWithHeight([TiUtils floatValue:height]);
  }

  return kGADAdSizeFluid;
}

- (NSString *)exampleAdId
{
  return @"ca-app-pub-3940256099942544/1712485313";
}

+ (NSDictionary *)dictionaryFromBannerView:(GADBannerView *)bannerView
{
  return @{
    @"adUnitId" : bannerView.adUnitID
  };
}

+ (NSDictionary *)dictionaryFromInterstitial:(GADInterstitial *)interstitial
{
  return @{
    @"adUnitId" : interstitial.adUnitID,
    @"isReady" : NUMBOOL(interstitial.isReady)
  };
}

#pragma mark - Ad Delegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
  if (![[self proxy] _hasListeners:@"didReceiveAd"]) {
    return;
  }

  [self.proxy fireEvent:@"didReceiveAd" withObject:[TiAdmobView dictionaryFromBannerView:view]];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
  if (![[self proxy] _hasListeners:@"didFailToReceiveAd"]) {
    return;
  }

  [self.proxy fireEvent:@"didFailToReceiveAd" withObject:@{ @"adUnitId" : view.adUnitID,
    @"error" : error.localizedDescription }];
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
  if (![[self proxy] _hasListeners:@"willPresentScreen"]) {
    return;
  }

  [self.proxy fireEvent:@"willPresentScreen" withObject:[TiAdmobView dictionaryFromBannerView:adView]];
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
  if (![[self proxy] _hasListeners:@"willDismissScreen"]) {
    return;
  }

  [self.proxy fireEvent:@"willDismissScreen" withObject:[TiAdmobView dictionaryFromBannerView:adView]];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
  if (![[self proxy] _hasListeners:@"didDismissScreen"]) {
    return;
  }

  [self.proxy fireEvent:@"didDismissScreen" withObject:[TiAdmobView dictionaryFromBannerView:adView]];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
  if (![[self proxy] _hasListeners:@"willLeaveApplication"]) {
    return;
  }

  [self.proxy fireEvent:@"willLeaveApplication" withObject:[TiAdmobView dictionaryFromBannerView:adView]];
}

- (void)didReceiveInAppPurchase:(GADInAppPurchase *)purchase
{
  if (![[self proxy] _hasListeners:@"didReceiveInAppPurchase"]) {
    return;
  }

  DebugLog(@"[WARN] Ti.Admob: The GADInAppPurchase class has been deprecated by Google and will be removed in the future.");

  [self.proxy fireEvent:@"didReceiveInAppPurchase"
             withObject:@{
               @"productId" : purchase.productID,
               @"quantity" : [NSNumber numberWithInteger:purchase.quantity]
             }];
}

#pragma mark - Interstitial Delegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
  if (![[self proxy] _hasListeners:@"didReceiveAd"]) {
    return;
  }

  [self.proxy fireEvent:@"didReceiveAd" withObject:[TiAdmobView dictionaryFromInterstitial:ad]];
  [self showInterstitial];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
  if (![[self proxy] _hasListeners:@"didFailToReceiveAd"]) {
    return;
  }

  [self.proxy fireEvent:@"didFailToReceiveAd" withObject:@{ @"adUnitId" : ad.adUnitID,
    @"error" : error.localizedDescription }];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
  if (![[self proxy] _hasListeners:@"willPresentScreen"]) {
    return;
  }

  [self.proxy fireEvent:@"willPresentScreen" withObject:[TiAdmobView dictionaryFromInterstitial:ad]];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
  if (![[self proxy] _hasListeners:@"willDismissScreen"]) {
    return;
  }

  [self.proxy fireEvent:@"willDismissScreen" withObject:[TiAdmobView dictionaryFromInterstitial:ad]];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
  TiThreadPerformOnMainThread(^{
    [self removeFromSuperview];
  },
      NO);

  if (![[self proxy] _hasListeners:@"didDismissScreen"]) {
    return;
  }

  [self.proxy fireEvent:@"didDismissScreen" withObject:[TiAdmobView dictionaryFromInterstitial:ad]];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
  if (![[self proxy] _hasListeners:@"willLeaveApplication"]) {
    return;
  }

  [self.proxy fireEvent:@"willLeaveApplication" withObject:[TiAdmobView dictionaryFromInterstitial:ad]];
}

#pragma mark - Reward Based VideoAd Delegate

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
  [self.proxy fireEvent:@"adrewarded" withObject:@{ @"type" : reward.type, @"amount" : reward.amount }];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
  [self.proxy fireEvent:@"adloaded" withObject:nil];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
  [self.proxy fireEvent:@"adopened" withObject:nil];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
  [self.proxy fireEvent:@"videostarted" withObject:nil];
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
  [self.proxy fireEvent:@"videocompleted" withObject:nil];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
  [self.proxy fireEvent:@"adclosed" withObject:nil];
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
  [self.proxy fireEvent:@"adleftapplication" withObject:nil];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error
{
  NSString *message = [TiUtils messageFromError:error];
  [self.proxy fireEvent:@"adfailedtoload" withObject:@{ @"message" : message }];
}

@end
