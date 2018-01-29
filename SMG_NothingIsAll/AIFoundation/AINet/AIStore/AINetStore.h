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
-(AINode*) setObject_Define:(AIModel*)data;     //存思维结果_定义
-(AINode*) setObject_Define:(AIModel*)data folderName:(NSString*)folderName;
-(void) setObject_Value:(id)model;              //存思维结果_值
-(void) setObjectNode:(AINode*)node;
-(void) setObjectData:(id)data pointer:(AIKVPointer*)pointer;


//MARK:===============================================================
//MARK:                     < objectFor >
//MARK:===============================================================
-(/*AIObject**/id) objectDataForPointer:(AIKVPointer*)pointer;
-(AINode*) objectNodeForData:(id)obj;
-(AINode*) objectNodeForPointer:(AIKVPointer*)kvPointer;
-(AINode*) objectNodeForDataType:(NSString*)dataType;//找(String,char,int,imv)的根节点;
-(AINode*) objectRootNode;


//MARK:===============================================================
//MARK:                     < update >
//MARK:===============================================================
-(void) updateNode:(AINode*)node abs:(AINode*)absNode;


@end



@interface AINetStore (Memory)
@end
