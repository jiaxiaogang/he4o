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
-(AINode*) searchAbstract_Induction:(NSString*)className;
-(void) searchModel_Induction:(id)model block:(void(^)(AINode *result))block;
-(void) searchModel_Logic:(AIInputMindValueAlgsModel*)model block:(void(^)(AINode *result))block;

/**
 *  MARK:--------------------thinking存储--------------------
 */
-(AINode*) insertModel:(AIModel*)model dataSource:(NSString*)dataSource;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model;
-(void) updateNode:(AINode*)node abs:(AINode*)abs;
-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode;


@end





