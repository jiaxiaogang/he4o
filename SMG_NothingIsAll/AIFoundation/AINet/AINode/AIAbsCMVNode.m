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

/**
 *  MARK:--------------------添加具象关联--------------------
 *  注:从大到小(5,4,3,2,1)
 */
-(void) addConPorts:(AIPort*)conPort{
    //1. 数据检查
    if (conPort == nil) {
        return;
    }
    
    //2. 去重
    for (NSInteger i = 0; i < self.conPorts.count; i++) {
        AIPort *checkPort = self.conPorts[i];
        if (checkPort.target_p) {
            if ([checkPort.target_p isEqual:conPort.target_p]) {
                [self.conPorts removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    //3. 插入合适位置
    BOOL find = false;
    for (NSInteger i = 0; i < self.conPorts.count; i++) {
        AIPort *checkPort = self.conPorts[i];
        if (checkPort.strong.value < conPort.strong.value) {
            [self.conPorts insertObject:conPort atIndex:i];
            find = true;
            break;
        }
    }
    if (!find) {
        [self.conPorts addObject:conPort];
    }
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
