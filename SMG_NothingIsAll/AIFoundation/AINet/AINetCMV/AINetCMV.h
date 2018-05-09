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
//MARK:                     < cmv基本模型节点 >
//MARK:===============================================================
@class AIKVPointer;
@interface AINetCMVNode : NSObject

@property (strong, nonatomic) NSMutableArray *algsArrOrder; //在imv前发生的noMV的algs数据序列;(前因序列)
@property (strong, nonatomic) AIKVPointer *cmvPointer;      //

@end
