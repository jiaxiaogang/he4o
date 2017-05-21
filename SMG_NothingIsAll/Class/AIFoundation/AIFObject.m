//
//  AIFObject.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFObject.h"

@implementation AIFObject


-(id) init{
    self = [super init];
    if (self) {
        self.pointer = [[PointerModel alloc] init];
        self.pointer.pointerClass = NSStringFromClass(self.class);
    }
    return self;
}

-(void) print{
    NSLog(@"%@",self);
}


@end
