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
 *  2,形成"神经网络"的网络线
 *  3,自带强度及衰减强化策略
 *  4,单独存表
 *  5,销毁时,通知GC;GC去回收已经没有指向的数据;
 */
@class AIPointerStrong;
@interface AIPointer : NSObject 

+(AIPointer*) initWithClass:(Class)pC withId:(NSInteger)pI ;

@property (strong,nonatomic) NSString *pClass;    //指针类型
@property (assign, nonatomic) NSInteger pId;  //指针地址(Id)
@property (strong,nonatomic) AIPointerStrong *strong;   //网络强度


@end
