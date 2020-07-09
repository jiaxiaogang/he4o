//
//  UMRemoteConfig.h
//  myFireBase
//
//  Created by 张军华 on 2019/12/30.
//  Copyright © 2019年 张军华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMRemoteConfigEnum.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^UMRemoteConfigFetchCompletion)(UMRemoteConfigFetchStatus status,
                                               NSError *_Nullable error);

typedef void (^UMRemoteConfigActivateCompletion)(NSError *_Nullable error);

@protocol UMRemoteConfigDelegate<NSObject>

@optional
/**
 *  @brief 获取服务器的网络请求的回调
 *  @param status see UMRemoteConfigFetchStatus
 *  @param error 错误信息
 *  @param userInfo  该回调的扩展信息
 *  @note  调用函数触发此回调
 *         fetchWithCompletionHandler
 *         fetchAndActivateWithCompletionHandler
 */
-(void)remoteConfigFetched:(UMRemoteConfigFetchStatus)status
                           error:(nullable NSError*)error
                        userInfo:(nullable id)userInfo;


/**
 *  @brief 远程配置被激活的回调
 *  @param status see UMRemoteConfigActiveStatus
 *  @param error 错误信息
 *  @param userInfo  该回调的扩展信息
 *  @note  调用函数触发此回调
 *         fetchAndActivateWithCompletionHandler
 *         activateWithCompletionHandler
 */
-(void)remoteConfigActivated:(UMRemoteConfigActiveStatus)status
                       error:(nullable NSError*)error
                    userInfo:(nullable id)userInfo;


/**
 *  @brief 配置已经准备就绪
 *  @param status see UMRemoteConfigActiveStatus
 *  @param error 错误信息
 *  @param userInfo  该回调的扩展信息
 *  @note  调用函数触发此回调
 *         fetchWithCompletionHandler
 */
-(void)remoteConfigReady:(UMRemoteConfigActiveStatus)status
                   error:(nullable NSError*)error
                userInfo:(nullable id)userInfo;

@end

@class UMRemoteConfigSettings;
@interface UMRemoteConfig : NSObject

@property(nonatomic,assign)id<UMRemoteConfigDelegate> remoteConfigDelegate;
@property(nonatomic, readwrite, strong) UMRemoteConfigSettings *configSettings;


#pragma mark - init
/**
 *  @brief 远程配置单例
 *  @param delegate  see UMRemoteConfigDelegate
 *  @note 用户初始化时候，
    先调用 remoteConfigWithDelegate:(id<UMRemoteConfigDelegate>)delegate，可以保证上次ready的数据可以回调给用户。
 */
+ (UMRemoteConfig *)remoteConfigWithDelegate:(nullable id<UMRemoteConfigDelegate>)delegate
                          withConfigSettings:(nullable UMRemoteConfigSettings*)configSettings;
+ (UMRemoteConfig *)remoteConfig;
#pragma mark - activate
/**
 *  @brief 激活本地配置
 *  @param completionHandler 回调
 */
+ (void)activateWithCompletionHandler:(nullable UMRemoteConfigActivateCompletion)completionHandler;

#pragma mark - Get Config
/**
 *  @brief 获取配置信息
 *  @param key 对应的key
 *  @note 获取配置的有限顺利，远程配置->Defaults
 */
+ (nullable id)configValueForKey:(nullable NSString *)key;

#pragma mark - Defaults
/**
 *  @brief 设置本地默认配置
 *  @param defaults 对应的本地配置
 */
+ (void)setDefaults:(nullable NSDictionary<NSString *, NSObject *> *)defaults;

/**
 *  @brief 设置本地默认配置
 *  @param fileName 包含本地配置的plist文件
 */
+ (void)setDefaultsFromPlistFileName:(nullable NSString *)fileName;


@end

NS_ASSUME_NONNULL_END
