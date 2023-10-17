//
//  TCResult.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/7/22.
//  Copyright © 2023 XiaoGang. All rights reserved.
//

#import "TCResult.h"

@implementation TCResult

+(TCResult*) new:(BOOL)success {
    TCResult *result = [[TCResult alloc] init];
    result.success = success;
    return result;
}

-(TCResult*) mkMsg:(NSString*)msg {
    self.msg = msg;
    return self;
}

-(TCResult*) mkDelay:(CGFloat)delay {
    self.delay = delay;
    return self;
}

-(TCResult*) mkStep:(NSInteger)step {
    self.step = step;
    return self;
}

@end
