//
//  AINetStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/30.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AINetStore : NSObject

+(AINetStore*) sharedInstance;


/**
 *  MARK:--------------------存obj到神经网络--------------------
 */
-(BOOL) setObjectWithNetNode:(AINode*)node;                         //存神经网络_节点
-(BOOL) setObjectWithNetData:(AIObject*)data;                       //存神经网络_数据
-(BOOL) setObjectWithFuncModel:(AIFuncModel*)funcModel;             //存神经网络_算法
-(BOOL) setObject:(AIObject*)obj folderName:(NSString*)folderName pointerId:(NSInteger)pointerId;


/**
 *  MARK:--------------------根据节点指针取节点--------------------
 */
-(/*AIObject**/id) objectForKvPointer:(AIKVPointer*)kvPointer;


/**
 *  MARK:--------------------存nodePointer和elementId的映射--------------------
 */
-(BOOL) setMapWithNodePointer:(AIKVPointer*)nodePointer withEId:(NSInteger)eId;
-(BOOL) setMapWithFuncModelPointer:(AIKVPointer*)nodePointer withEId:(NSInteger)eId;
-(BOOL) setMapWithPointer:(AIKVPointer*)pointer folderName:(NSString*)folderName withEId:(NSInteger)eId;


/**
 *  MARK:--------------------是否已存过ElementId下的Node--------------------
 */
-(BOOL) containsNodeWithEId:(NSInteger)eId;
-(BOOL) containsFuncModelWithEId:(NSInteger)eId;
-(BOOL) containsObjectWithEId:(NSInteger)eId folderName:(NSString*)folderName;


/**
 *  MARK:--------------------get节点pointer根据eId--------------------
 */
-(AIKVPointer*) getNodePointerFromMapWithEId:(NSInteger)eId;
-(AIKVPointer*) getFuncModelPointerFromMapWithEId:(NSInteger)eId;
-(AIKVPointer*) getPointerFromMapWithFolderName:(NSString*)folderName withEId:(NSInteger)eId;

@end




@interface AINetStore (Memory)

@end
