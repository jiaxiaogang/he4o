//
//  Input.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Input.h"
#import "InputHeader.h"
#import "SMGHeader.h"
#import "FeelHeader.h"
#import "ThinkHeader.h"

@implementation Input

-(void) commitText:(NSString*)text{
    if (self.delegate && [self.delegate respondsToSelector:@selector(input_CommitToThink:)]) {
        [self.delegate input_CommitToThink:STRTOOK(text)];
    }
}

@end
