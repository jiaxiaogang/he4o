//
//  AIActionControl.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINode,AIInputMindValueAlgsModel;
@interface AIActionControl : NSObject


+(AIActionControl*) shareInstance;


/**
 *  MARK:--------------------input输入--------------------
 */
-(void) commitInput:(id)input;


/**
 *  MARK:--------------------thinking搜索--------------------
 */
-(void) searchModel_Induction:(id)model block:(void(^)(AINode *result))block;
-(void) searchModel_Logic:(AIInputMindValueAlgsModel*)model block:(void(^)(AINode *result))block;

/**
 *  MARK:--------------------thinking存储--------------------
 */
-(void) updateNetModel:(AINode*)model;
-(AINode*) insertModel:(AIModel*)model;

@end
