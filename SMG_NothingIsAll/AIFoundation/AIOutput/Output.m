//
//  Output.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Output.h"

@implementation Output

-(void) output_Text:(NSString*)text{
    [self saveLogThink:OutputType_Text content:STRTOOK(text)];
    NSLog(@"%@",text);
}

-(void) output_Face:(MoodType)type value:(int)value{
    if (type == MoodType_Irritably2Calm) {
        if (value < 0) {
            [self saveLogThink:OutputType_Face content:@(OutputFaceType_Cry)];//logThink
            NSLog(@"😭");
        }else if(value > 1) {
            [self saveLogThink:OutputType_Face content:@(OutputFaceType_Smile)];//logThink
            NSLog(@"😃");
        }
    }
}

-(void) saveLogThink:(OutputType)type content:(NSObject*)content{
    //1,存输出
}

@end
