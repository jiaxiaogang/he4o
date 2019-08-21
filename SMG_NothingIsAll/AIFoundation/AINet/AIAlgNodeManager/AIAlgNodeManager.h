//
//  AIAlgNodeManager.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/14.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAlgNode,AIAbsAlgNode;
@interface AIAlgNodeManager : NSObject


/**
 *  MARK:--------------------构建algNode--------------------
 *  1. 自动将algsArr中的元素分别生成absAlgNode
 *  2. absAlgNode根据索引的去重而去重;
 *  3. 具象algNode根据网络中联想而去重; (for(abs1.cons) & for(abs2.cons))
 *  4. abs和con都要有关联强度序列; (目前不需要,以后有需求的时候再加上)
 *  5. 微信息引用处理: value索引中,加上refPorts;类似algNode.refPorts的方式使用;并且使用单文件的方式存储和插线;
 *
 *  @param algsArr      : 算法值的装箱数组;
 *  @param isMem        : 为false时,持久化构建(如commitOutput),为true时仅内存网络中(如dataIn);
 *  _param dataSource  : 概念节点的dataSource就是稀疏码信息的algsType (不传时,从algsArr提取)
 *  @result notnull     : 返回具象algNode
 */
+(AIAlgNode*) createAlgNode:(NSArray*)algsArr isOut:(BOOL)isOut isMem:(BOOL)isMem;
+(AIAlgNode*) createAlgNode:(NSArray*)algsArr dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem;


/**
 *  MARK:--------------------构建absAlgNode中间概念节点--------------------
 *  @param value_ps     : 要构建absAlgNode的content_ps notnull;
 *  @param conAlgs      : 具象AIAlgNode数组:(外类比时的algA&algB / 内类比时仅有一个元素) //不可为空数组
 *  @param isMem        : 是否持久化,(如thinkIn中,视觉场景下的subView就不进行持久化,只存在内存网络中)
 *  _param dataSource  : 概念节点的dataSource就是稀疏码信息的algsType; (不传时,从algsArr提取)
 *
 *  注: TODO:判断algSames是否就是algsA或algB本身; (等conAlgNode和absAlgNode统一不区分后,再判断本身)
 */
+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem;
+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs dataSource:(NSString*)dataSource isMem:(BOOL)isMem;

@end
