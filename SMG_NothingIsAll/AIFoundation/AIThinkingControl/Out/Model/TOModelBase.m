//
//  TOModelBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/26.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"

@implementation TOModelBase

-(id) initWithContent_p:(AIKVPointer*)content_p{
    self = [super init];
    if (self) {
        self.content_p = content_p;
    }
    return self;
}

-(BOOL) isEqual:(TOModelBase*)object{
    if (object && object.content_p) {
        return [object.content_p isEqual:self.content_p];
    }
    return false;
}

-(void)setStatus:(TOModelStatus)status{
    NSLog(@"toModel.setStatus:%@ (%@ -> %@)",Pit2FStr(self.content_p),TOStatus2Str(self.status),TOStatus2Str(status));
    _status = status;
}

@end
