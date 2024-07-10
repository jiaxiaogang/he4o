//
//  HeLogUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/14.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeLogUtil : NSObject

/**
 *  MARK:--------------------filter--------------------
 *  @param startT : 格式为yyyyMMddHHmmssSSS 如: 20201230235959000
 */
+(NSArray*) filterByTime:(NSString*)startT endT:(NSString*)endT checkDatas:(NSArray*)checkDatas;
+(NSArray*) filterByKeyword:(NSString*)keyword checkDatas:(NSArray*)checkDatas;

/**
 *  MARK:--------------------数据的标识--------------------
 */
+(NSString*) idenByData:(NSMutableArray*)datas;

/**
 *  MARK:--------------------NSData MD5--------------------
 */
+(NSString *)md5ByData:(NSData*)data;

//返回demand打日志时的pointer;
+(AIKVPointer*) demandLogPointer:(DemandModel*)demand;

//缩进的前辍,每缩进单位两个空字符;
+(NSString*) getPrefixStr:(int)prefixNum;

@end
