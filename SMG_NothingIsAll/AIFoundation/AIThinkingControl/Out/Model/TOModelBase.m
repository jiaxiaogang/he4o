//
//  TOModelBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"
#import "AIKVPointer.h"

@implementation TOModelBase

-(id) initWithContent_p:(AIKVPointer*)content_p{
    self = [super init];
    if (self) {
        self.content_p = content_p;
    }
    return self;
}

- (NSMutableArray *)except_ps{
    if (_except_ps == nil) {
        _except_ps = [[NSMutableArray alloc] init];
    }
    return _except_ps;
}

-(BOOL) isEqual:(TOModelBase*)object{
    if (object && object.content_p) {
        return [object.content_p isEqual:self.content_p];
    }
    return false;
}

@end
