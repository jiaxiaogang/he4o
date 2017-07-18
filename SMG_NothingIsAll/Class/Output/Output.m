//
//  Output.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Output.h"
#import "SMGHeader.h"

@implementation Output

-(void) output_Text:(NSString*)text{
    [self saveLogThink:OutputType_Text content:STRTOOK(text)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(output_Text:)]) {
        [self.delegate output_Text:STRTOOK(text)];
    }
}

-(void) output_Face:(MoodType)type value:(int)value{
    if (type == MoodType_Irritably2Calm) {
        if (value < 0) {
            [self saveLogThink:OutputType_Face content:@(OutputFaceType_Cry)];//logThink
            if (self.delegate && [self.delegate respondsToSelector:@selector(output_Face:)]) {
                [self.delegate output_Face:@"😭"];
            }
        }else if(value > 1) {
            [self saveLogThink:OutputType_Face content:@(OutputFaceType_Smile)];//logThink
            if (self.delegate && [self.delegate respondsToSelector:@selector(output_Face:)]) {
                [self.delegate output_Face:@"😃"];
            }
        }
    }
}

-(void) saveLogThink:(OutputType)type content:(NSObject*)content{
    //1,存输出
    AIOutputModel *model = [[AIOutputModel alloc] init];
    model.type = type;
    model.content = content;
    [AIOutputStore insert:model awareness:true];
}

@end
