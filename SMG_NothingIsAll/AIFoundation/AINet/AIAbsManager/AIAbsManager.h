//
//  AIAbsManager.h
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
@interface AIAbsManager : NSObject


/**
 *  MARK:--------------------在foNode基础上构建抽象--------------------
 *  @params foA         : conFoA (item类型为AIFoNodeBase)
 *  @params orderSames  : algNode组
 *  @result : notnull
 */
-(AINetAbsFoNode*) create:(AIFoNodeBase*)foA foB:(AIFoNodeBase*)foB orderSames:(NSArray*)orderSames;

@end
