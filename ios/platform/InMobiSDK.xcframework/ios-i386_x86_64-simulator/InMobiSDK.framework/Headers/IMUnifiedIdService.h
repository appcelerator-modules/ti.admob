//
//  IMUnifiedIdService.h
//  InMobiSDK
//  Copyright © 2021 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMUserDataModel.h"
#import "IMUnifiedIdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Class to integrate UnifiedIdService
 */

@interface IMUnifiedIdService : NSObject

/**
 * Update user's data to InMobiUnifiedIdService in hashed form.
 * This method is used for identifying the user for user targeted ads.
 * InMobiUnifiedIdService does not persist users info.
 * It holds only the hashed info for a sessions lifetime.
 * Expected to be called on every app session and on user login.
 * @param data Represents user email and phone number in hashed format
 */
+ (void)push:(nullable IMUserDataModel *)data;

/**
 * Clears all UnifiedId info.
 * Cancels all ongoing requests (Push and fetch).
 * Clears publisher provided unified ids.
 * Expected to be called on user logout.
 */
+ (void)reset;

/**
 * Retrieves unified id from InMobi supported vendors.
 * @param delegate Represents the callback that delivers the unified ids.
 */
+ (void)fetchUnifiedIds:(id<IMUnifiedIdDelegate>)delegate;

/**
 * For testing unified id on simulators, publisher needs to enable debug mode.
 * Default value will be No. Debug mode is only for simulators, wont work on actual devices
 * @param debugMode Set true to enable debug mode.
 */
+ (void)enableDebugMode:(BOOL)debugMode;

@end

NS_ASSUME_NONNULL_END
