//
//  MoodDurationManager.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/11.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MoodDurationManager.h"

@interface MoodDurationManager ()

@end

@implementation MoodDurationManager

+ (MoodDurationManager *)sharedInstance
{
    static MoodDurationManager *articleData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        articleData = [[MoodDurationManager alloc] init];
    });
    return articleData;
}

-(void) checkAddMood:(Mood*)mood{
    if (mood) {
        if (mood.type == MoodType_Irritably2Calm) {
            if (mood.value < -3) {
                NSLog(@"急十分钟");
            }
        }
    }
}

@end
