//
//  AIDemand.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIDemandModel.h"

@implementation AIDemandModel

-(id) initWithAIMindValueModel:(AIMindValueModel*)model{
    self = [super init];
    if (self) {
        if (model) {
            self.value = fabs(model.value);
            self.type = model.type;
        }
    }
    return self;
}

@end
