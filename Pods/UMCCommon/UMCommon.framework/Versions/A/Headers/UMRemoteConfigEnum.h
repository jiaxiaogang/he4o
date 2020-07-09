//
//  UMRemoteConfigEnum.h
//  myFireBase
//
//  Created by 张军华 on 2019/12/30.
//  Copyright © 2019年 张军华. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Indicates whether updated data was successfully fetched.
typedef NS_ENUM(NSInteger, UMRemoteConfigFetchStatus) {
    /// Config has never been fetched.
    UMRemoteConfigFetchStatusNoFetchYet,
    /// Config fetch succeeded.
    UMRemoteConfigFetchStatusSuccess,
    /// Config fetch failed.
    UMRemoteConfigFetchStatusFailure,
    /// Config fetch was throttled.
    UMRemoteConfigFetchStatusThrottled,
};


/// Indicates whether ActiveStatus in the local data .
typedef NS_ENUM(NSInteger, UMRemoteConfigActiveStatus) {
    UMRemoteConfigActiveStatus_None,
    UMRemoteConfigActiveStatus_Ready,
    UMRemoteConfigActiveStatus_Active,
    UMRemoteConfigActiveStatus_Expiration
};



///// Indicates whether updated data was successfully fetched and activated.
//typedef NS_ENUM(NSInteger, UMRemoteConfigFetchAndActivateStatus) {
//    // The remote fetch succeeded and fetched data was activated.
//    UMRemoteConfigFetchAndActivateStatusSuccessFetchedFromRemote,
//    // The fetch and activate succeeded from already fetched but yet unexpired config data. You can
//    // control this using minimumFetchInterval property in FIRRemoteConfigSettings.
//    UMRemoteConfigFetchAndActivateStatusSuccessUsingPreFetchedData,
//    // The fetch and activate failed.
//    UMRemoteConfigFetchAndActivateStatusError
//};

//typedef NS_ENUM(NSInteger, UMRemoteConfigSource) {
//    UMRemoteConfigSourceRemote,   ///< The data source is the Remote Config service.
//    UMRemoteConfigSourceDefault,  ///< The data source is the DefaultConfig defined for this app.
//    UMRemoteConfigSourceStatic,   ///< The data doesn't exist, return a static initialized value.
//};


NS_ASSUME_NONNULL_END
