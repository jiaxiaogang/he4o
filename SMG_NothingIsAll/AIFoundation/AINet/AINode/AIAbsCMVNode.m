//
//  AIAbsCMVNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsCMVNode.h"
#import "AIPort.h"
#import "AIPointer.h"

//MARK:===============================================================
//MARK:                     < AIAbsCMVNode >
//MARK:===============================================================
@implementation AIAbsCMVNode

- (NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [NSMutableArray new];
    }
    return _conPorts;
}

-(AIPort*) getConPort:(NSInteger)index{
    return ARR_INDEX(self.conPorts, index);
}

-(AIPort*) getConPortWithExcept:(NSArray*)except_ps{
    for (AIPort *conPort in self.conPorts) {
        BOOL excepted = false;
        for (AIPointer *except_p in ARRTOOK(except_ps)) {
            if ([except_p isEqual:conPort.target_p]) {
                excepted = true;
                break;
            }
        }
        if (!excepted) {
            conPort.strong.value += 1;//被激活强度+1;
            return conPort;
        }
    }
    return nil;
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
}

@end
