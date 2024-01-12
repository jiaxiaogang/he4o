////
////  AILine.h
////  SMG_NothingIsAll
////
////  Created by 贾  on 2017/6/29.
////  Copyright © 2017年 XiaoGang. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "AIObject.h"
//
///**
// *  MARK:--------------------网线--------------------
// *  1,指向任何2+个AIPointer
// *  2,形成"神经网络"的网络线
// *  3,自带强度及衰减强化策略
// *  4,单独存表
// *  5,销毁时,通知GC;GC去回收已经没有指向的数据;
// */
//@class AILineStrong,AIPort,AIPointer;
//@interface AILine : AIObject
//
///**
// *  MARK:--------------------new--------------------
// *  @param obj... : 需要传入obj是已存储过的
// *  //估计将要删掉AILineType;不灵活...AILineType本身应该也是一个抽象节点;
// *  //准备开发多维网络(像多维数组的概念)
// */
//+ (AILine*) newWithType:(AILineType)type aiObjs:(NSArray*)aiObjs;
//
////@property (strong,nonatomic) NSMutableArray *pointers;//count=2
//@property (strong,nonatomic) AILineStrong *strong;   //网络强度
//@property (assign, nonatomic) AILineType type;       //因"知识表示"的泛化要求;必须简化"树形知识表示"结构;而更加依赖AILine;而AILaw和AILogic也可以使用AILine来代替;(参考N4P1)
//@property (strong,nonatomic) AIPort *port;          //接口
//
///**
// *  MARK:--------------------取另一头--------------------
// */
//-(NSArray*) otherPointers:(AIPointer*)pointer;
//
//@end

