//
//  NVUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AINetAbsNode,AICMVNode,AIFrontOrderNode;
@interface NVUtils : NSObject

/**
 *  MARK:--------------------将valud指针数组,转换成字符串--------------------
 */
+(NSString*) convertValuePs2Str:(NSArray*)value_ps;


/**
 *  MARK:--------------------获取某absNode的描述--------------------
 */
+(NSString*) getAbsNodeDesc:(AINetAbsNode*)absNode;



//MARK:===============================================================
//MARK:                     < cmv基本模型之 (foOrder->cmvNode)模型 >
//MARK:===============================================================

//根据foNode的描述
+(NSString*) getFoNodeDesc:(AIFrontOrderNode*)foNode;

//根据cmvNode的描述
+(NSString*) getCmvNodeDesc:(AICMVNode*)cmvNode;

//根据cmvModel的描述
+(NSString*) getCmvModelDesc:(AIFrontOrderNode*)foNode cmvNode:(AICMVNode*)cmvNode;

@end

