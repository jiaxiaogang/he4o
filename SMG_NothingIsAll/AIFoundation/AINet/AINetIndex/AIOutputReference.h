//
//  AIOutputReference.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------各Output算法,引用索引--------------------
 */
@class AIOutputKVPointer;
@interface AIOutputReference : NSObject

/**
 *  MARK:--------------------给outputNode建索引--------------------
 *  @param outputNode_p :   指outputNode或absOutputNode的节点地址;
 *  @param algsType     :   引用序列的分区标识
 *  @param dataTo       :   引用序列的算法标识(函数)
 */
-(void) setNodePointerToOutputReference:(AIOutputKVPointer*)outputNode_p algsType:(NSString*)algsType dataTo:(NSString*)dataTo difStrong:(NSInteger)difStrong;


/**
 *  MARK:--------------------根据"分区和算法标识"查找引用节点的node_p地址--------------------
 *  @param limit : 最多少个
 *  @param algsType : 分区标识
 *  @param dataTo   : 算法标识
 */
-(NSArray*) getNodePointersFromOutputReference:(NSString*)algsType dataTo:(NSString*)dataTo limit:(NSInteger)limit;

@end
