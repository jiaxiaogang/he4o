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


//MARK:===============================================================
//MARK:                     < value的可视化 >
//MARK:===============================================================

//根据value指针数组描述 (i3 o4)
+(NSString*) convertValuePs2Str:(NSArray*)value_ps;



//MARK:===============================================================
//MARK:                       < node的可视化 >
//MARK:===============================================================

//根据absNode描述
+(NSString*) getAbsNodeDesc:(AINetAbsNode*)absNode;



//MARK:===============================================================
//MARK:           < cmvModel的可视化(foOrder->cmvNode) >
//MARK:===============================================================

//根据foNode的描述
+(NSString*) getFoNodeDesc:(AIFrontOrderNode*)foNode;

//根据cmvNode的描述
+(NSString*) getCmvNodeDesc:(AICMVNode*)cmvNode;

//根据cmvModel的描述
+(NSString*) getCmvModelDesc:(AIFrontOrderNode*)foNode cmvNode:(AICMVNode*)cmvNode;

@end

