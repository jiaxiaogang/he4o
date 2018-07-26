//
//  AINetAbsNode.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < AbsNode类(抽象神经元(多级和双级合并)) >
//MARK:===============================================================
@class AIKVPointer;
@interface AINetAbsNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;
@property (strong, nonatomic) NSMutableArray *conPorts; //具象关联端口
@property (strong, nonatomic) AIKVPointer *absValue_p;  //微信息组
@property (strong, nonatomic) AIKVPointer *absCmvNode_p;//抽象cmv指向;

-(void) print;

@end
