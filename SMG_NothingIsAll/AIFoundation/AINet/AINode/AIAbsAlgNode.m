//
//  AIAbsAlgNode.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsAlgNode.h"

@implementation AIAbsAlgNode

-(NSMutableArray *)conPorts{
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

/**
 *  MARK:--------------------encode--------------------
 *  @bug
 *      2020.12.27: 老闪退,将ports加了copy应该就好了 (原来就有过类似问题,这次全局conPorts,absPorts和refPorts都加了copy);
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self.conPorts copy] forKey:@"conPorts"];
}

@end
