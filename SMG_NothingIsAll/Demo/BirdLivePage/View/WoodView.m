//
//  WoodView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "WoodView.h"
#import "UIView+Extension.h"

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
    [self setFrame:CGRectMake(0, (ScreenHeight - 100) * 0.5f, 5, 100)];
    [self setBackgroundColor:UIColorWithRGBHex(0x825528)];
}

-(void) initDisplay{
    [self reset];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

//复位
-(void) reset{
    self.x = 0;
    self.alpha = 0;
}

//扔出
-(void) throw{
    //1. 扔出前复位;
    self.x = 0;
    self.alpha = 1;
    [self.layer removeAllAnimations];
    
    //2. 扔出
    [UIView animateWithDuration:2.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.x += ScreenWidth;
    } completion:^(BOOL finished) {
        if (finished) {
            [self reset];
        }
    }];
    
    
    
}

@end
