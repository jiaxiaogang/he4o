//
//  Output.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Output.h"

@implementation Output

static Output *_instance;
+(Output*) sharedInstance{
    if (_instance == nil) {
        _instance = [[Output alloc] init];
    }
    return _instance;
}

+(void) output_Text:(NSString*)text{
    Output *op = [Output sharedInstance];
    if (op.delegate && [op.delegate respondsToSelector:@selector(output_Text:)]) {
        [op.delegate output_Text:text];
    }
}

+(void) output_Face:(OutputFaceType)type{
    Output *op = [Output sharedInstance];
    if (op.delegate && [op.delegate respondsToSelector:@selector(output_Text:)]) {
        if (type == OutputFaceType_Cry) {
            [op.delegate output_Text:@"😭"];
        }else if(type == OutputFaceType_Smile){
            [op.delegate output_Text:@"😃"];
        }
    }
}

@end
