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
@class AINetAbsFoNode;
@interface AIAbsManager : NSObject


/**
 *  MARK:--------------------在foNode基础上构建抽象--------------------
 *  @params conFoNodes : 具象节点 (item类型为AIFoNodeBase)
 *  @params refs_p : 微信息组
 *  @result : notnull
 */
-(AINetAbsFoNode*) create:(NSArray*)conFoNodes refs_p:(NSArray*)refs_p;

@end
