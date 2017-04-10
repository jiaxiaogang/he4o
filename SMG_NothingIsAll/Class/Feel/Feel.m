//
//  Feel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Feel.h"
#import "InputHeader.h"
#import "SMGHeader.h"

@implementation Feel

-(void) commitInputModel:(InputModel*)inputModel{
    NSLog(@"感觉系统收到Input发来的多媒体数据");
    if (inputModel) {
        [SMG sharedInstance].understand commit
    }
}

-(NSString*) feelForText:(NSString*)text{
    //作数据检查,例如大于50字;则背不下来;只记部分;
    return STRTOOK(text);
}

-(UIImage*) feelForImg:(UIImage*)img{
    //先从本地找替代品;
    return nil;//压缩尺寸,压缩质量,压缩大小后返回;
}

-(NSObject*) feelForAudio:(NSObject*)audio{
    //先从本地找替代品;
    return nil;
}



@end
