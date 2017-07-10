//
//  AIStoreBase.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIStoreBase.h"

@implementation AIStoreBase

+(id) search{
    return nil;
}

+(void) insert:(NSObject*)data{
    if (data) {
        [data.class insertToDB:data];
    }
}

@end
