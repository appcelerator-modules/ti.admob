/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2010-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAdmobModule.h"
#import "TiAdmobTypes.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <PersonalizedAdConsent/PersonalizedAdConsent.h>
#import <UserMessagingPlatform/UserMessagingPlatform.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
#import <AppTrackingTransparency/ATTrackingManager.h>
#import <FBAudienceNetwork/FBAdSettings.h>
#import <InMobiAdapter/InMobiAdapter.h>
#endif

@implementation TiAdmobModule

- (id)moduleGUID
{
  return @"0d005e93-9980-4739-9e41-fd1129c8ff32";
}

- (NSString *)moduleId
{
  return @"ti.admob";
}

#pragma mark Public API's

- (void)disableSDKCrashReporting:(id)unused
{
  [GADMobileAds.sharedInstance disableSDKCrashReporting];
}

- (void)disableAutomatedInAppPurchaseReporting:(id)unused
{
  DEPRECATED_REMOVED(@"Admob.disableAutomatedInAppPurchaseReporting", @"4.0.0", @"4.0.0 (removed by Google)");
}

- (void)requestConsentInfoUpdateWithParameters:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  //NSArray<NSString *> *publisherIdentifiers = [args objectForKey:@"publisherIdentifiers"];
  KrollCallback *callback = [args objectForKey:@"callback"];

  // Create a UMPRequestParameters object.
  UMPRequestParameters *parameters = [[UMPRequestParameters alloc] init];

  // Set tag for under age of consent. Here NO means users are not under age.
  parameters.tagForUnderAgeOfConsent = [TiUtils boolValue:@"tagForUnderAgeOfConsent" properties:args def:NO];;
  
  // Request an update to the consent information.
  [[UMPConsentInformation sharedInstance] requestConsentInfoUpdateWithParameters:parameters
                                                                        completionHandler:^(NSError *_Nullable error) {
                                                                          // The consent information has updated.
                                                                          if (error != nil) {
                                                                            // Handle the error.
                                                                            [callback call:@[ @{@"success" : @NO,
                                                                              @"error" : error.localizedDescription} ]
                                                                                thisObject:self];
                                                                            return;
                                                                          } else {
                                                                            // The consent information state was updated.
                                                                            // You are now ready to see if a form is available.
                                                                            UMPFormStatus formStatus =
                                                                              UMPConsentInformation.sharedInstance
                                                                                  .formStatus;
                                                                              NSNumber *status = @(formStatus);
                                                                              if (formStatus == UMPFormStatusAvailable) {
                                                                                NSLog(@"[INFO] Ti.AdMob: formStatus is available!");
                                                                              }
                                                                              if (callback != nil) {                                                                            
                                                                                [callback call:@[ @{
                                                                                  @"success" : @YES,
                                                                                  @"status" : status} ]
                                                                                  thisObject:self];
                                                                              }
                                                                          }                                                                          
                                                                        }];
}

- (void)loadForm:(id)args 
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  KrollCallback *callback = [args objectForKey:@"callback"];
  
  TiThreadPerformOnMainThread(
      ^{
        [UMPConsentForm loadWithCompletionHandler:^(UMPConsentForm *form,
                                                    NSError *loadError) {
          if (loadError) {
            // Handle the error.
            [callback call:@[ @{ @"loadError" : loadError.localizedDescription } ] thisObject:self];
          } else {
            // Present the form. You can also hold on to the reference to present
            // later.
            NSNumber *status = @(UMPConsentInformation.sharedInstance.consentStatus);
            if (UMPConsentInformation.sharedInstance.consentStatus ==
                UMPConsentStatusRequired) {
              [form
                  presentFromViewController:[[[TiApp app] controller] topPresentedController]
                          completionHandler:^(NSError *_Nullable dismissError) {
                            if (UMPConsentInformation.sharedInstance.consentStatus ==
                                UMPConsentStatusObtained) {
                              // App can start requesting ads. 
                              [callback call:@[ @{
                                @"status" : @(UMPConsentInformation.sharedInstance.consentStatus), // update here because it can change between the above assignment
                                @"dismissError" : NULL_IF_NIL(dismissError.localizedDescription)
                              } ]
                                  thisObject:self]; 
                              return;                            
                            }
                          }];
            } else {
              [callback call:@[ @{
                @"status" : status
              } ]
                  thisObject:self];
            }
          }
        }];
      },
      NO);
}

