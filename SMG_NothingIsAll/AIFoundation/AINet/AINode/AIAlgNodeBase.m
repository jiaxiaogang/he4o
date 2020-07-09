//
//  AIAlgNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIAlgNodeBase.h"

@implementation AIAlgNodeBase

-(NSMutableArray *)refPorts{
    if (_refPorts == nil) {
        _refPorts = [NSMutableArray new];
    }
    return _refPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.refPorts = [aDecoder decodeObjectForKey:@"refPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    @try {
        [super encodeWithCoder:aCoder];
        //[aCoder encodeObject:[self.refPorts copy] forKey:@"refPorts"];
        [aCoder encodeObject:self.refPorts forKey:@"refPorts"];//怀疑导致闪退,如复现,改成copy代码试下;
    } @catch (NSException *exception) {
        NSLog(@"%@\n%@\n%@\n%lu",exception.name,exception.reason,exception.userInfo,(unsigned long)self.refPorts.count);
        NSLog(@"此处老是闪退");
    }
}

@end
