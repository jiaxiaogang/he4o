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

-(void) aiNetCMV_CreatedNode:(AIKVPointer*)indexPointer nodePointer:(AIKVPointer*)nodePointer;

@end

@interface AINetCMV : NSObject

@property (weak, nonatomic) id<AINetCMVDelegate> delegate;
-(AINetCMVModel*) create:(NSArray*)imvAlgsArr order:(NSArray*)order;

@end





//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
@interface AINetCMVModel : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;             //自身存储地址
@property (strong, nonatomic) NSMutableArray *orders_kvp; //在imv前发生的noMV的algs数据序列;(前因序列)(使用kvp而不是port的原因是cmvModel的强度不变:参考n12p16)
@property (strong, nonatomic) AIKVPointer *cmvPointer;      //

-(void) create;

@end





//MARK:===============================================================
//MARK:                     < AINode之: cmv节点 >
//MARK:===============================================================
@interface AICMVNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;             //自身存储地址
@property (strong, nonatomic) AIKVPointer *targetTypePointer;   //目标类型数据指针;(指向targetType的值存储地址)
@property (strong, nonatomic) AIKVPointer *urgentValuePointer;  //迫切度数据指针;(指向urgentValue的值存储地址)

@end


//MARK:===============================================================
//MARK:                     < AINode之: 前因序列_节点 >
//MARK:===============================================================
@interface AIFrontOrderNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;             //自身存储地址
@property (strong, nonatomic) AIKVPointer *data_kvp;            //前因数据
@property (strong, nonatomic) AIKVPointer *cmvModel_kvp;        //被引用的cmvModel;

@end
