//
//  MKStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MKStore.h"



@implementation MKStore

static MKStore *instance;
+(id) sharedInstance{
    if (instance == nil) {
        instance = [[MKStore alloc] init];
    }
    return instance;
}
@end
