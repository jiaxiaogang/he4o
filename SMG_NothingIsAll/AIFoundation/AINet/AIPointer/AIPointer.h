//
//  AIPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------"数据指针"--------------------
 *  1. 可以指向任何表的任一项;
 *  2. 指针的字段,是为指针的使用者而设的;例如A有B的指针,则需要B指针描述B的确切位置;
 */
@interface AIPointer : NSObject <NSCoding>

@property (assign, nonatomic) NSInteger pointerId;          //指针地址(Id)
@property (strong, nonatomic) NSMutableDictionary *params;  //用于分区(在二分查巨量队列,params越细分,越有利性能)

@end
