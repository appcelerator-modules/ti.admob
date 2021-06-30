//
//  IMUnifiedIdDelegate.h
//  InMobiSDK
//  Copyright © 2021 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMUnifiedIdDelegate <NSObject>

/**
 * Publishers should implement this protocol to fetch unified ids
 * Publisher should send this delegate in IMUnifiedIdService fetchUnifiedIds:(id<IMUnifiedIdDelegate>)delegate
 *
 * @param response contains unified ids procured from InMobi supported vendors
 * @param error contains reason on why unified ids were not fetched.
 */

- (void)onFetchCompleted:(nullable NSDictionary *)response error:(nullable NSError *)error;

@end
