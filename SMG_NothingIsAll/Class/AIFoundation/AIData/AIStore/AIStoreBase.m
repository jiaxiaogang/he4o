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

+(void) insert:(AIObject*)data awareness:(BOOL)awareness{
    if (data) {
        //1,存data
        [data.class insertToDB:data];
        
        //2,存意识流
        if (awareness) {
            AIAwarenessModel *awareModel = [[AIAwarenessModel alloc] init];
            awareModel.awarenessP = data.pointer;
            [AIAwarenessStore insert:awareModel awareness:false];
        }
    }
}

@end
