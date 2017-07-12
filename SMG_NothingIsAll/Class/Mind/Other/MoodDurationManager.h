//
//  MoodDurationManager.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/11.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------"精神持续"管理类--------------------
 *  如:心情:开心,恐惧,生气,急等;
 *
 *  //两种设计:
 *  //1,使用"心情持续"管理器;
 *  //2,使用"神经网络"AILine的类型;
 *  //3,AILine越简单越好,所以当前先用方案1;以后不排除重构使用2;
 */
@interface MoodDurationManager : NSObject

+ (MoodDurationManager *)sharedInstance;
-(void) checkAddMood:(Mood*)mood rateBlock:(void(^)(Mood *mood))rateBlock;
-(void) checkRemoveMood:(Mood*)mood;

@end





@interface MoodDurationManagerModel : NSObject

@property (strong,nonatomic) Mood *mood;
@property (strong,nonatomic) void(^ rateBlock)(Mood *mood);

@end
