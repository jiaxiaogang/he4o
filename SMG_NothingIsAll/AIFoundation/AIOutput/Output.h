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
 *  MARK:--------------------反射输出器methodName--------------------
 */
+(NSString*) getReactorMethodName;


/**
 *  MARK:--------------------内部反射封装--------------------
 *  1. 随后将其重构为外部方便扩展的方式;
 *  2. 例如:对Anxious情绪,testHungryDemo与birdGrowDemo的反应肯定就不是一样的;
 */
+(void) output_Face:(AIMoodType)type;


/**
 *  MARK:--------------------反射输出器--------------------
 *  @param rds         : 先天反射标识 (作为dataSource的后辍);
 *  @param paramNum    : 参数值 (目前仅支持1个)
 */
+(void) output_Reactor:(NSString*)rds paramNum:(NSNumber*)paramNum;


/**
 *  MARK:--------------------后天检查执行输出--------------------
 *  @param algNode_p : 祖母节点指针
 @  @result 输出有效(>1条)时,返回true;
 */
+(BOOL) checkAndInvoke:(AIKVPointer*)algNode_p;

@end
