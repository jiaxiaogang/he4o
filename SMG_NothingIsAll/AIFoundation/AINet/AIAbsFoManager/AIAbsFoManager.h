//
//  AIAbsFoManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < AINetAbs管理器 >
//MARK:===============================================================
@class AINetAbsFoNode,AIFoNodeBase;
@interface AIAbsFoManager : NSObject


/**
 *  MARK:--------------------在foNode基础上构建抽象--------------------
 *  @params conFos      : 具象节点们 (item类型为AIFoNodeBase) (外类比时,传入foA和foB) (内类比时传入conFo即可)
 *  @params orderSames  : algNode组
 *  @result : notnull
 *  注: 转移: 仅概念支持内存网络向硬盘网络的转移,fo不进行转移;
 */
-(AINetAbsFoNode*) create:(NSArray*)conFos orderSames:(NSArray*)orderSames;

@end
