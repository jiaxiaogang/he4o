//
//  NVUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AINetAbsNode;
@interface NVUtils : NSObject

/**
 *  MARK:--------------------将valud指针数组,转换成字符串--------------------
 */
+(NSString*) convertValuePs2Str:(NSArray*)value_ps;


/**
 *  MARK:--------------------获取某absNode的描述--------------------
 */
+(NSString*) getAbsNodeDesc:(AINetAbsNode*)absNode;

@end

