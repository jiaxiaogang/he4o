//
//  AIMainThread.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMainThread.h"

@implementation AIMainThread

-(void)setIsBusy:(BOOL)isBusy{
    _isBusy = isBusy;
    [[NSNotificationCenter defaultCenter] postNotificationName:ObsKey_MainThreadBusy object:nil];
}

@end
