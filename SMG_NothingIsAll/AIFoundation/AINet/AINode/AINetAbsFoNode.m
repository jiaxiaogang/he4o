//
//  AINetAbsFoNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsFoNode.h"

@implementation AINetAbsFoNode


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

-(NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [[NSMutableArray alloc] init];
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
    @try {
        [super encodeWithCoder:aCoder];
        //[aCoder encodeObject:[self.conPorts copy] forKey:@"conPorts"];
        [aCoder encodeObject:self.conPorts forKey:@"conPorts"];//怀疑导致闪退,如复现,改成copy代码试下;
    } @catch (NSException *exception) {
        NSLog(@"%@\n%@\n%@\n%lu",exception.name,exception.reason,exception.userInfo,(unsigned long)self.conPorts.count);
        NSLog(@"");
    }
}

@end
