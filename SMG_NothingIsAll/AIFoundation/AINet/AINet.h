//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINode,AIImvAlgsModel,AIPointer,AIKVPointer,AIPort;
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
-(AINode*) insertArr:(NSArray*)data;
-(AINode*) insertLogic:(AIImvAlgsModel*)data;
-(AINode*) insertCan:(id)data;
-(void) insertProperty:(id)data rootPointer:(AIPointer*)rootPointer;
-(AINode*) insertModel:(AIModel*)model dataSource:(NSString*)dataSource energy:(NSInteger)energy;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINode*)model;
-(void) updateNode:(AINode*)node abs:(AINode*)abs;
-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode;
-(void) updateNode:(AINode *)node changeNode:(AINode *)changeNode;
-(void) updateNode:(AINode *)node logicNode:(AINode *)logicNode;


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AINode*) searchObj:(id)data;
-(AINode*) searchArr:(NSArray*)data;
-(AINode*) searchCan:(id)data;
-(AINode*) searchNodeForDataModel:(AIModel*)model;
-(AINode*) searchNodeForDataObj:(id)obj;
-(AINode*) searchNodeForDataType:(NSString*)dataType dataSource:(NSString*)dataSource;


//MARK:===============================================================
//MARK:                     < index >
//MARK:===============================================================
-(NSMutableArray*) getAlgsArr:(NSObject*)algsModel;  //装箱 (algsModel to indexPointerArr);

-(void) setItemAlgsReference:(AIKVPointer*)indexPointer port:(AIPort*)port difValue:(int)difValue;
-(NSArray*) getItemAlgsReference:(AIKVPointer*)pointer limit:(NSInteger)limit;  //获取算法单结果的第二序列联想;

@end
