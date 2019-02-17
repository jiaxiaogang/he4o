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
 *  @param algsArr   : 算法值的装箱数组;
 *  @result 具象algNode
 */
+(AIAlgNode*) createAlgNode:(NSArray*)algsArr isOut:(BOOL)isOut;


/**
 *  MARK:--------------------构建absAlgNode中间祖母节点--------------------
 *  注: TODO:判断algSames是否就是algsA或algB本身; (等conAlgNode和absAlgNode统一不区分后,再判断本身)
 */
+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)algSames algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB;

@end
