//
//  AIFoNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------时序节点基类--------------------
 *  @name 前因序列
 *  1. 是frontOrderNode和absNode的基类;
 */
@interface AIFoNodeBase : AINodeBase

/**
 *  MARK:--------------------cmvNode_p结果--------------------
 *  @desc 指向mv基本模型的价值影响节点;
 */
@property (strong, nonatomic) AIKVPointer *cmvNode_p;

/**
 *  MARK:--------------------生物钟时间间隔记录--------------------
 *  @desc
 *      1. 功能: 用于记录时序中,每元素间的生物钟间隔 (单位:s);
 *      2. 比如: [我,打,豆豆]->{mv+},记录成deltaTime后为[0,1,100,0];
 *      3. 表示: 我用1ms打了,100ms豆豆,0ms内就感受到了爽;
 *      4. 首位: 首位总是0,因为本序列采用了首位参照,所以为0;
 *  @deltaTimes元素有可能为0的情况;
 *      1. 首位为0;
 *      2. 末位为N或L时,为0 (因为N和L抽象自frontAlg);
 *      3. isOut=true时,为0,比如反射反应触发"吃",是即时触发的,自然是0;
 *  _result 2021.12.26: 传入index,取出的结果为:"从index-1到index的时间";
 */
@property (strong, nonatomic) NSMutableArray *deltaTimes;
@property (assign, nonatomic) NSTimeInterval mvDeltaTime;

/**
 *  MARK:--------------------SP强度值--------------------
 *  @desc <key:spIndex, value:spStrong> (其中mv的key为content.count) (参考25031-3);
 */
@property (strong, nonatomic) NSMutableDictionary *spDic;

/**
 *  MARK:--------------------有效率--------------------
 *  @desc <key:effectIndex, value:effectStrong> (其中mv的key为content.count) (参考26094);
 */
@property (strong, nonatomic) NSMutableDictionary *effectDic;

/**
 *  MARK:--------------------指向抽/具象indexDic的持久化--------------------
 *  @desc <K:指向的PId, V:与指向fo的indexDic映射> (其中indexDic为<K:absIndex,V:conIndex>);
 */
@property (strong, nonatomic) NSMutableDictionary *absIndexDDic;
@property (strong, nonatomic) NSMutableDictionary *conIndexDDic;


//MARK:===============================================================
//MARK:                     < spDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新SP强度值--------------------
 *  @param spIndex : 当前要更新sp强度值的下标 (参考25031-3);
 *                    1. 表示责任帧下标,比如为1时,则表示第2帧的责任;
 *                    2. 如果是mv则输入content.count;
 */
-(void) updateSPStrong:(NSInteger)spIndex type:(AnalogyType)type;


//MARK:===============================================================
//MARK:                     < effectDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新有效率值--------------------
 *  @version
 *      2022.05.27; 废弃,eff改成反省的一种了,所以不再需要effDic了 (参考26127-TODO1);
 */
-(void) updateEffectStrong:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo status:(EffectStatus)status;

/**
 *  MARK:--------------------取effIndex下有效的Effs--------------------
 */
-(NSArray*) getValidEffs:(NSInteger)effIndex;


//MARK:===============================================================
//MARK:                     < indexDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------返回self的抽/具象的indexDic--------------------
 */
-(NSDictionary*) getIndexDic:(AIKVPointer*)other_p isAbs:(BOOL)isAbs;

/**
 *  MARK:--------------------获取cutIndex--------------------
 */
-(NSInteger) getCutIndexByIndexDic:(AIKVPointer*)other_p isAbs:(BOOL)isAbs;

@end
