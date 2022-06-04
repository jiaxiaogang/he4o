//
//  RLTrainer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGrowPageSEL @"GrowPage"                //成长页
#define kMainPageSEL @"MainPage"                //回主页
#define kFlySEL @"Fly"                          //飞
#define kWoodLeftSEL @"Wood"                        //扔木棒
#define kWoodRdmSEL @"WoodRdm"                  //随机地点_扔木棒
#define kEatSEL @"Eat"                          //吃
#define kClearTCSEL @"ClearTC"                  //模拟重启

#define kBirthPosRdmSEL @"BirthPosRdm"          //出生在随机
#define kBirthPosRdmCentSEL @"BirthPosRdmCent"  //出生在随机偏中间
#define kBirthPosCentSEL @"BirthPosCent"        //出生在中间

/**
 *  MARK:--------------------强化训练器--------------------
 *  @desc 使用说明: 每个训练项,必须调用以下三个方法:
 *          1. 先通过regist()注册训练项;
 *          2. 再通过queue()新增训练序列;
 *          3. 再通过invoked()标记训练项执行完成;
 */
@interface RLTrainer : NSObject

+(RLTrainer*) sharedInstance;

@property (assign, nonatomic) BOOL noLogMode;   //无日志模式

/**
 *  MARK:--------------------注册可执行训练项--------------------
 */
-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector;

/**
 *  MARK:--------------------新增训练序列--------------------
 */
-(void) queue1:(NSString*)name;
-(void) queue1:(NSString*)name count:(NSInteger)count;
-(void) queueN:(NSArray*)names count:(NSInteger)count;

/**
 *  MARK:--------------------单步训练执行完成报告--------------------
 */
-(void) invoked:(NSString*)name;

/**
 *  MARK:--------------------打开控制台--------------------
 */
-(void) open;

@end
