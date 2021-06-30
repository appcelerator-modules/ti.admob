//
//  IMAdMetaInfo.h
//  InMobiSDK
//
//  Copyright © 2020 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMAdMetaInfo : NSObject

/**
 * CreativeID of the ad.
 */
@property (nonatomic, strong, readonly) NSString* creativeID;
/**
 * Bid info Dictionary of the ad.
 */
@property (nonatomic, strong, readonly) NSDictionary* bidInfo;
/**
 * Bidvalue of the ad.
 */
- (double)getBid;

@end

NS_ASSUME_NONNULL_END
