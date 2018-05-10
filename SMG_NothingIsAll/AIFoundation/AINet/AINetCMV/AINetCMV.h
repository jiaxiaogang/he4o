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
@class AIKVPointer;
@interface AINetCMV : NSObject

-(void) create:(NSArray*)imvAlgsArr order:(NSArray*)order;

@end



//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
@class AIKVPointer;
@interface AINetCMVModel : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *algsArrOrder; //在imv前发生的noMV的algs数据序列;(前因序列)
@property (strong, nonatomic) AIKVPointer *cmvPointer;      //

@end



//MARK:===============================================================
//MARK:                     < cmv节点 >
//MARK:===============================================================
@class AIKVPointer;
@interface AINetCMVNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;             //自身存储地址
@property (strong, nonatomic) AIKVPointer *targetTypePointer;   //目标类型数据指针;(指向targetType的值存储地址)
@property (strong, nonatomic) AIKVPointer *urgentValuePointer;  //迫切度数据指针;(指向urgentValue的值存储地址)

@end
