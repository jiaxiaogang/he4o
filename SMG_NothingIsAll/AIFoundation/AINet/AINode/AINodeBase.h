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
 *  @todo
 *      1. 需要将analogyType转为的ds,改为独立的type属性;
 *          > 比如GL类型的Alg节点,其at是稀疏码的皮层算法名(如size),但而ds则是analogyType转来,这导致皮层算法区名未被纳入(如AIVersionAlgs);
 *          > 如果有一天,视区和声区,都有一个叫"size"的算法,则会混乱;
 */
@interface AINodeBase : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身存储地址
@property (strong, nonatomic) NSMutableArray *conPorts; //具象关联端口
@property (strong, nonatomic) NSMutableArray *absPorts; //抽象方向的端口;

/**
 *  MARK:--------------------组端口--------------------
 *  @desc : 组分关联的 "组";
 *  1. 用于fo: 在imv前发生的noMV的algs数据序列;(前因序列)(使用kvp而不是port的原因是cmvModel的强度不变:参考n12p16)
 *  2. 用于alg: 稀疏码微信息组;(微信息/嵌套概念)指针组 (以pointer默认排序) (去重,否则在局部识别全含时,判定content.count=matchingCount时会失效)
 *  @version
 *      2022.12.25: 将content_ps改成contentPorts (参考2722f-todo11);
 */
@property (strong, nonatomic,nonnull) NSMutableArray *contentPorts;
-(NSMutableArray *)content_ps;
-(void) setContent_ps:(NSArray*)content_ps;
-(void) setContent_ps:(NSArray*)content_ps getStrongBlock:(NSInteger(^)(AIKVPointer *item_p))getStrongBlock;

/**
 *  MARK:--------------------返回content长度--------------------
 */
-(NSInteger) count;
-(AIKVPointer*) p;
-(NSInteger) pId;

//MARK:===============================================================
//MARK:                     < 匹配度 (支持: 概念,时序) >
//MARK:===============================================================

//当时序时,匹配度为整个indexDic抽具象映射的综合匹配度,目前不支持根据cutIndex计算一部分的匹配度,如果需要这么计算,可以使用[AINetUtils getMatchFo:indexDic]计算时序一部分映射的匹配度;
@property (strong, nonatomic) NSMutableDictionary *absMatchDic; //抽象匹配度字典 <K:对方pId, V:相似度> (参考27153-todo2);
@property (strong, nonatomic) NSMutableDictionary *conMatchDic; //具象匹配度字典 <K:对方pId, V:相似度> (参考27153-todo2);

/**
 *  MARK:--------------------更新抽具象相似度--------------------
 *  @param absAlg : 传抽象节点进来,而self为具象节点;
 */
-(void) updateMatchValue:(AINodeBase*)absAlg matchValue:(CGFloat)matchValue;

/**
 *  MARK:--------------------取抽或具象的相近度--------------------
 */
-(CGFloat) getConMatchValue:(AIKVPointer*)con_p;
-(CGFloat) getAbsMatchValue:(AIKVPointer*)abs_p;

@end
