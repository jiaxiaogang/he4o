//
//  AINetCMVIndex.h
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
 *  4. 在本类中,仅存储正负两个序列,将所有类型的mv的+和-的节点地址,以有序的方式依次存入;
 */
@interface AINetCMVIndex : NSObject

/**
 *  MARK:--------------------给cmvNode建索引--------------------
 *  @param cmvNode_p : 指cmvNode或absCMVNode的节点地址;
 *  @param cmvNodePort : 指cmvNode或absCMVNode的被插口;
 */
-(AIKVPointer*) setNodePointerToDirectionIndex:(AIKVPointer*)cmvNode_p strongValue:(int)strongValue mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction;
-(AIKVPointer*) setNodePointerToDirectionIndex:(AIPort*)cmvNodePort mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction;


//根据mvAlgsType查找其抽象节点的node_p地址;
-(AIKVPointer*) getNodePointerFromDirectionIndex:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(NSInteger)limit;

@end


//MARK:===============================================================
//MARK:                     < AINetCMVIndexModel (一组index) >
//MARK:===============================================================
@interface AINetCMVIndexModel : NSObject

@property (strong,nonatomic) NSMutableArray *referencePorts;//所指向节点的地址和强度;(按引用数排序)(如吃饭,比吃苹果引用数高很多)
@property (strong,nonatomic) NSString *algsType;            //所属mv类型
@property (strong,nonatomic) NSString *dataSource;

@end
