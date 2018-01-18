//
//  AIActionControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINode;
@interface AIActionControl : NSObject


+(AIActionControl*) shareInstance;


/**
 *  MARK:--------------------新事务--------------------
 *  由`意识控制器`提交过来的任务只是:
 *  1. 任务源:(神经网络的数据)
 *  2. 任务目标:(一个mindValue方向 | 其它)
 */



/**
 *  MARK:--------------------input输入--------------------
 */
-(void) commitInput:(id)input;


/**
 *  MARK:--------------------thinking搜索--------------------
 */
-(void) searchModel:(id)model type:(MultiNetType)type block:(void(^)(AINode *result))block;


/**
 *  MARK:--------------------thinking存储--------------------
 */
-(void) updateNetModel:(AINode*)model;
-(AINode*) insertModel:(AIModel*)model;

@end
