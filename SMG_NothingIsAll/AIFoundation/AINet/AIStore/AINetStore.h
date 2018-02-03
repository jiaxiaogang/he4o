//
//  AINetStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/30.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------AINetStore存储器--------------------
 *  1. 自动进行AIPointer,AILine,AIPort,存储等操作;
 */
@class AINode,AIKVPointer,AIModel,AINode;
@interface AINetStore : NSObject

+(AINetStore*) sharedInstance;


//MARK:===============================================================
//MARK:                     < setObject >
//MARK:===============================================================
-(AINode*) setObjectModel:(AIModel*)model dataSource:(NSString*)dataSource;     //存思维结果_定义
-(void) setObjectNode:(AINode*)node;
-(void) setObjectData:(id)data pointer:(AIKVPointer*)pointer;


//MARK:===============================================================
//MARK:                     < objectFor >
//MARK:===============================================================
-(id) objectDataForPointer:(AIKVPointer*)pointer;
-(AINode*) objectNodeForDataModel:(AIModel*)model;
-(AINode*) objectNodeForDataObj:(id)obj;
-(AINode*) objectNodeForPointer:(AIKVPointer*)kvPointer;
-(AINode*) objectNodeForDataType:(NSString*)dataType dataSource:(NSString*)dataSource;//找条件dataType(String,char,int,imv)与dataSource(inputModel的属性名)的根节点;(不判断则传nil)
-(AINode*) objectRootNode;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNode:(AINode*)node abs:(AINode*)absNode;
-(void) updateNode:(AINode *)node propertyNode:(AINode *)propertyNode;

@end


@interface AINetStore (Memory)
@end
