//
//  AIFArray.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIFArray.h"

@implementation AIFArray

-(id) init{
    self = [super init];
    if (self) {
        self.content = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addObject:(AIFObject*)obj{
    if (obj) {
        [self.content addObject:obj.pointer];
    }else{
        NSLog(@"!!!数据为空");
    }
}

-(void) removeObject:(AIFObject*)obj{
    if (obj) {
        [self.content removeObject:obj.pointer];
    }
}

-(void) removeObjectFromAtIndex:(NSUInteger)index{
    [self.content removeObjectAtIndex:index];
}

-(BOOL) containsObject:(AIFObject*)obj{
    if (obj) {
        return [self.content containsObject:obj.pointer];
    }
    return false;
}
@end
