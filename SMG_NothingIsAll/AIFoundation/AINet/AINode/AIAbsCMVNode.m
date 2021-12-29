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
    if (!ISOK(_conPorts, NSMutableArray.class)) {
        _conPorts = [[NSMutableArray alloc] initWithArray:_conPorts];
    }
    return _conPorts;
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
    [aCoder encodeObject:[self.conPorts copy] forKey:@"conPorts"];
}

@end
