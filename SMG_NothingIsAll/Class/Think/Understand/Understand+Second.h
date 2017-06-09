//
//  Understand+Second.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Understand.h"

/**
 *  MARK:--------------------Think-理解--------------------
 *  接AIFoundation版的Understand系统;
 */
@interface Understand (Second)

/**
 *  MARK:--------------------无注意力的--------------------
 *  1,存回放池;
 *  2,转Feel;(取属性,取Obj等但不存储;)
 *  3,唯一性判断(如果大脑正在思考别的事;将不作判断 & 并中断执行下去)//此方法部分
 *  4,由Mind判断要不要去理解;(由mind执行)
 *  5,无注意力时,是不记忆的;(由mind决定)
 */
-(AIPointer*) commitOutAttention:(id)data;


/**
 *  MARK:--------------------有注意力的--------------------
 *  1,由Mind驱动
 *  2,
 */
-(void) commitInAttension:(id)data;



@end
