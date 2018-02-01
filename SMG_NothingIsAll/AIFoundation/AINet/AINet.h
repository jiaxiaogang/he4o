//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINode,AIInputMindValueAlgsModel;
@interface AINet : NSObject

+(AINet*) sharedInstance;

//MARK:===============================================================
//MARK:                     < insert >
//MARK:===============================================================
//MARK:--------------------构建属性--------------------
-(void) insertProperty:(NSString*)propertyName;

//MARK:--------------------构建值--------------------
-(void) insertValue:(id)value;

//MARK:--------------------构建变化--------------------
-(void) insertChange:(id)change;

//MARK:--------------------构建父类--------------------
-(void) insertParent:(NSString*)parentName;

//MARK:--------------------构建子类--------------------
-(void) insertSubX:(id)subX;

//MARK:--------------------构建实例--------------------
-(void) insertInstance:(id)instance;

//MARK:--------------------构建接口--------------------
-(void) insertMethod:(NSString*)method;
-(AINode*) insertObj:(id)data;
-(AINode*) insertArr:(NSArray*)data;
-(AINode*) insertLogic:(AIInputMindValueAlgsModel*)data;
-(AINode*) insertCan:(id)data;
-(void) insertProperty:(id)data rootPointer:(AIPointer*)rootPointer;
-(AINode*) insertModel:(AIModel*)model energy:(NSInteger)energy;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model;


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AINode*) searchObj:(id)data;
-(AINode*) searchArr:(NSArray*)data;
-(AINode*) searchLogic:(id)data;
-(AINode*) searchCan:(id)data;
-(AINode*) searchWithModel:(id)model;
-(AINode*) searchAbstract_Induction:(NSString*)className;

@end
