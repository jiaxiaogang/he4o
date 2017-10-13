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
#import "AINet.h"

@implementation Input

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    
}

-(void) commitText:(NSString*)text{
    [theThink commitUnderstandByShallowFromInput:text];//从input常规输入的浅度理解即可;(简单且错误,参考N4P2)
    
    //2017.10.13修正,input->aiNet->funcModel->aiNet->awareness作预测对比(参考n7p6)
    [theNet commitString:text];
}

@end
