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
 *
 *  @param algsArr   : 算法值的装箱数组;
 *  @result 具象algNode
 */
+(AIAlgNode*) createAlgNode:(NSArray*)algsArr;


/**
 *  MARK:--------------------构建absAlgNode中间祖母节点--------------------
 */
+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)algSames algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB;

@end