- (void)requestConsentInfoUpdateForPublisherIdentifiers:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  NSArray<NSString *> *publisherIdentifiers = [args objectForKey:@"publisherIdentifiers"];
  KrollCallback *callback = [args objectForKey:@"callback"];

  [[PACConsentInformation sharedInstance] requestConsentInfoUpdateForPublisherIdentifiers:publisherIdentifiers
                                                                        completionHandler:^(NSError *_Nullable error) {
                                                                          if (error != nil) {
                                                                            [callback call:@[ @{@"success" : @NO,
                                                                              @"error" : error.localizedDescription} ]
                                                                                thisObject:self];
                                                                            return;
                                                                          }

                                                                          [callback call:@[ @{@"success" : @YES} ] thisObject:self];
                                                                        }];
}

- (void)showConsentForm:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  if ([args objectForKey:@"privacyURL"] == nil) {
    [self throwException:NSLocalizedString(@"Missing \"privacyURL\" argument", nil) subreason:@"Cannot show consent form" location:CODELOCATION];
    return;
  }

  NSURL *privacyURL = [TiUtils toURL:[args objectForKey:@"privacyURL"] proxy:self];
  KrollCallback *callback = [args objectForKey:@"callback"];

  PACConsentForm *form = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
  form.shouldOfferPersonalizedAds = [TiUtils boolValue:@"shouldOfferPersonalizedAds" properties:args def:YES];
  form.shouldOfferNonPersonalizedAds = [TiUtils boolValue:@"shouldOfferNonPersonalizedAds" properties:args def:YES];
  form.shouldOfferAdFree = [TiUtils boolValue:@"shouldOfferAdFree" properties:args def:NO];

  TiThreadPerformOnMainThread(
      ^{
        [form loadWithCompletionHandler:^(NSError *_Nullable error) {
          if (error != nil) {
            [callback call:@[ @{ @"error" : error.localizedDescription } ] thisObject:self];
            return;
          }

          [form presentFromViewController:[[[TiApp app] controller] topPresentedController]
                        dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
                          [callback call:@[ @{
                            @"userPrefersAdFree" : @(userPrefersAdFree),
                            @"error" : NULL_IF_NIL(error.localizedDescription)
                          } ]
                              thisObject:self];
                        }];
        }];
      },
      NO);
}

- (NSNumber *)consentStatus
{
  return @([[PACConsentInformation sharedInstance] consentStatus]);
}

- (NSArray *)adProviders
{
  NSArray *adProviders = [[PACConsentInformation sharedInstance] adProviders];
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:adProviders.count];

  for (PACAdProvider *adProvider in adProviders) {
    [result addObject:@{ @"identifier" : adProvider.identifier,
      @"name" : adProvider.name,
      @"privacyPolicyURL" : adProvider.privacyPolicyURL }];
  }

  return result;
}

- (NSArray *)debugIdentifiers
{
  return [[PACConsentInformation sharedInstance] debugIdentifiers] ?: @[];
}

- (void)setDebugIdentifiers:(id)debugIdentifiers
{
  [[PACConsentInformation sharedInstance] setDebugIdentifiers:debugIdentifiers];
}

- (NSNumber *)debugGeography
{
  return @([[PACConsentInformation sharedInstance] debugGeography]);
}

- (void)resetConsent:(id)unused
{
  [[UMPConsentInformation sharedInstance] reset];
}

- (void)setTagForUnderAgeOfConsent:(id)tagForUnderAgeOfConsent
{
  ENSURE_TYPE(tagForUnderAgeOfConsent, NSNumber);
  [[PACConsentInformation sharedInstance] setTagForUnderAgeOfConsent:[TiUtils boolValue:tagForUnderAgeOfConsent]];
}

- (NSNumber *)isTaggedForUnderAgeOfConsent:(id)unused
{
  return @([[PACConsentInformation sharedInstance] isTaggedForUnderAgeOfConsent]);
}

- (NSNumber *)trackingAuthorizationStatus
{
  if (@available(iOS 14, *)) {
    return @([ATTrackingManager trackingAuthorizationStatus]);
  } else {
    NSLog(@"[WARN] Ti.AdMob: The property `trackingAuthorizationStatus` should be used on ios version 14 and above only");
  }
  return @3;
}

- (void)requestTrackingAuthorization:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  KrollCallback *callback = [args objectForKey:@"callback"];
  if (@available(iOS 14, *)) {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
      NSNumber *trackingStatus = @(status);
      if (callback != nil) {
        [callback call:@[ @{ @"status" : trackingStatus } ] thisObject:self];
      }
    }];
    return;
  } else {
    NSLog(@"[WARN] Ti.AdMob: The function `requestTrackingAuthorization` should be used on ios version 14 and above only");
  }
  if (callback != nil) {
    [callback call:@[ @{ @"status" : @3 } ] thisObject:self];
  }
}

