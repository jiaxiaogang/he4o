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
@class AINode,AIKVPointer,AIModel,AINodeBase;
@interface AINetStore : NSObject

+(AINetStore*) sharedInstance;


//MARK:===============================================================
//MARK:                     < setObject >
//MARK:===============================================================
-(AINode*) setObject:(AIModel*)data;                       //存神经网络_数据
-(AINode*) setObject:(AIModel*)data folderName:(NSString*)folderName pointerId:(NSInteger)pointerId;
-(void) setObjectNode:(AINodeBase*)node;
-(void) setObjectData:(id)data pointer:(AIKVPointer*)pointer;


//MARK:===============================================================
//MARK:                     < objectFor >
//MARK:===============================================================
-(/*AIObject**/id) objectForKvPointer:(AIKVPointer*)kvPointer;
-(BOOL) objectFor:(id)obj folderName:(NSString*)folderName;
-(AINodeBase*) objectNodeForPointer:(AIKVPointer*)kvPointer;
-(AINode*) objectNodeForClass:(Class)c;
-(AINodeBase*) objectRootNode;

@end



@interface AINetStore (Memory)
@end
