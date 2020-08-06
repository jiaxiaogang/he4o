//
//  HEView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/8/6.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HEView.h"

@implementation HEView

-(id) init {
    self = [super init];
    if(self != nil){
        self.tag = visibleTag;
        self.initTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end
