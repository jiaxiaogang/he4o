//
//  SMGHeader.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGEnum.h"
#import "SMG.h"
#import "SMGUtils.h"
#import "SMGRange.h"
#import "SMGEnum.h"
#import "StoreHeader.h"
#import "AIHeader.h"
#import "MindHeader.h"

/**
 *  MARK:--------------------ObserverKEY--------------------
 */
#define ObsKey_ThinkBusy @"ObsKey_ThinkBusy"                            //思考状改变
#define ObsKey_MainThreadBusy @"ObsKey_MainThreadBusy"                  //意识线程状态改变
#define ObsKey_AwarenessModelChanged @"ObsKey_AwarenessModelChanged"    //意识流新数据
#define ObsKey_HungerLevelChanged @"ObsKey_HungerLevelChanged"          //电量改变
/**
 *  MARK:--------------------数据检查--------------------
 */

//String
#define STRISOK(a) (a  && ![a isKindOfClass:[NSNull class]] && [a isKindOfClass:[NSString class]] && ![a isEqualToString:@""])//是否空字符串
#define STRTOOK(a) (a  && ![a isKindOfClass:[NSNull class]]) ? ([a isKindOfClass:[NSString class]] ? a : [NSString stringWithFormat:@"%@", a]) : @""
#define STRFORMAT(a, ...) [NSString stringWithFormat:a, ##__VA_ARGS__]//String.format

//Array
#define ARRISOK(a) (a  && [a isKindOfClass:[NSArray class]] && a.count)//是否空数组
#define ARRTOOK(a) (a  && [a isKindOfClass:[NSArray class]]) ?  a : [NSArray new]
#define ARR_INDEX(a,i) (a && [a isKindOfClass:[NSArray class]] && a.count > i) ?  a[i] : nil//数组取子防闪

//NSNumber
#define NUMISOK(a) (a  && [a isKindOfClass:[NSNumber class]])//是否有效NSNumber
#define NUMTOOK(a) (a  && [a isKindOfClass:[NSNumber class]]) ? a : @(0)

//Dic
#define DICISOK(a) (a  && [a isKindOfClass:[NSDictionary class]] && a.count)//是否空字典
#define DICTOOK(a) (a  && [a isKindOfClass:[NSDictionary class]]) ?  a : [NSDictionary new]

//AILine
#define LINEISOK(a) (a  && [a isKindOfClass:[AILine class]])

//AIPointer
#define POINTERISOK(a) (a && [a isKindOfClass:[AIPointer class]] && a.pointerId > 0)

//ISOK
#define ISOK(a, c) (a && [a isKindOfClass:c])

/**
 *  MARK:--------------------快捷建对象--------------------
 */

//SMGRange
#define SMGRangeMake(loc,len) [SMGRange rangeWithLocation:loc length:len]


/**
 *  MARK:--------------------快捷访问对象--------------------
 */
#define theOutput [SMG sharedInstance].output
#define theThink [SMG sharedInstance].thinkControl
#define theFeel [SMG sharedInstance].feel
#define theInput [SMG sharedInstance].input
#define theMainThread [SMG sharedInstance].mainThread

#define theMind [SMG sharedInstance].mindControl
#define theMine [SMG sharedInstance].mindControl.mine
#define theAwareness [SMG sharedInstance].mindControl.awareness
#define theMood [SMG sharedInstance].mindControl.mine.mood
#define theHunger [SMG sharedInstance].mindControl.mine.hunger
#define theHobby [SMG sharedInstance].mindControl.mine.hobby

