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


-(void) commitText:(NSString*)text{
    
    text = STRTOOK(text);
    
    //取属性;
    //[FeelTextUtils getLength:text];
    if (self.delegate && [self.delegate respondsToSelector:@selector(feel_CommitToThink:)]) {
        [self.delegate feel_CommitToThink:text];
    }
}

-(void) commitImg:(UIImage*)img{
    //1,解析出
    //2,先从本地找替代品;取不到合适的;再解析img;
    //3,压缩尺寸,压缩质量,压缩大小后返回;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(feel_CommitToThink:)]) {
        [self.delegate feel_CommitToThink:img];
    }
}

-(void) commitAudio:(NSObject*)audio{
    //先从本地找替代品;
    if (self.delegate && [self.delegate respondsToSelector:@selector(feel_CommitToThink:)]) {
        [self.delegate feel_CommitToThink:audio];
    }
}

@end
