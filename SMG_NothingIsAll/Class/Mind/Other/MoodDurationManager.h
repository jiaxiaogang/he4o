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
 */
@interface MoodDurationManager : NSObject

+ (MoodDurationManager *)sharedInstance;
-(void) checkAddMood:(Mood*)mood;

@end
