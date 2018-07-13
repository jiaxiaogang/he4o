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




//MARK:===============================================================
//MARK:                     < AINode之: cmv节点 >
//MARK:===============================================================
@interface AICMVNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身存储地址
@property (strong, nonatomic) AIKVPointer *urgentTo_p;  //迫切度数据指针;(指向urgentValue的值存储地址)
@property (strong, nonatomic) AIKVPointer *delta_p;     //变化指针;(指向变化值存储地址)
@property (strong, nonatomic) AIKVPointer *cmvModel_kvp;//被引用的cmvModel;
@property (strong, nonatomic) NSMutableArray *absPorts; //抽象方向的端口;

@end




//MARK:===============================================================
//MARK:                     < AINode之: 前因序列_节点 >
//MARK:===============================================================
@interface AIFrontOrderNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;             //自身存储地址
@property (strong, nonatomic) NSMutableArray *orders_kvp;       //在imv前发生的noMV的algs数据序列;(前因序列)(使用kvp而不是port的原因是cmvModel的强度不变:参考n12p16)
@property (strong, nonatomic) AIKVPointer *cmvModel_kvp;        //被引用的cmvModel;
@property (strong, nonatomic) NSMutableArray *absPorts;         //抽象插口

@end




//MARK:===============================================================
//MARK:                     < AIAbsCMVNode >
//MARK:===============================================================
@interface AIAbsCMVNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身地址
@property (strong, nonatomic) AIKVPointer *urgentTo_p;  //迫切度数据指针;(指向urgentValue的值存储地址)
@property (strong, nonatomic) AIKVPointer *delta_p;     //变化指针;(指向变化值存储地址)
@property (strong, nonatomic) NSMutableArray *conPorts; //具象方向端口;

@end
