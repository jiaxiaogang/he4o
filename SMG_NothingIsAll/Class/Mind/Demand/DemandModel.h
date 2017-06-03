//
//  DemandModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/3.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------需求模型--------------------
 *  特性:
 *      1,可变性(不同人对同事件在不同情况下会产生不同需求)
 *      2,灵活性(Mind变化,需求就变化)
 *  
 *  数据格式:
 *      1,因为其特性,所以需求不能存在Memory中,也不能存DB;只能实时生成;
 *  分类:
 *      1,记忆相关需求:如参加会议,从Mem里找引起需求变化的记忆,并分析出需求;
 *      2,记忆无关需求:如饥饿,从Mine读取值;
 *  设计:
 *      1,但Demand必须由Mind产生,从Memory生成,
 *      2,Demand不能存死在DB
 *      3,Demand会传递(例如,明天早上起来记得吃个鸡蛋)
 *      4,Demand有解决程度(例如,完成了50%的需求)
 *      5,需求的分析,可以存在记忆中...(参见N2P13)
 *
 */
@interface DemandModel : NSObject



@end
