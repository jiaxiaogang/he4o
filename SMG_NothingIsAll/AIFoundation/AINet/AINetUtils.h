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
//MARK:                     < insertPointer >
//MARK:===============================================================

/**
 *  MARK:--------------------二分插线到强度ports--------------------
 *  @param pointer  : 把这个插到ports
 *  @param ports    : 把pointer插到这儿;
 *  @param ps       : pointer是alg时,传alg.content_ps | pointer是fo时,传fo.orders; (用来计算md5.header)
 */
+(void) insertPointer:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps;
+(void) insertPointer:(AIPointer*)pointer toMemPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps;

/**
 *  MARK:--------------------插线到ports (分文件优化)--------------------
 *  @param pointerFileName : 指针序列文件名,如FILENAME_Reference_ByPointer
 *  @param portFileName : 强度序列文件名,如FILENAME_Reference_ByPort
 *
 *  1. 各种神经元中只保留"指针"和"类型";
 *  2. 其它absPorts,conPorts,refPorts都使用单独文件的方式;
 *  3. 暂不使用 (未完成)
 */
-(void) insertPointer:(AIKVPointer*)node_p target_p:(AIKVPointer*)target_p difStrong:(int)difStrong pointerFileName:(NSString*)pointerFileName portFileName:(NSString*)portFileName;


/**
 *  MARK:--------------------对微信息引用进行关联--------------------
 *  @desc               : 将algNode插线到value_ps的refPorts
 *  @param algNode_p    : 引用微信息的algNode
 *  @param value_ps     : 微信息组
 *  @param ps           : 生成md5的ps
 *  @param saveDB       : 存硬盘/内存神经网络;
 */
+(void) insertPointer:(AIPointer*)algNode_p toRefPortsByValues:(NSArray*)value_ps ps:(NSArray*)ps saveDB:(BOOL)saveDB;

/**
 *  MARK:--------------------对algNode引用进行关联--------------------
 *  @desc               : 将algNode插线到value_ps的refPorts
 *  @param foNode_p     : 引用algNode的foNode
 *  @param order_ps     : orders节点组
 *  @param ps           : 生成md5的ps
 */
+(void) insertPointer:(AIPointer*)foNode_p toRefPortsByOrders:(NSArray*)order_ps ps:(NSArray*)ps;


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
 *  @param saveDB   : 是否持久化到神经网络
 */
+(void) relateAbs:(AIAbsAlgNode*)absNode conNodes:(NSArray*)conNodes saveDB:(BOOL)saveDB;

@end
