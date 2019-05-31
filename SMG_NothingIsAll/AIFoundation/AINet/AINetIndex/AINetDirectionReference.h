//
//  AINetDirectionReference.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/11.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------CMV方向索引--------------------
 *  1. 用于mvNode的唯一抽象;(+或-的
 *  2. 每种类型的mindValue仅有一个+,一个-;所以无需引用序列;
 *  3. 每种类型的mindValue仅有一个+和-值,所以无需索引序列;
 *  4. 在本类中,分别存储每个mv类型的正负两个序列,将所有类型的mv的+和-的节点地址,以有序的方式依次存入;(strong从小到大)
 *  5. mv的索引序列与引用序列都在本类中;因为direction没有值,只有方向;
 *  6. 每个mv区的引用序列,以(按引用数排序)(如吃饭,比吃苹果引用数高很多)
 */
@interface AINetDirectionReference : NSObject


/**
 *  MARK:--------------------查找direction引用的节点的node_p地址--------------------
 *  @param limit : 最多少个
 *  @param mvAlgsType : 分区标识(mv类型)
 *  @param direction : mv变化方向
 *  @param isMem : 取内存网络/硬盘网络
 */
-(NSArray*) getNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem limit:(NSInteger)limit;


/**
 *  MARK:--------------------根据筛选器,将方向mv的port返回--------------------
 *  @param filter : 指定筛选器
 *  @param mvAlgsType : 分区标识(mv类型)
 *  @param direction : mv变化方向
 *  @param isMem : 取内存网络/硬盘网络
 */
-(NSArray*) getNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem filter:(NSArray*(^)(NSArray *protoArr))filter;


@end
