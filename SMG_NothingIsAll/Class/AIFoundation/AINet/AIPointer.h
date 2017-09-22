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
 *  1,可以指向任何表的任一项;
 */
@interface AIPointer : NSObject <NSCoding>

/**
 *  MARK:-------------------取指向的数据--------------------
 */
-(NSInteger) pointerId;

@end
