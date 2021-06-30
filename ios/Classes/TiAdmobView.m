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

- (GADBannerView *)bannerView
{
  if (bannerView == nil) {
    // Create the view with dynamic width and height specification.
    bannerView = [[GADBannerView alloc] initWithAdSize:[self generateAdSize]];

    // Set the delegate to receive the internal events
    [bannerView setDelegate:self];

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

  if (interstitialAd) {
    interstitialAd.fullScreenContentDelegate = nil;
  }
  
  if (rewardedAd) {
    rewardedAd.fullScreenContentDelegate = nil;
  }

  RELEASE_TO_NIL(bannerView);
  RELEASE_TO_NIL(interstitialAd);
  RELEASE_TO_NIL(rewardedAd);

  [super dealloc];
}

#pragma mark - Public API's

- (void)initialize
{
  ENSURE_UI_THREAD_0_ARGS
  id adType = [[self proxy] valueForKey:@"adType"];
  ENSURE_TYPE_OR_NIL(adType, NSNumber);
  
  id debugEnabled = [self.proxy valueForKey:@"debugEnabled"];
  adUnitId = [self.proxy valueForKey:@"adUnitId"];
  if (debugEnabled != nil && [TiUtils boolValue:debugEnabled def:NO]) {
    adUnitId = self.exampleAdId;
  }

  if ([TiUtils intValue:adType def:TiAdmobAdTypeBanner] == TiAdmobAdTypeBanner) {
    [self loadBanner];
  } else if ([TiUtils intValue:adType def:TiAdmobAdTypeBanner] == TiAdmobAdTypeInterstitial) {
    [self loadInterstitial];
  } else if ([TiUtils intValue:adType def:TiAdmobAdTypeBanner] == TiAdmobAdTypeRewardedVideo) {
    [self loadRewardedVideoWithAdUnitID:adUnitId];
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
    [[GADRequest request] setKeywords:@[ [TiUtils stringValue:value] ]];
    NSLog(@"[WARN] Ti.AdMob: The property `keywords` with string values is deprecated. Please use an array of string values instead.");
  } else if ([value isKindOfClass:[NSArray class]]) {
    [[GADRequest request] setKeywords:value];
  } else {
    NSLog(@"[ERROR] Ti.AdMob: The property `keywords` must be either a String or an Array.");
  }
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
  [GADMobileAds.sharedInstance.requestConfiguration tagForChildDirectedTreatment:[TiUtils boolValue:value]];
}

- (void)setRequestAgent_:(id)value
{
  ENSURE_TYPE(value, NSString);
  [[GADRequest request] setRequestAgent:[TiUtils stringValue:value]];
}

- (void)setContentURL_:(id)value
{
  ENSURE_TYPE(value, NSString);

  if ([self validateUrl:value] == NO) {
    NSLog(@"[WARN] Ti.AdMob: The value of the property `contentURL` looks invalid.");
  }

  [[GADRequest request] setContentURL:[TiUtils stringValue:value]];
}

- (void)setExtras_:(id)args
{
  ENSURE_TYPE(args, NSDictionary);

  GADExtras *extras = [[GADExtras alloc] init];
  [extras setAdditionalParameters:args];
  [[GADRequest request] registerAdNetworkExtras:extras];

  RELEASE_TO_NIL(extras);
}

- (void)setLocation_:(id)args
{
  ENSURE_TYPE(args, NSDictionary);

  [[GADRequest request] setLocationWithLatitude:[[args valueForKey:@"latitude"] floatValue]
                                longitude:[[args valueForKey:@"longitude"] floatValue]
                                 accuracy:[[args valueForKey:@"accuracy"] floatValue]];
}

- (void)loadBanner
{
  [[self bannerView] loadRequest:[GADRequest request]];
}

- (void)loadRewardedVideoWithAdUnitID:(NSString *)adUnitID
{
  // Pass directly here because it can be overwritten by
  // calling "loadRewardedVideo(adUnitId)" again
  [GADRewardedAd loadWithAdUnitID:adUnitID request:[GADRequest request] completionHandler:^(GADRewardedAd * _Nullable _rewardedAd, NSError * _Nullable error) {
    if (error) {
      [self.proxy fireEvent:@"adfailedtoload" withObject:@{ @"message": error.localizedDescription }];
      return;
    }
    
    rewardedAd = [_rewardedAd retain];
    rewardedAd.fullScreenContentDelegate = self;

    [[self proxy] fireEvent:@"adloaded"];
  }];
}

- (void)loadInterstitial
{
  [GADInterstitialAd loadWithAdUnitID:adUnitId
                               request:[GADRequest request]
                     completionHandler:^(GADInterstitialAd *ad, NSError *error) {
     if (error) {
       [self.proxy fireEvent:@"adfailedtoload" withObject:@{ @"message": error.localizedDescription }];
       return;
     }

     interstitialAd = [ad retain];
     interstitialAd.fullScreenContentDelegate = self;

    [[self proxy] fireEvent:@"adloaded"];
   }];
}

- (void)showInterstitial
{
  NSError *error;
  BOOL canPresent = interstitialAd && [interstitialAd canPresentFromRootViewController:[[[TiApp app] controller] topPresentedController] error:&error];

  if (canPresent) {
    [interstitialAd presentFromRootViewController:[[[TiApp app] controller] topPresentedController]];
  } else {
    NSLog(@"[WARN] Cannot show interstitial: %@", error.localizedDescription);
  }
}

- (void)showRewardedVideo
{
  NSError *error;
  BOOL canPresent = rewardedAd && [rewardedAd canPresentFromRootViewController:[[[TiApp app] controller] topPresentedController] error:&error];

  if (canPresent) {
    [rewardedAd presentFromRootViewController:[[[TiApp app] controller] topPresentedController] userDidEarnRewardHandler:^{
      NSDictionary *event = @{
        @"amount": rewardedAd.adReward.amount,
        @"type": rewardedAd.adReward.type
      };

      [[self proxy] fireEvent:@"adrewarded" withObject:event];
    }];
  } else {
    NSLog(@"[WARN] Cannot show rewarded video: %@", error.localizedDescription);
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

- (void)setGender_:(id)value
{
  DEPRECATED_REMOVED(@"Admob.gender", @"3.0.0", @"4.0.0 (removed by Google)")
}

- (void)setDateOfBirth_:(id)value
{
  DEPRECATED_REMOVED(@"Admob.dateOfBirth", @"3.0.0", @"4.0.0 (removed by Google)")
}

- (void)setTestDevices_:(id)value
{
  DEPRECATED_REMOVED(@"Admob.testDevices", @"4.0.0", @"4.0.0 (removed by Google)")
}

#pragma mark - Utilities

// http://stackoverflow.com/a/3819561/5537752
- (BOOL)validateUrl:(NSString *)candidate
{
  NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
  NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
  return [urlTest evaluateWithObject:candidate];
}

- (GADAdSize)generateAdSize
{
  id height = [[self proxy] valueForKey:@"height"];
  CGRect frame = self.frame;
  // Here safe area is taken into account, hence the view frame is used after the
  // view has been laid out.
  if (@available(iOS 11.0, *)) {
    frame = UIEdgeInsetsInsetRect(self.frame, self.safeAreaInsets);
  }
  CGFloat viewWidth = frame.size.width;

  // We still support this, but per Google docs, we should primariy use
  // the adaptive banner width (without a fixed height)
  if (height != nil) {
    return GADAdSizeFullWidthPortraitWithHeight([TiUtils floatValue:height]);
  }

  return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
}

- (NSString *)exampleAdId
{
  return @"ca-app-pub-3940256099942544/1712485313";
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView
{
  [self.proxy fireEvent:@"didReceiveAd" withObject:@{ @"adUnitId": adUnitId }];
}

- (void)bannerView:(nonnull GADBannerView *)bannerView
    didFailToReceiveAdWithError:(nonnull NSError *)error
{
  [self.proxy fireEvent:@"didFailToReceiveAd" withObject:@{ @"adUnitId" : adUnitId, @"error" : error.localizedDescription }];
}

- (void)bannerViewDidRecordImpression:(nonnull GADBannerView *)bannerView
{
  [self.proxy fireEvent:@"didRecordImpression" withObject:adUnitId];
}

// These three are only called if the banner ad triggers an in-app fullscreen view
// (without leaving the app)

- (void)bannerViewWillPresentScreen:(nonnull GADBannerView *)bannerView
{
  [self.proxy fireEvent:@"willPresentScreen" withObject:@{ @"adUnitId": adUnitId }];
}

- (void)bannerViewWillDismissScreen:(nonnull GADBannerView *)bannerView
{
  [self.proxy fireEvent:@"willDismissScreen" withObject:@{ @"adUnitId": adUnitId }];
}

- (void)bannerViewDidDismissScreen:(nonnull GADBannerView *)bannerView
{
  [self.proxy fireEvent:@"didDismissScreen" withObject:@{ @"adUnitId": adUnitId }];
}

#pragma mark - GADFullScreenContentDelegate

// NOTE: I tried to map them as best as possible, but for example "adDidRecordImpression" is new
// and "willPresentScreen" is not available anymore

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad
{
  NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{ @"adUnitId": adUnitId }];

  if ([ad isKindOfClass:[GADRewardedAd class]]) {
    GADAdReward *adReward = [(GADRewardedAd *)ad adReward];
    event[@"amount"] = adReward.amount;
    event[@"type"] = adReward.type;
  }

  [self.proxy fireEvent:@"didRecordImpression" withObject:event];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
  [self.proxy fireEvent:@"didFailToReceiveAd" withObject:@{ @"adUnitId" : adUnitId, @"error" : error.localizedDescription }];
}

- (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
  [self.proxy fireEvent:@"didPresentScreen" withObject:@{ @"adUnitId": adUnitId }];
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
  [self.proxy fireEvent:@"willDismissScreen" withObject:@{ @"adUnitId": adUnitId }];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
  [self.proxy fireEvent:@"didDismissScreen" withObject:@{ @"adUnitId": adUnitId }];
}

@end
