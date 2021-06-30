/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2010-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAdmobViewProxy.h"
#import "TiApp.h"
#import "TiUtils.h"

@implementation TiAdmobViewProxy

- (TiAdmobView *)admobView
{
  return (TiAdmobView *)[self view];
}

- (void)receive:(id)unused
{
  [[self admobView] initialize];
}

- (void)showRewardedVideo:(id)args
{
  [[self admobView] showRewardedVideo];
}

- (void)showInterstitial:(id)args
{
  [[self admobView] showInterstitial];
}

- (void)loadRewardedVideo:(id)adUnitId
{
  [[self admobView] loadRewardedVideoWithAdUnitID:adUnitId];
}

@end
