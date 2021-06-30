/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2010-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAdmobView.h"
#import "TiViewProxy.h"

@interface TiAdmobViewProxy : TiViewProxy {
}

- (TiAdmobView *)admobView;

- (void)receive:(id)unused;

- (void)showRewardedVideo:(id)args;

- (void)showInterstitial:(id)args;

- (void)loadRewardedVideo:(id)adUnitId;

@end
