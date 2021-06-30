//
//  IMUserDataModel.h
//  InMobiSDK
//  Copyright © 2021 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMUserDataTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * InMobiUserDataModel is Data Model for passing user data in hashed form to InMobiUnifiedIdService.
 */

@interface IMUserDataModel : NSObject <NSCopying>

@property (nonatomic, strong) IMUserDataTypes* phoneNumber;
@property (nonatomic, strong) IMUserDataTypes* emailId;
@property (nonatomic, strong) NSDictionary* extras;

- (instancetype)initWithPhoneNumber:(nullable IMUserDataTypes *)phoneNumber
                            emailId:(nullable IMUserDataTypes *)emailId
                             extras:(nullable NSDictionary *)extras;

@end

NS_ASSUME_NONNULL_END
