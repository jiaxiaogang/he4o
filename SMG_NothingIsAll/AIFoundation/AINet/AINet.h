//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINetModel;
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

-(AIModel*) insertInt:(int)data;
-(AIModel*) insertFLoat:(float)data;
-(AIModel*) insertChar:(char)data;
-(AIModel*) insertObj:(id)data;
-(AIModel*) insertArr:(NSArray*)data;
-(AIModel*) insertLogic:(id)data;
-(AIModel*) insertCan:(id)data;
-(void) insertProperty:(id)data rootPointer:(AIPointer*)rootPointer;
-(void) insertModel:(AIModel*)model;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNetModel:(AINetModel*)model;


//MARK:===============================================================
//MARK:                     < search >
//MARK:===============================================================
-(AIModel*) searchInt:(int)data;
-(AIModel*) searchFLoat:(float)data;
-(AIModel*) searchChar:(char)data;
-(AIModel*) searchObj:(id)data;
-(AIModel*) searchArr:(NSArray*)data;
-(AIModel*) searchLogic:(id)data;
-(AIModel*) searchCan:(id)data;
-(AINetModel*) searchWithModel:(id)model;

@end