- (void)setAdvertiserTrackingEnabled:(id)advertiserTrackingEnabled
{
  // this method is required by Facebook Audience Network for iOS >= 14
  if (@available(iOS 14, *)) {
    ENSURE_TYPE(advertiserTrackingEnabled, NSNumber);
    [FBAdSettings setAdvertiserTrackingEnabled:[TiUtils boolValue:advertiserTrackingEnabled]];
  } else {
    NSLog(@"[WARN] Ti.AdMob: The function `setAdvertiserTrackingEnabled` should be used on ios version 14 and above only");
  }
}

- (void)setInMobi_updateGDPRConsent:(id)updateGDPRConsent
{
  NSMutableDictionary *consentObject = [[NSMutableDictionary alloc] init];

  ENSURE_TYPE(updateGDPRConsent, NSNumber);
  if ([TiUtils boolValue:updateGDPRConsent]) {
    // this method is required by InMobi to set GDPR    
    [consentObject setObject:@"1" forKey:@"gdpr"];
    [consentObject setObject:@"true" forKey:IM_GDPR_CONSENT_AVAILABLE];
    NSLog(@"[INFO] Ti.AdMob: inMobi_updateGDPRConsent --> true");
  }  else {    
    [consentObject setObject:@"0" forKey:@"gdpr"];
    [consentObject setObject:@"true" forKey:IM_GDPR_CONSENT_AVAILABLE];
    NSLog(@"[INFO] Ti.AdMob: inMobi_updateGDPRConsent --> false");
  }

  [GADMInMobiConsent updateGDPRConsent:consentObject];
}

#pragma mark Constants

MAKE_SYSTEM_PROP(TRACKING_AUTHORIZATION_STATUS_NOT_DETERMINED, 0);
MAKE_SYSTEM_PROP(TRACKING_AUTHORIZATION_STATUS_RESTRICTED, 1);
MAKE_SYSTEM_PROP(TRACKING_AUTHORIZATION_STATUS_DENIED, 2);
MAKE_SYSTEM_PROP(TRACKING_AUTHORIZATION_STATUS_AUTHORIZED, 3);

MAKE_SYSTEM_PROP(CONSENT_FORM_STATUS_UNKNOWN, UMPFormStatusUnknown); // 0
MAKE_SYSTEM_PROP(CONSENT_FORM_STATUS_AVAILABLE, UMPFormStatusAvailable); // 1
MAKE_SYSTEM_PROP(CONSENT_FORM_STATUS_UNAVAILABLE, UMPFormStatusUnavailable); // 2
MAKE_SYSTEM_PROP(CONSENT_STATUS_UNKNOWN, UMPConsentStatusUnknown); // 0
MAKE_SYSTEM_PROP(CONSENT_STATUS_REQUIRED, UMPConsentStatusRequired); // 1
MAKE_SYSTEM_PROP(CONSENT_STATUS_NOT_REQUIRED, UMPConsentStatusNotRequired); // 2
MAKE_SYSTEM_PROP(CONSENT_STATUS_OBTAINED, UMPConsentStatusObtained); // 3

//MAKE_SYSTEM_PROP(CONSENT_STATUS_UNKNOWN, PACConsentStatusUnknown);
MAKE_SYSTEM_PROP(CONSENT_STATUS_NON_PERSONALIZED, PACConsentStatusNonPersonalized);
MAKE_SYSTEM_PROP(CONSENT_STATUS_PERSONALIZED, PACConsentStatusPersonalized);

MAKE_SYSTEM_PROP(DEBUG_GEOGRAPHY_DISABLED, PACDebugGeographyDisabled);
MAKE_SYSTEM_PROP(DEBUG_GEOGRAPHY_EEA, PACDebugGeographyEEA);
MAKE_SYSTEM_PROP(DEBUG_GEOGRAPHY_NOT_EEA, PACDebugGeographyNotEEA);

MAKE_SYSTEM_STR(SIMULATOR_ID, kGADSimulatorID);
MAKE_SYSTEM_PROP(GENDER_MALE, kGADGenderMale);
MAKE_SYSTEM_PROP(GENDER_FEMALE, kGADGenderFemale);
MAKE_SYSTEM_PROP(GENDER_UNKNOWN, kGADGenderUnknown);
MAKE_SYSTEM_PROP(AD_TYPE_BANNER, TiAdmobAdTypeBanner);
MAKE_SYSTEM_PROP(AD_TYPE_INTERSTITIAL, TiAdmobAdTypeInterstitial);
MAKE_SYSTEM_PROP(AD_TYPE_REWARDED_VIDEO, TiAdmobAdTypeRewardedVideo);

@end
