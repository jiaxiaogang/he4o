//
//  Output.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------输出--------------------
 *  1. 把OUTPUT有时间的话;融入到神经网络中...(小脑机制)
 *  2. 共分为两种反射机制; (内核外部的调用output_Reactor:和内部的调用如:output_Face:)
 *  3. 输出从 "反射输出" 到 "主动输出";
 *
 */
@class AIKVPointer;
@interface Output : NSObject

/**
 *  MARK:--------------------反射输出--------------------
 *  @param outputModels : OutputModel数组;
 *  如: 吸吮,抓握
 *  注: 先天,被动
 */
+(void) output_Reactor:(NSArray*)outputModels;


/**
 *  MARK:--------------------思维输出--------------------
 *  @param algNode_p : 概念节点指针
 *  @result 输出有效(>1条)时,返回true;
 *  如: 吃奶,飞行
 *  注: 后天,主动 (由神经网络后天执行输出: 检查执行微信息输出)
 */
+(BOOL) output_TC:(AIKVPointer*)algNode_p;


/**
 *  MARK:--------------------情绪输出--------------------
 *  @param type : 情绪类型
 *  如: 焦急
 *  注: 先天,主动 (由思维控制器主动调用发泄情绪)
 *  代码实践: 对Anxious情绪,testHungryDemo与birdGrowDemo的反应肯定就不是一样的,所以具体执行的outModel由应用层指定;
 */
+(void) output_Mood:(AIMoodType)type;

@end
