//
//  AINodeBase.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------节点基类--------------------
 *  1. 有指针地址;
 *  2. 可被抽象;
 */
@interface AINodeBase : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身存储地址
@property (strong, nonatomic) NSMutableArray *absPorts; //抽象方向的端口;

/**
 *  MARK:--------------------组端口--------------------
 *  @desc : 组分关联的 "组";
 *  1. 用于fo: 在imv前发生的noMV的algs数据序列;(前因序列)(使用kvp而不是port的原因是cmvModel的强度不变:参考n12p16)
 *  2. 用于alg: 稀疏码微信息组;(微信息/嵌套概念)指针组 (以pointer默认排序)
 */
@property (strong, nonatomic) NSMutableArray *content_ps;

/**
 *  MARK:--------------------返回所有absPorts--------------------
 *  @desc memAbsPorts + hdAbsPorts;
 */
-(NSMutableArray *)absPorts_All;

/**
 *  MARK:--------------------取absPorts--------------------
 *  @param saveDB : true则返回absPorts | false则返回memAbsPorts
 *  @return notnull
 */
//-(NSMutableArray *)absPorts:(BOOL)saveDB;

@end
