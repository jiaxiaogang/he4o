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
@class AIEffectStrong,HEResult;
@interface AIFoNodeBase : AINodeBase

/**
 *  MARK:--------------------迁移关联 (上传) (参考29069-todo10.2)--------------------
 *  @desc 工作在场景fo下,在cansetFo下不工作;
 */
@property (strong, nonatomic) NSMutableArray *transferFromPorts;

/**
 *  MARK:--------------------迁移关联 (下承) (参考29069-todo10.2)--------------------
 *  @desc 工作在场景fo下,在cansetFo下不工作;
 */
@property (strong, nonatomic) NSMutableArray *transferToPorts;

/**
 *  MARK:--------------------cmvNode_p结果--------------------
 *  @desc 指向mv基本模型的价值影响节点;
 */
@property (strong, nonatomic) AIKVPointer *cmvNode_p;


//MARK:===============================================================
//MARK:                     < deltaTimes组 >
//MARK:===============================================================

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


//MARK:===============================================================
//MARK:                     < spDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------SP强度值--------------------
 *  @desc <key:spIndex, value:spStrong> (其中mv的key为content.count) (参考25031-3);
 */
@property (strong, nonatomic) NSMutableDictionary *spDic;

/**
 *  MARK:--------------------更新SP强度值--------------------
 *  @param spIndex : 当前要更新sp强度值的下标 (参考25031-3);
 *                    1. 表示责任帧下标,比如为1时,则表示第2帧的责任;
 *                    2. 如果是mv则输入content.count;
 */
-(void) updateSPStrong:(NSInteger)spIndex type:(AnalogyType)type;
-(void) updateSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type;

/**
 *  MARK:--------------------从start到end都计一次S或P--------------------
 */
-(void) updateSPStrong:(NSInteger)start end:(NSInteger)end type:(AnalogyType)type;

/**
 *  MARK:--------------------更新整个spDic--------------------
 */
-(void) updateSPDic:(NSDictionary*)newSPDic;


//MARK:===============================================================
//MARK:                     < outSPDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------OutSP强度值--------------------
 *  @desc <key:sceneFromPId_cansetFromPId, value:outSPStrong> (参考32012-TODO2);
 *  @desc outSPDic存在每个sceneTo下,k为sceneFrom_cansetFrom,v为它在这个sceneTo下对应的spDic;
 */
@property (strong, nonatomic) NSMutableDictionary *outSPDic;

/**
 *  MARK:--------------------初始化整个outSPDic (参考32012-TODO3)--------------------
 */
-(void) initItemOutSPDicIfNotInited:(AIKVPointer*)sceneFrom cansetFrom:(AIKVPointer*)cansetFrom;

/**
 *  MARK:--------------------更新OutSPDic强度值--------------------
 */
-(void) updateOutSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type sceneFrom:(AIKVPointer*)sceneFrom cansetFrom:(AIKVPointer*)cansetFrom debugMode:(BOOL)debugMode caller:(NSString*)caller;

/**
 *  MARK:--------------------更新整个outSPDic--------------------
 */
-(void) updateOutSPDic:(NSDictionary*)newSPDic sceneFrom:(AIKVPointer*)sceneFrom cansetFrom:(AIKVPointer*)cansetFrom;

/**
 *  MARK:--------------------获取某条outSPDic--------------------
 */
-(NSDictionary*) getItemOutSPDic:(AIKVPointer*)sceneFrom cansetFrom:(AIKVPointer*)cansetFrom;

