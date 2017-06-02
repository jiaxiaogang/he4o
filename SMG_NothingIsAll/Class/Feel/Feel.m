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
#import "FeelHeader.h"
#import "ThinkHeader.h"

@implementation Feel


-(NSString*) feelForText:(NSString*)text{
    
    //取属性;
    //[FeelTextUtils getLength:text];
    
    return STRTOOK(text);
}

-(UIImage*) feelForImg:(UIImage*)img{
    //解析出
    //先从本地找替代品;取不到合适的;再解析img;
    
    return nil;//压缩尺寸,压缩质量,压缩大小后返回;
}

-(NSObject*) feelForAudio:(NSObject*)audio{
    //先从本地找替代品;
    return nil;
}

@end
