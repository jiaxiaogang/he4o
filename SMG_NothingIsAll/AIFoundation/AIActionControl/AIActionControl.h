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


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
+(AIActionControl*) shareInstance;
-(void) commitInput:(id)input;


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AINode*) searchNodeForDataType:(NSString*)dataType dataSource:(NSString *)dataSource;
-(AINode*) searchNodeForDataType:(NSString*)dataType dataSource:(NSString *)dataSource autoCreate:(AIModel*)createModel;//类比时自动构建abs
-(AINode*) searchNodeForDataModel:(AIModel*)model;
-(AINode*) searchNodeForDataObj:(id)obj;


//MARK:===============================================================
//MARK:                     < insert >
//MARK:===============================================================
-(AINode*) insertModel:(AIModel*)model dataSource:(NSString*)dataSource;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model;
-(void) updateNode:(AINode*)node abs:(AINode*)abs;
-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode;


@end





