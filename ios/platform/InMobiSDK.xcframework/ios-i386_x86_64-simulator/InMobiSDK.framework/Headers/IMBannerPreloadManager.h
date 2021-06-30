//
//  IMBannerPreloadManager.h
//  InMobiSDK
//
//  Copyright © 2020 InMobi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMBannerPreloadManager : NSObject

-(instancetype)init NS_UNAVAILABLE;
/**
 * Preloads a Banner ad and returns the following callback.
 *       Meta Information will be recieved from the callback banner:didReceiveWithMetaInfo
 *       Failure of Preload will be recieved from the callback banner:didFailToReceiveWithError
 */
-(void)preload;
/**
 * Loads a Preloaded Banner ad.
 */
-(void)load;

@end

NS_ASSUME_NONNULL_END