//MARK:===============================================================
//MARK:                     < effectDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------有效率--------------------
 *  @desc <key:effectIndex, value:effectStrong> (其中mv的key为content.count) (参考26094);
 *  @status 用的较少,以下在使用:
 *          1. TCRefrection.refrection()
 *          2. AIRank.cansetsRankingV4()
 *  @todo
 *      2022.11.23: 待废除 (参考27205);
 *          补充正据: 不建议废除,从定义上来看,eff主外,sp主内,sp并不能表达eff对场景的明确指向,所以二者看似一样,但并不一样 (但在当前的设计中,canset只服务一个scene,所以它不明确也是明确);
 *          补充反据: 可考虑废除,因为现在每个场景下的cansets是隔离的,它的防重范围也是scene下,所以即使一模一样的canset在不同的scene下,也会各生成各的,各统计各的SPEFF,这会导致EFF没意义,用SP乘积完全可以替代;
 */
@property (strong, nonatomic) NSMutableDictionary *effectDic;

/**
 *  MARK:--------------------更新有效率值--------------------
 */
-(AIEffectStrong*) updateEffectStrong:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo status:(EffectStatus)status;

/**
 *  MARK:--------------------获取canset的effStrong--------------------
 */
-(AIEffectStrong*) getEffectStrong:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo;

/**
 *  MARK:--------------------取effIndex下有效的Effs--------------------
 */
-(NSArray*) getValidEffs:(NSInteger)effIndex;


//MARK:===============================================================
//MARK:                     < indexDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------指向抽/具象indexDic的持久化--------------------
 *  @desc <K:指向的PId, V:与指向fo的indexDic映射> (其中indexDic为<K:absIndex,V:conIndex>);
 */
@property (strong, nonatomic) NSMutableDictionary *absIndexDDic;
@property (strong, nonatomic) NSMutableDictionary *conIndexDDic;

/**
 *  MARK:--------------------返回self的抽/具象的indexDic--------------------
 */
-(NSDictionary*) getAbsIndexDic:(AIKVPointer*)abs_p;
-(NSDictionary*) getConIndexDic:(AIKVPointer*)con_p;

/**
 *  MARK:--------------------更新抽具象indexDic存储--------------------
 */
-(void) updateIndexDic:(AIFoNodeBase*)absFo indexDic:(NSDictionary*)indexDic;


//MARK:===============================================================
//MARK:                     < conCansets组 >
//MARK:===============================================================

/**
 *  MARK:--------------------S候选集--------------------
 *  @desc 在proto发生完全时,将它记录到此处,在sulution求解时,取做S候选集;
 *  @desc 来源:
 *          1. 末尾帧: R任务的解决方案来源,是源于TI阶段预测pFo未发生时,认为当时真实发生的事肯定有所帮助,所以才没发生,所以将其记录在此;
 *          2. 中间帧: H任务的解决方案来源,是源于在行为化后,它真实有效时,抽象出H帧的解决方案,并记录在此;
 *  @version
 *      2022.11.23: 将conCansets更新成conCansetsDic (参考;
 *  @result 类型: <K:targetIndex, V: List<AIKVPointer>> 注: 当targetIndex=self.count时,则为R任务的解决方案候选集;
 */
@property (strong, nonatomic) NSMutableDictionary *conCansetsDic;

/**
 *  MARK:--------------------获取所有候选集--------------------
 */
-(NSArray*) getConCansets:(NSInteger)targetIndex;

/**
 *  MARK:--------------------更新一条候选--------------------
 */
-(HEResult*) updateConCanset:(AIKVPointer*)newConCansetFo targetIndex:(NSInteger)targetIndex;

//MARK:===============================================================
//MARK:                     < transfer组 >
//MARK:===============================================================

/**
 *  MARK:--------------------找出从sceneFrom已经迁移过来了哪些cansetFroms (由sceneTo调用)--------------------
 */
-(NSArray*) getTransferedCansetFroms:(AIKVPointer*)sceneFrom_p;

/**
 *  MARK:--------------------找出sceneTo的哪些cansetTos是self迁移过去的 (由sceneFrom调用)--------------------
 */
-(NSArray*) getTransferedCansetTos:(AIKVPointer*)sceneTo_p;

/**
 *  MARK:--------------------将当前fo解析成orders返回--------------------
 */
-(NSArray*) convert2Orders;

@end
