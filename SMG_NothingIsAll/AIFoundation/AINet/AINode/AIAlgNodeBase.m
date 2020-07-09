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
        [aCoder encodeObject:self.refPorts forKey:@"refPorts"];
    } @catch (NSException *exception) {
        NSLog(@"%@\n%@\n%@\n%@",exception.name,exception.reason,exception.userInfo,self.refPorts);
        NSLog(@"此处老是闪退,refPorts有快两千个元素了,,,");
    }
}

@end
