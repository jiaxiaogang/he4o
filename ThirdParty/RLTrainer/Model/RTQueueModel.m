//
//  RTQueueModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/2/12.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "RTQueueModel.h"

@implementation RTQueueModel

+(RTQueueModel*) newWithName:(NSString*)name arg0:(id)arg0 arg1:(id)arg1 arg2:(id)arg2 {
    RTQueueModel *result = [[RTQueueModel alloc] init];
    result.name = name;
    result.arg0 = arg0;
    result.arg1 = arg1;
    result.arg2 = arg2;
    return result;
}

@end
