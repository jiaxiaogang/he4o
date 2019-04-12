//
//  AINet.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIModel,AINode,AIImvAlgsModel,AIPointer,AIKVPointer,AIPort,AIFrontOrderNode,AINetAbsFoNode,AIAbsCMVNode,AIAlgNode,AIAbsAlgNode;
@interface AINet : NSObject

+(AINet*) sharedInstance;

//MARK:===============================================================
//MARK:                     < index >
//MARK:===============================================================
-(NSMutableArray*) getAlgsArr:(NSObject*)algsModel;  //装箱 (algsModel to indexPointerArr);
-(AIPointer*) getNetDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource;//单data装箱


//MARK:===============================================================
//MARK:                     < reference >
//MARK:===============================================================

/**
 *  MARK:--------------------引用序列--------------------
 *  @param indexPointer : value地址
 *  @param target_p : 引用者地址(如:xxNode.pointer)
 *
 *  注: 暂不支持output;
 */
-(void) setNetReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue;

//获取算法单结果的第二序列联想;
-(NSArray*) getNetReference:(AIKVPointer*)pointer limit:(NSInteger)limit;


//MARK:===============================================================
//MARK:                     < cmv >
//MARK:===============================================================
-(AIFrontOrderNode*) createCMV:(NSArray*)imvAlgsArr order:(NSArray*)order;


//MARK:===============================================================
//MARK:                     < absFo >
//MARK:===============================================================
-(AINetAbsFoNode*) createAbsFo_Outside:(AIFoNodeBase*)foA foB:(AIFoNodeBase*)foB orderSames:(NSArray*)orderSames;
-(AINetAbsFoNode*) createAbsFo_Inner:(AIFoNodeBase*)conFo orderSames:(NSArray*)orderSames;


//MARK:===============================================================
//MARK:                     < directionReference >
//MARK:===============================================================
-(AIPort*) getNetNodePointersFromDirectionReference_Single:(NSString*)mvAlgsType direction:(MVDirection)direction;
-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(int)limit;
-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction filter:(NSArray*(^)(NSArray*))filter;
-(void) setNetNodePointerToDirectionReference:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(int)difStrong;


//MARK:===============================================================
//MARK:                     < AINetOutputIndex >
//MARK:===============================================================

//小脑索引
-(AIKVPointer*) getOutputIndex:(NSString*)dataSource outputObj:(NSNumber*)outputObj;


//MARK:===============================================================
//MARK:                     < absCmv >
//MARK:===============================================================
-(AIAbsCMVNode*) createAbsCMVNode_Outside:(AIKVPointer*)absFo_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p;
-(AIAbsCMVNode*) createAbsCMVNode_Inner:(AIKVPointer*)absFo_p conMv_p:(AIKVPointer*)conMv_p;


//MARK:===============================================================
//MARK:                     < algNode >
//MARK:===============================================================
-(AIAlgNode*) createAlgNode:(NSArray*)algsArr isOut:(BOOL)isOut;

//外类比调用
-(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)algSames algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB;

//内类比调用
-(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps alg:(AIAlgNode*)alg;

//获取绝对匹配到value_ps的algNode (祖母引用联想的方式去重)
-(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p;
-(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps exceptAlg_p:(AIPointer*)exceptAlg_p;

@end


