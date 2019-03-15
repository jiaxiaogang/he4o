//
//  AINodeBase.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------节点基类--------------------
 *  1. 有指针地址;
 *  2. 可被抽象;
 */
@interface AINodeBase : NSObject <NSCoding>

@property (strong, nonatomic) AIKVPointer *pointer;     //自身存储地址
@property (strong, nonatomic) NSMutableArray *absPorts; //抽象方向的端口;

@end
