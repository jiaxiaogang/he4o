//
//  AIAwarenessStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIAwarenessStore.h"

@implementation AIAwarenessStore

+(void) insert:(AIObject*)data awareness:(BOOL)awareness{
    [super insert:data awareness:awareness];
    //2,每次意识流数据变化引起意识的思考;
    if (data) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ObsKey_AwarenessModelChanged object:data];
    }
}

@end
