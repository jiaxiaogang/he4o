//
//  NVUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AINetAbsNode,AICMVNode,AIFrontOrderNode,AIAbsCMVNode;
@interface NVUtils : NSObject


//MARK:===============================================================
//MARK:                     < value的可视化 >
//MARK:===============================================================

//根据value指针数组描述 (i3 o4)
+(NSString*) convertValuePs2Str:(NSArray*)value_ps;


//MARK:===============================================================
//MARK:                       < node的可视化 >
//MARK:===============================================================

//foNode前时序列的描述 (i3 o4)
+(NSString*) getFoNodeDesc:(AIFoNodeBase*)foNode;

//cmvNode的描述 ("ur0_de0")
+(NSString*) getCmvNodeDesc:(AICMVNodeBase*)cmvNode;


//MARK:===============================================================
//MARK:           < cmvModel的可视化(foOrder->cmvNode) >
//MARK:===============================================================

//根据foNode的描述
+(NSString*) getCmvModelDesc_ByFoNode:(AIFoNodeBase*)foNode;

//根据cmvNode的描述
+(NSString*) getCmvModelDesc_ByCmvNode:(AICMVNodeBase*)cmvNode;

//根据cmvModel的描述 (fo: %@ => cmv: %@)
+(NSString*) getCmvModelDesc:(AIFoNodeBase*)absNode cmvNode:(AICMVNodeBase*)cmvNode;;


//MARK:===============================================================
//MARK:                     < conPorts & absPorts >
//MARK:===============================================================

//conPorts的描述 (conPorts >>\n > 1\n > 2)
+(NSString*) getFoNodeConPortsDesc:(AINetAbsNode*)absNode;

//absPorts的描述 (absPorts >>\n > 1\n > 2)
+(NSString*) getFoNodeAbsPortsDesc:(AIFoNodeBase*)foNode;


@end

