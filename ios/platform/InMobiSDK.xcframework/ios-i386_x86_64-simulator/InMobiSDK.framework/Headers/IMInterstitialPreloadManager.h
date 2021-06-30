//
//  IMInterstitialPreloadManager.h
//  InMobiSDK
//
//  Copyright © 2020 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMInterstitialPreloadManager : NSObject

-(instancetype)init NS_UNAVAILABLE;
/**
 * Preload a Interstitial ad and returns the following callbacks.
 *       Meta Information will be recieved from the callback interstitial:didReceiveWithMetaInfo
 *       Failure of Preload will be recieved from the callback interstitial:didFailToReceiveWithError
 */
-(void)preload;
/**
 * Loads a Preloaded Interstitial ad.
 */
-(void)load;

@end

NS_ASSUME_NONNULL_END
