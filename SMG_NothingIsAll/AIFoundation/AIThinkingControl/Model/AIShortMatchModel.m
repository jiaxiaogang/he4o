//
//  ActiveCache.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/15.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIShortMatchModel.h"

@implementation AIShortMatchModel

-(AIAlgNodeBase *)matchAlg{
    return ARR_INDEX(self.matchAlgs, 0);
}

@end
