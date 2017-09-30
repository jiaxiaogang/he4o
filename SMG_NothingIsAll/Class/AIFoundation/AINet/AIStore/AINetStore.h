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
 *  MARK:--------------------存神经网络的节点--------------------
 */
-(BOOL) setObject_NetNode:(AINode*)node;

/**
 *  MARK:--------------------存obj到神经网络--------------------
 */
-(BOOL) setObject:(AIObject*)obj folderName:(NSString*)folderName pointerId:(NSInteger)pointerId;

/**
 *  MARK:--------------------存nodePointer和elementId的映射--------------------
 */
-(BOOL) setObject_NodePointerEId:(AIKVPointer*)nodePointer eId:(NSInteger)eId;

@end
