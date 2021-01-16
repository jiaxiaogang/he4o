//
//  WoodView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "WoodView.h"

@implementation WoodView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setFrame:CGRectMake(0, ScreenHeight - 150 - 85, 5, 150)];
    [self setBackgroundColor:UIColorWithRGBHex(0x825528)];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) throw{
    //1. 扔出
    [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.x += ScreenWidth;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
