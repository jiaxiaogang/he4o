//
//  AIAlgsPointer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/1/28.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

/**
 *  MARK:--------------------output记录数据的指针--------------------
 *  1. 根据此指针,可以直接调用到指定输出算法,并将指针下的内容输出;
 *  2. 输出指针可直接
 */
@interface AIOutputKVPointer : AIPointer

@property (strong,nonatomic) NSString *dataTo;    //算法名

@end
