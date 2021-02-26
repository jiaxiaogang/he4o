//
//  XGDelegate.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/2/26.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------使用说明--------------------
 *  1. 直接使用Act0 act = ^(){ //执行代码 },使用时调用act();
 *  2. 使用void(^act)() = ^(){ //执行代码 },使用时调用act();
 */

typedef void (^Act0)();
typedef void (^Act1)(id p1);
typedef void (^Act2)(id p2);
typedef void (^Act3)(id p3);
typedef void (^Act4)(id p4);

typedef id (^Func0)();
typedef id (^Func1)(id p1);
typedef id (^Func2)(id p2);
typedef id (^Func3)(id p3);
typedef id (^Func4)(id p4);
