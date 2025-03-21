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
@class HEResult,TOFoModel;
@interface AIFoNodeBase : AINodeBase

/**
 *  MARK:--------------------迁移关联V2 (当前为F继承的I端口) (参考29069-todo10.2 & 33112-TODO4.4)--------------------
 *  @desc 工作在场景fo下,在cansetFo下不工作 (这个数据存在sceneFo中,而不是cansetFo);
 */
@property (strong, nonatomic) NSMutableArray *transferIPorts;

/**
 *  MARK:--------------------迁移关联V2 (当前为I推举的F端口) (参考29069-todo10.2 & 33112-TODO4.4)--------------------
 *  @desc 工作在场景fo下,在cansetFo下不工作 (这个数据存在sceneFo中,而不是cansetFo);
 *  @desc 因为现在I层Canset都废弃了，所以这个必须保持存在IFScene下，不要想着移到canset下来。
 */
@property (strong, nonatomic) NSMutableArray *transferFPorts;

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
-(void) updateSPStrong:(NSInteger)spIndex type:(AnalogyType)type caller:(NSString*)caller;
-(void) updateSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type caller:(NSString*)caller;

/**
 *  MARK:--------------------从start到end都计一次S或P--------------------
 */
-(void) updateSPStrong:(NSInteger)start end:(NSInteger)end type:(AnalogyType)type caller:(NSString*)caller;

/**
 *  MARK:--------------------更新整个spDic--------------------
 */
-(void) updateSPDic:(NSDictionary*)newSPDic;


//MARK:===============================================================
//MARK:                     < outSPDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------OutSP强度值--------------------
 *  @desc <key:cansetTo的元素字符串的md5值, value:<vk:spIndex下标, vv:spStrong>> (参考33062-TODO2 & 33065-TODO1);
 *  @desc outSPDic存在每个sceneTo下,k为cansetTo,v为它在这个sceneTo下对应的itemSPDic;
 *  @version
 *      2025.03.08: 从存在Scene下，改为存到F层Canset下（参考33172-方案3）。
 */
@property (strong, nonatomic) NSMutableDictionary *outSPDic;

/**
 *  MARK:--------------------更新OutSPDic强度值--------------------
 */
-(void) updateOutSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type baseSceneToContent_ps:(NSArray*)baseSceneToContent_ps debugMode:(BOOL)debugMode caller:(NSString*)caller;
-(BOOL) containsOutSPStrong:(NSArray*)baseSceneContent_ps;

/**
 *  MARK:--------------------由sceneFo调用,返回canset对应的itemOutSPDic--------------------
 */
-(NSDictionary*) getItemOutSPDic:(NSString*)baseSceneOutSPKey;


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
 *  MARK:--------------------从startIndex（含）开始取所有cansets--------------------
 */
-(NSArray*) getConCansetsWithStartIndex:(NSInteger)startIndex;

/**
 *  MARK:--------------------更新一条候选--------------------
 */
-(HEResult*) updateConCanset:(AIKVPointer*)newConCansetFo targetIndex:(NSInteger)targetIndex;

/**
 *  MARK:--------------------将当前fo解析成orders返回--------------------
 */
-(NSArray*) convert2Orders;

//@property (strong, nonatomic) NSMutableDictionary *debugSPMinXiLog;

@end
