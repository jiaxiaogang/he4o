//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINode,AIImvAlgsModel,AIPointer,AIKVPointer,AIPort,AIFrontOrderNode,AINetAbsFoNode,AIAbsCMVNode,AIAlgNode,AIAbsAlgNode,AIAlgNodeBase;
@interface AINet : NSObject

+(AINet*) sharedInstance;

//MARK:===============================================================
//MARK:                     < index >
//MARK:===============================================================

/**
 *  MARK:--------------------算法模型的装箱--------------------
 *  转为指针数组(每个值都是指针)(在dataIn后第一件事就是装箱)
 *  @result notnull
 */
-(NSMutableArray*) algModelConvert2Pointers:(NSDictionary*)modelDic algsType:(NSString*)algsType;
-(AIPointer*) getNetDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource;//单data装箱


//MARK:===============================================================
//MARK:                     < reference >
//MARK:===============================================================

/**
 *  MARK:--------------------引用序列--------------------
 *  @param indexPointer : value地址
 *  @param target_p : 引用者地址(如:xxNode.pointer)
 *
 *  注:
 *  1. 暂不支持output;
 *  2. 由AINetUtils.insertRefPorts_AllMvNode()取代
 */
//-(void) setNetReference:(AIKVPointer*)value_p target_p:(AIKVPointer*)target_p difValue:(int)difValue;

//获取算法单结果的第二序列联想;
-(NSArray*) getNetReference:(AIKVPointer*)pointer limit:(NSInteger)limit;


//MARK:===============================================================
//MARK:                     < cmv >
//MARK:===============================================================
-(AIFrontOrderNode*) createCMV:(NSArray*)imvAlgsArr order:(NSArray*)order;


//MARK:===============================================================
//MARK:                     < conFo >
//MARK:===============================================================
-(AIFrontOrderNode*) createConFo:(NSArray*)order_ps;

//MARK:===============================================================
//MARK:                     < absFo >
//MARK:===============================================================
-(AINetAbsFoNode*) createAbsFo_Outside:(AIFoNodeBase*)foA foB:(AIFoNodeBase*)foB orderSames:(NSArray*)orderSames;
-(AINetAbsFoNode*) createAbsFo_Inner:(AIFoNodeBase*)conFo orderSames:(NSArray*)orderSames;


//MARK:===============================================================
//MARK:                     < directionReference >
//MARK:===============================================================
-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem limit:(int)limit;
-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem filter:(NSArray*(^)(NSArray *protoArr))filter;

/**
 *  MARK:--------------------mvNode的方向索引--------------------
 *  @param difStrong    : mv的迫切度越高,越强;
 *  @param cmvNode      : cmvNode有可能还在create阶段,未存硬盘,所以不能传指针进来;
 */
-(void) setMvNodeToDirectionReference:(AICMVNodeBase*)cmvNode difStrong:(NSInteger)difStrong;


//MARK:===============================================================
//MARK:                     < AINetOutputIndex >
//MARK:===============================================================

//小脑索引
-(AIKVPointer*) getOutputIndex:(NSString*)algsType outputObj:(NSNumber*)outputObj;


//MARK:===============================================================
//MARK:                     < absCmv >
//MARK:===============================================================
-(AIAbsCMVNode*) createAbsCMVNode_Outside:(AIKVPointer*)absFo_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p;
-(AIAbsCMVNode*) createAbsCMVNode_Inner:(AIKVPointer*)absFo_p conMv_p:(AIKVPointer*)conMv_p;


//MARK:===============================================================
//MARK:                     < algNode >
//MARK:===============================================================

/**
 *  MARK:--------------------创建概念节点--------------------
 *  将微信息组,转换成概念节点;
 *  需要对概念节点指定当前的isOut状态; (思维控制器知道它是行为还是认知)
 *  @result notnull
 */
-(AIAlgNode*) createAlgNode:(NSArray*)algsArr isOut:(BOOL)isOut isMem:(BOOL)isMem;
-(AIAlgNode*) createAlgNode:(NSArray*)algsArr dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem;


/**
 *  MARK:--------------------构建抽象概念--------------------
 *  1. 内类比调用 & 外类比调用 (存硬盘)
 *  2. thinkIn调用 (存内存)
 */
-(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem;
-(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs dataSource:(NSString*)dataSource isMem:(BOOL)isMem;

@end
