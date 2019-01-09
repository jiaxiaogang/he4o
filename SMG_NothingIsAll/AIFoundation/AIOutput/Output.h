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
 *  MARK:--------------------先天执行输出器--------------------
 *  @param outputModels : OutputModel数组;
 */
+(void) output_Reactor:(NSArray*)outputModels;


/**
 *  MARK:--------------------后天检查执行输出--------------------
 *  @param algNode_p : 祖母节点指针
 *  @result 输出有效(>1条)时,返回true;
 *  由神经网络后天执行输出: 检查执行微信息输出
 */
+(BOOL) output_TC:(AIKVPointer*)algNode_p;

@end
