//
//  IMCoreConstants.h
//  InMobiSDK
//
//  Copyright © 2018 InMobi. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef IMCoreConstants_h
#define IMCoreConstants_h

#define kIMEmptyStr @""
#define kIMMillisInSec 1000.0f

#pragma mark - Block Typedef Constants

typedef void (^ASCompletionBlock)(void);
typedef void (^ASSuccessBlock)(BOOL success);
typedef void (^ASErrorCompletionBlock)(NSError* err);
typedef void (^ASDataTaskCompletionBlock)(NSData* data, NSURLResponse* resp, NSError* err);
typedef void (^ASDataCompletionBlock)(NSData* data);

#pragma mark - MediationEvents

typedef NS_ENUM(NSInteger, IMMediationEvent) {
    kIMMediationEventAttempt = 12,
    kIMMediationEventImpression = 13,
    kIMMediationEventFailure = 14,
    kIMMediationEventAdReturned = 34,
    kIMMediationEventConnectionError = 35,
    kIMMediationEventFailShow = 36,
    kIMMediationEventAdapterRefresh = 37
};

typedef NS_ENUM(NSInteger, IMInterstitialAnimationType) {
    kIMInterstitialAnimationTypeCoverVertical,
    kIMInterstitialAnimationTypeFlipHorizontal,
    kIMInterstitialAnimationTypeNone
};

typedef NS_ENUM(NSInteger, IMPrimaryIntegration) {
    kIMPrimaryIntegrationUndefined = -1,
    kIMPrimaryIntegrationAerServ = 0,
    kIMPrimaryIntegrationInMobi = 1
};

typedef NS_ENUM(NSInteger, IMCoreAdState) {
    kIMCoreAdStateInit = 0,
    kIMCoreAdStatePreloading,
    kIMCoreAdStatePreloaded,
    kIMCoreAdStateLoading,
    kIMCoreAdStateLoaded,
    kIMCoreAdStateShowCalled,
    kIMCoreAdStateRendered,
    kIMCoreAdStateActive,
    kIMCoreAdStateDismissed,
    kIMCoreAdStateFailed
};

typedef NS_ENUM(NSInteger, IMUnifiedTimeout) {
    kIMUnifiedTimeoutPreinit = 0,
    kIMUnifiedTimeoutMutt,
    kIMUnifiedTimeoutMediationLoad,
    kIMUnifiedTimeoutUnifiedAuction,
    kIMUnifiedTimeoutRendering,
    kIMUnifiedTimeoutShow,
    kIMUnifiedTimeoutBitmap
};

// SDK Meta Info
extern NSString* const kASIMUnifiedMediationNetworkName;
extern NSString* const kASIMUnifiedSDKName;

// Unified SDK Timeouts
extern NSTimeInterval const kASIMUnifiedStep0_Preinit_TimeoutDefaultVal;
extern NSTimeInterval const kASIMUnifiedStep1a_Mutt_TimeoutDefaultVal;
extern NSTimeInterval const kASIMUnifiedStep1b_MediationLoad_TimeoutDefaultVal;
extern NSTimeInterval const kASIMUnifiedStep2u_UnifiedAuction_UTimeoutDefaultVal;
extern NSTimeInterval const kASIMUnifiedStep3r_Render_TimeoutDefaultVal;
extern NSTimeInterval const kASIMUnifiedStep4s_Show_TimeoutDefaultVal;

// Unified Auction Endpoint
extern NSString* const kUnifiedAuctionEndPointUrl;

// Unified Auction Keys
extern NSString* const kASIMUnifiedAuction_RequestID_Key;
extern NSString* const kASIMUnifiedAuction_AdType_Key;
extern NSString* const kASIMUnifiedAuction_AdSetAuctionMeta_Key;
extern NSString* const kASIMUnifiedAuction_ImpressionId_Key;
extern NSString* const kASIMUnifiedAuction_AdAuctionMeta_Key;
extern NSString* const kASIMUnifiedAuction_DynamicBid_Key;
extern NSString* const kASIMUnifiedAuction_Macros_Key;

// KeyStore Keys
extern NSString* const kASIMKVStoreSDKSettings;
extern NSString* const kASIMKVStoreMappingManagers;
extern NSString* const kASIMKVStorePlacementInfo;
extern NSString* const kASIMKVStoreTrueBaseEventUrls;

// Ad Markup Types
extern NSString* const kASIMAdMarkupTypeInMobiJSON;
extern NSString* const kASIMAdMarkupTypeHTML;
extern NSString* const kASIMAdMarkupTypeMediationJSON;

// Banner Refresh
extern NSTimeInterval const kASIMBannerRefreshUnset;
extern NSTimeInterval const kASIMBannerRefreshDisabledForAS;
extern NSTimeInterval const kASIMBannerRefreshDefault;
extern NSTimeInterval const kASIMBannerRefreshMinimum;

// Interstitial Base VC Close Button
extern NSTimeInterval const kASIMInterstitialBaseVCCloseButtonDelay;

// AS Tracking Events
extern NSString* const kASBannerRenderedEventType;
extern NSString* const kASVASTImpressionEventType;

// NSCoding Keys
extern NSString* const kASIMCodingIntTypeKey;
extern NSString* const kASIMCodingIMAccountIdKey;
extern NSString* const kASIMCodingASAppIdKey;
extern NSString* const kASIMCodingPrimaryAcctIdKey;
extern NSString* const kASIMCodingSecondaryAcctIdKey;
extern NSString* const kASIMCodingAppIdKey;
extern NSString* const kASIMCodingLocationKey;
extern NSString* const kASIMCodingBSSIDKey;
extern NSString* const kASIMCodingCellKey;
extern NSString* const kASIMCodingMappingTableKey;
extern NSString* const kASIMCodingMappingASKey;
extern NSString* const kASIMCodingMappingIMKey;
extern NSString* const kASIMCodingASPlacementKey;
extern NSString* const kASIMCodingIMPlacementKey;
extern NSString* const kASIMCodingPreinitBannerRefresh;
extern NSString* const kASIMCodingHasDynamicKey;
extern NSString* const kASIMCodingHasRewardsKey;
extern NSString* const kASIMCodingIsDebugKey;
extern NSString* const kASIMCodingPubKeysKey;
extern NSString* const kASIMCodingUserIdKey;
extern NSString* const kASIMCodingSecureOnlyKey;
extern NSString* const kASIMCodingKeywordsKey;
extern NSString* const kASIMCodingExtKey;
extern NSString* const kASIMCodingExtrasKey;
extern NSString* const kASIMCodingRefreshEnabledKey;
extern NSString* const kASIMCodingRefreshIntervalKey;
extern NSString* const kASIMCodingAnimationTypeKey;
extern NSString* const kASIMCodingPrimaryFlow;

//preinit request keys
extern NSString* const kASApplicationKey;
extern NSString* const kASVersionKey;
extern NSString* const kASIPhoneSDK;
extern NSString* const kASAsPlcId;
extern NSString* const kASGDPRConsentKey;
extern NSString* const kASAppId;

extern NSString* const kASContentTypeKey;
extern NSString* const kASTextHtmlMimeType;
extern NSString* const kASTextXmlMimeType;
extern NSString* const kASApplicationJsonMimeType;

//preinit keys
extern NSString* const kPlacementInfoASPlacementKey;
extern NSString* const kPlacementInfoIMPlacementKey;
extern NSString* const kPlacementInfoBannerRefresh;

#endif /* IMCoreConstants_h */
