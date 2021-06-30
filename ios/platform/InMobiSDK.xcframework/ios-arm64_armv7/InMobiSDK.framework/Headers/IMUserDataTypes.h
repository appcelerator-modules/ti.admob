//
//  IMUserDataTypes.h
//  InMobiSDK
//  Copyright © 2021 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * InMobiUserDataTypes is Data Model for holding user data in hashed format
 * that uses InMobiUserDataTypes to hold on to user email and phone number
 */

@interface IMUserDataTypes : NSObject <NSCopying>

@property (nonatomic, strong) NSString* md5;
@property (nonatomic, strong) NSString* sha1;
@property (nonatomic, strong) NSString* sha256;

- (instancetype)initWithMd5:(nullable NSString *)md5
                       sha1:(nullable NSString *)sha1
                     sha256:(nullable NSString *)sha256;

@end

NS_ASSUME_NONNULL_END
