//
//  AIAbsCMVNode.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < AIAbsCMVNode >
//MARK:===============================================================
@interface AIAbsCMVNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身地址
@property (strong, nonatomic) AIKVPointer *urgentTo_p;  //迫切度数据指针;(指向urgentValue的值存储地址)
@property (strong, nonatomic) AIKVPointer *delta_p;     //变化指针;(指向变化值存储地址)
@property (strong, nonatomic) NSMutableArray *conPorts; //具象方向端口;
@property (strong, nonatomic) AIKVPointer *absNode_p;   //前因节点

@end
