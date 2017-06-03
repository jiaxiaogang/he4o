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

/**
 *  MARK:--------------------记忆数据--------------------
 *  1,用Decision分析记忆中数据为mindShakeArr;将mindShakeArr交由Mind决断(Decision与Mind紧密关联)
 *  2,Mind决断后,下达需求任务给FeelOut;
 *  3,FeelOut决定如何输出;
 *  注:(此处引出Decision的"分析决策阶段"和"FeelOut阶段"的不同)(因为我们有可能分析决策;但不行动)
 *
 *  如:早上起来喝牛奶:
 *      1,早上起来,Input记忆时Understand联想到喝牛奶;
 *      2,Understand交给Mind;
 *      3,Mind交@"喝牛奶"给Decision找到喝牛奶找到关联记忆;并分析mindShakeArr交回给Mind;
 *      4,Mind下令喝一个;并交给FeelOut;
 *      5,FeelOut决定行动起来;喝一个走起;
 *  如:饿了:
 *      1,Mind饿了;
 *      2,将找吃的交给Decision找到冰箱里有什么的关联记忆,并分析mindShakeArr交回给Mind;
 *      3,Mind下令喝牛奶;并交给FeelOut;
 *      4,FeelOut决定行动起来;喝一个走起;
 */
@property (strong,nonatomic) NSMutableArray *memArr;    //相关记忆数据;

@property (strong,nonatomic) NSMutableArray *mindShakeArr;  //


@end
