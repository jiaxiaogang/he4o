//
//  AICMVNode.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < AINode之: cmv节点 >
//MARK:===============================================================
@interface AICMVNode : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身存储地址
@property (strong, nonatomic) AIKVPointer *urgentTo_p;  //迫切度数据指针;(指向urgentValue的值存储地址)
@property (strong, nonatomic) AIKVPointer *delta_p;     //变化指针;(指向变化值存储地址)
@property (strong, nonatomic) AIKVPointer *cmvModel_p;//被引用的cmvModel;
@property (strong, nonatomic) NSMutableArray *absPorts; //抽象方向的端口;

@end
