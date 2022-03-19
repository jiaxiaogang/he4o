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

/**
 *  MARK:--------------------isEqual--------------------
 *  @version
 *      2022.03.19: content_p为空时,返回super.Equal(),因为Demand的content_p全是空的;
 */
-(BOOL) isEqual:(TOModelBase*)object{
    if (object && object.content_p) {
        return [object.content_p isEqual:self.content_p];
    }
    return [super isEqual:object];
}

-(void)setStatus:(TOModelStatus)status{
    NSLog(@"toModel.setStatus:%@ (%@ -> %@)",Pit2FStr(self.content_p),TOStatus2Str(self.status),TOStatus2Str(status));
    _status = status;
}

@end
