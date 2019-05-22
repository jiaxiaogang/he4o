//
//  AINetUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAbsAlgNode;
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
//MARK:                     < 对 (祖母/时序) 引用关联 (数组) >
//MARK:===============================================================

/**
 *  MARK:--------------------祖母_引用_微信息--------------------
 *  @desc               : 将algNode插线到value_ps的refPorts
 *  @param algNode_p    : 引用微信息的algNode
 *  @param value_ps     : 微信息组
 *  @param ps           : 生成md5的ps
 */
+(void) insertPointer_AllAlgNode:(AIPointer*)algNode_p value_ps:(NSArray*)value_ps ps:(NSArray*)ps;

/**
 *  MARK:--------------------时序_引用_祖母--------------------
 *  @desc               : 将algNode插线到value_ps的refPorts
 *  @param foNode_p     : 引用algNode的foNode
 *  @param order_ps     : orders节点组
 *  @param ps           : 生成md5的ps
 */
+(void) insertPointer_AllFoNode:(AIPointer*)foNode_p order_ps:(NSArray*)order_ps ps:(NSArray*)ps;
+(void) insertPointer_AllFoNode:(AIPointer*)foNode_p order_p:(AIPointer*)order_p ps:(NSArray*)ps;


//MARK:===============================================================
//MARK:                     < 对 (内存) 引用关联 (单个) >
//MARK:===============================================================

/**
 *  MARK:--------------------memNode_p_引用_passiveRef_p--------------------
 *  @param passiveRef_p     : 此指针,被某节点引用;
 *  @param memNode_p    : 此节点,引用了某指针;
 *  1. 目前仅支持内存网络,硬盘网络在AIRefrAINetIndexReference.setRefresh()中;
 *  2. 微信息引用ports.header为空; (因为目前不需要)
 */
+(void) insertPointer_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p;
+(void) insertPointer_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p ps:(NSArray*)ps;


//MARK:===============================================================
//MARK:                     < 仅插线 到 ports >
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
 */
+(void) insertPointer_Mem:(AIPointer*)pointer toPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps;


//MARK:===============================================================
//MARK:                     < Other >
//MARK:===============================================================

/**
 *  MARK:--------------------检查value_ps指针isOut都是true--------------------
 */
+(BOOL) checkAllOfOut:(NSArray*)value_ps;


//MARK:===============================================================
//MARK:                     < Relate >
//MARK:===============================================================

/**
 *  MARK:--------------------关联抽具象祖母--------------------
 *  @param absNode  : 抽象祖母
 *  @param conNodes : 具象祖母们
 */
+(void) relateAbs:(AIAbsAlgNode*)absNode conNodes:(NSArray*)conNodes;

@end
