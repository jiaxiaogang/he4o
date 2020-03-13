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
 */
+(NSArray*) filterByTime:(NSString*)startT endT:(NSString*)endT checkDatas:(NSArray*)checkDatas;
+(NSArray*) filterByKeyword:(NSString*)keyword checkDatas:(NSArray*)checkDatas;

@end
