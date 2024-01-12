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
 *  @act使用示例:
 *      本用法: Act0 act = ^(){ //执行代码 },使用时调用act();
 *      相当于: void(^act)() = ^(){ //执行代码 },使用时调用act();
 *  @func使用示例:
 *      本用法: Func1 func = ^(){return yourClass;};,使用时:YourClass yc = func();
 *      相当于: YourClass(^func)() = ^(){ return yourClass; },使用时:YourClass yc = func();
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
