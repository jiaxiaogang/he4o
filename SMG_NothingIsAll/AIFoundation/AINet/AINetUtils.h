//
//  AINetUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAbsAlgNode,AINetAbsFoNode,AIAbsCMVNode;
@interface AINetUtils : NSObject

//MARK:===============================================================
//MARK:                     < CanOutput >
//MARK:===============================================================

/**
 *  MARK:--------------------检查是否可以输出algsType&dataSource--------------------
 *  1. 有过输出记录,即可输出;
 */
+(BOOL) checkCanOutput:(NSString*)dataSource;


/**
 *  MARK:--------------------标记canout--------------------
 *  @param algsType     : 分区标识 (algsType不需要,因为都是Output)
 *  @param dataSource   : 算法标识
 */
+(void) setCanOutput:(NSString*)dataSource ;

//MARK:===============================================================
//MARK:                     < Other >
//MARK:===============================================================

/**
 *  MARK:--------------------检查value_ps指针isOut都是true--------------------
 */
+(BOOL) checkAllOfOut:(NSArray*)value_ps;

@end



@interface AINetUtils (Insert)

//MARK:===============================================================
//MARK:                     < 引用插线 (外界调用,支持alg/fo/mv) >
//MARK:===============================================================

/**
 *  MARK:--------------------概念_引用_微信息--------------------
 *  @desc               : 将algNode插线到value_ps的refPorts
 *  @param algNode_p    : 引用微信息的algNode
 *  @param value_ps     : 微信息组
 *  @param ps           : 生成md5的ps
 */
+(void) insertRefPorts_AllAlgNode:(AIPointer*)algNode_p value_ps:(NSArray*)value_ps ps:(NSArray*)ps;


/**
 *  MARK:--------------------时序_引用_概念--------------------
 *  @desc               : 将algNode插线到value_ps的refPorts
 *  @param foNode_p     : 引用algNode的foNode
 *  @param order_ps     : orders节点组
 *  @param ps           : 生成md5的ps
 */
+(void) insertRefPorts_AllFoNode:(AIPointer*)foNode_p order_ps:(NSArray*)order_ps ps:(NSArray*)ps;
+(void) insertRefPorts_AllFoNode:(AIPointer*)foNode_p order_p:(AIPointer*)order_p ps:(NSArray*)ps;


/**
 *  MARK:--------------------mv_引用_微信息--------------------
 *  @param difStrong    : mvNode的方向索引序列传urgent正相关值 / delta和urgent传1;
 *  @param value_p      : 有三种值; 1:delta 2:urgent 3:DirectionReference地址;
 *  注:目前在使用NetRefrence,所以此处不用;
 */
+(void) insertRefPorts_AllMvNode:(AIPointer*)mvNode_p value_p:(AIPointer*)value_p difStrong:(NSInteger)difStrong;



//MARK:===============================================================
//MARK:                     < 内存插线 >
//MARK:===============================================================

/**
 *  MARK:--------------------节点插到被引用信息上--------------------
 *  @param passiveRef_p : 此指针,被某节点引用;
 *  @param memNode_p    : 此节点,引用了某指针;
 *  @param ps           : algNode传content_ps,foNode传content_ps,而mv传nil;
 *  @param difStrong    : mvNode索引引用序列传迫切度正相关值,delta和urgent及别的微信息传1;
 *  1. 目前仅支持内存网络,硬盘网络在AIRefrAINetIndexReference.setRefresh()中;
 *  2. 微信息引用ports.header为空; (因为目前不需要)
 */
+(void) insertRefPorts_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p ps:(NSArray*)ps difStrong:(NSInteger)difStrong;
/**
 *  MARK:--------------------抽象插到具象上--------------------
 */
+(void) insertAbsPorts_MemNode:(AIPointer*)abs_p con_p:(AIPointer*)con_p absNodeContent:(NSArray*)absNodeContent;

/**
 *  MARK:--------------------具象插到抽象上--------------------
 */
+(void) insertConPorts_MemNode:(AIPointer*)con_p abs_p:(AIPointer*)abs_p conNodeContent:(NSArray*)conNodeContent;



//MARK:===============================================================
//MARK:                     < 通用 仅插线到ports >
//MARK:===============================================================

/**
 *  MARK:--------------------硬盘插线到强度ports序列--------------------
 *  @param pointer  : 把这个插到ports
 *  @param ports    : 把pointer插到这儿;
 *  @param ps       : pointer是alg时,传alg.content_ps | pointer是fo时,传fo.orders; (用来计算md5.header)
 */
+(void) insertPointer_Hd:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps;

/**
 *  MARK:--------------------内存插线到时间ports序列--------------------
 *  @param pointer  : 把这个插到ports
 *  @param memPorts : 把pointer插到这儿;
 *  @param ps       : pointer是alg时,传alg.content_ps | pointer是fo时,传fo.orders; (用来计算md5.header)
 *  注: 内存网络中,仅按时间排序,没有强度;
 */
+(void) insertPointer_Mem:(AIPointer*)pointer toPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps difStrong:(NSInteger)difStrong;


//MARK:===============================================================
//MARK:                     < 抽具象关联 Relate (外界调用,支持alg/fo) >
//MARK:===============================================================

/**
 *  MARK:--------------------关联抽具象概念--------------------
 *  @param absNode  : 抽象概念
 *  @param conNodes : 具象概念们
 *  注: 抽具象的difStrong默认都为1;
 */
+(void) relateAlgAbs:(AIAbsAlgNode*)absNode conNodes:(NSArray*)conNodes;
+(void) relateFoAbs:(AINetAbsFoNode*)absNode conNodes:(NSArray*)conNodes;
+(void) relateMvAbs:(AIAbsCMVNode*)absNode conNodes:(NSArray*)conNodes;

@end


//MARK:===============================================================
//MARK:                     < 转移 >
//MARK:===============================================================
@interface AINetUtils (Move)

+(id) move2HdNodeFromMemNode_Alg:(AINodeBase*)memNode;
+(id) move2HdNodeFromMemNode_Fo:(AINodeBase*)memNode;

@end
