//
//  UMRemoteConfigSettings.h
//  myFireBase
//
//  Created by 张军华 on 2019/12/30.
//  Copyright © 2019年 张军华. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMRemoteConfigSettings : NSObject

/// Indicates the default value in seconds to set for the minimum interval that needs to elapse
/// before a fetch request can again be made to the Remote Config backend. After a fetch request to
/// the backend has succeeded, no additional fetch requests to the backend will be allowed until the
/// minimum fetch interval expires.
/// @note 目前没用，保留字段
@property(atomic, assign) NSTimeInterval minimumFetchInterval;
/// Indicates the default value in seconds to abandon a pending fetch request made to the backend.
/// This value is set for outgoing requests as the timeoutIntervalForRequest as well as the
/// timeoutIntervalForResource on the NSURLSession's configuration.
/// @note 目前没用，保留字段
@property(atomic, assign) NSTimeInterval fetchTimeout;
///active after fetch config
///获取远程配置后，是否激活
@property(atomic, assign) BOOL activateAfterFetch;
@end

NS_ASSUME_NONNULL_END
