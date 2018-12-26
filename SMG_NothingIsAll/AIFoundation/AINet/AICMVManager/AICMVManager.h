//
//  AICMVManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
@class AIKVPointer,AIFrontOrderNode;
@protocol AICMVManagerDelegate <NSObject>


/**
 *  MARK:--------------------新的微信息被引用,报告引用--------------------
 *  @param indexPointer : 微信息值的指针;
 *  @param nodePointer : 宏节点的指针;
 */
-(void) aiNetCMV_CreatedNode:(AIPointer*)indexPointer nodePointer:(AIKVPointer*)nodePointer;

/**
 *  MARK:--------------------cmvNode或absCMVNode构建时,报告directionReference--------------------
 *  @param difStrong : mv的迫切度越高,越强;
 *  @param direction : 方向(delta的正负)
 */
-(void) aiNetCMV_CreatedCMVNode:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(NSInteger)difStrong;

@end



/**
 *  MARK:--------------------foNode->cmvNode的模型--------------------
 */
@interface AICMVManager : NSObject

@property (weak, nonatomic) id<AICMVManagerDelegate> delegate;

/**
 *  MARK:--------------------create foNode->cmvNode 基本模型--------------------
 *  @param imvAlgsArr : imv此次输入信息
 *  @param order : 瞬时记忆序列
 *  @result : 返回foNode;
 */
-(AIFrontOrderNode*) create:(NSArray*)imvAlgsArr order:(NSArray*)order;

@end
