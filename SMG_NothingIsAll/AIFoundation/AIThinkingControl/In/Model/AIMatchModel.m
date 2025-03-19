//
//  AIMatchModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/19.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIMatchModel.h"

@implementation AIMatchModel

-(id) init {
    self = [super init];
    if (self != nil) {
        self.matchValue = 1;
    }
    return self;
}


/**
 *  MARK:--------------------获取强度--------------------
 *  @desc 获取概念引用强度,求出平均值 (参考2722d-todo4);
 */
-(CGFloat) strongValue {
    return self.matchCount > 0 ? self.sumRefStrong / self.matchCount : 1;
}

@end
