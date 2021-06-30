/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2010-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiModule.h"

@interface TiAdmobModule : TiModule

- (void)disableSDKCrashReporting:(id)unused;

- (void)disableAutomatedInAppPurchaseReporting:(id)unused; // REMOVED

- (void)requestConsentInfoUpdateWithParameters:(id)args;

- (void)loadForm:(id)args;

- (void)requestConsentInfoUpdateForPublisherIdentifiers:(id)args;

- (void)showConsentForm:(id)args;

- (NSNumber *)consentStatus;

- (NSArray *)adProviders;

- (NSArray *)debugIdentifiers;

- (void)setDebugIdentifiers:(id)debugIdentifiers;

- (NSNumber *)debugGeography;

- (void)resetConsent:(__unused id)unused;

- (void)setTagForUnderAgeOfConsent:(id)tagForUnderAgeOfConsent;

- (NSNumber *)isTaggedForUnderAgeOfConsent:(__unused id)unused;

- (NSNumber *)trackingAuthorizationStatus;

- (void)requestTrackingAuthorization:(id)args;

- (void)setAdvertiserTrackingEnabled:(id)advertiserTrackingEnabled;

- (void)setInMobi_updateGDPRConsent:(id)updateGDPRConsent;

@end
