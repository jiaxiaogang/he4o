//
//  AIRecognitionCache.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/26.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------同一时刻调用识别的缓存--------------------
 *  @desc 说明：用于缓存单次概念识别中：其单码识别，组码识别，特征识别 的结果。
 *        原因：因为单次概念识别中（同时刻内，整个长时网络不会有新的变化），但总是有重复的特征、组码、单码在跑识别，所以完全可以用缓存来避免重复。
 */
@interface AIRecognitionCache : NSObject

/**
 *  MARK:--------------------取缓存，如果无缓存，则调用加载后返回--------------------
 *  @param key 可以传要识别的AIKVPointer过来当key。
 *  @result 返回的一般是AIMatchModel为元素的数组。
 */
+(id) getCache:(id)key cacheBlock:(id(^)())cacheBlock;
+(void) printLog:(BOOL)andReset;

@end
