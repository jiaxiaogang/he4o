//
//  AIMainThread.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------智能主线程--------------------
 *  	• 智能分配cpu
 *          ○ 1,在计算某数据任务的时候;智能记录当前cpu占用率;
 *          ○ 2,今后进行某运算时,智能调节任务量 & 运算时机;(实现智能计算分配,智力不同但不卡顿)
 *      参考:AI/框架/Understand/MainThread;
 *      注:目前版本不开发;
 */
@interface AIMainThread : NSObject

-(BOOL) isBusy;

@end
