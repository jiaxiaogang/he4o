//
//  AINetCMV.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < 杏仁核 >
//MARK:===============================================================
@class AIKVPointer,AINetCMVModel;
@protocol AINetCMVDelegate <NSObject>


/**
 *  MARK:--------------------新的微信息被引用,报告引用--------------------
 *  @param indexPointer : 微信息值的指针;
 *  @param nodePointer : 宏节点的指针;
 */
-(void) aiNetCMV_CreatedNode:(AIKVPointer*)indexPointer nodePointer:(AIKVPointer*)nodePointer;

/**
 *  MARK:--------------------cmvNode或absCMVNode构建时,报告directionReference--------------------
 *  @param difStrong : mv的迫切度越高,越强;
 *  @param direction : 方向(delta的正负)
 */
-(void) aiNetCMV_CreatedCMVNode:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(NSInteger)difStrong;

@end




@interface AINetCMV : NSObject

@property (weak, nonatomic) id<AINetCMVDelegate> delegate;
-(AINetCMVModel*) create:(NSArray*)imvAlgsArr order:(NSArray*)order;

@end




//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
@interface AINetCMVModel : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;         //自身存储地址
@property (strong, nonatomic) AIKVPointer *foNode_p;      //前因数据
@property (strong, nonatomic) AIKVPointer *cmvNode_p;      //

-(void) create;

@end
