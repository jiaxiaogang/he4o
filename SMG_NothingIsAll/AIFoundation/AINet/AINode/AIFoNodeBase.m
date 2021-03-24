//
//  AIFoNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIFoNodeBase.h"

@implementation AIFoNodeBase

-(NSMutableArray *)deltaTimes{
    if (!_deltaTimes) {
        _deltaTimes = [[NSMutableArray alloc] init];
    }
    return _deltaTimes;
}

-(NSMutableArray *)diffConPorts{
    if (!ISOK(_diffConPorts, NSMutableArray.class)) {
        _diffConPorts = [[NSMutableArray alloc] initWithArray:_diffConPorts];
    }
    return _diffConPorts;
}

-(NSMutableArray *)diffAbsPorts{
    if (!ISOK(_diffAbsPorts, NSMutableArray.class)) {
        _diffAbsPorts = [[NSMutableArray alloc] initWithArray:_diffAbsPorts];
    }
    return _diffAbsPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.cmvNode_p = [aDecoder decodeObjectForKey:@"cmvNode_p"];
        self.deltaTimes = [aDecoder decodeObjectForKey:@"deltaTimes"];
        self.mvDeltaTime = [aDecoder decodeDoubleForKey:@"mvDeltaTime"];
        self.diffConPorts = [aDecoder decodeObjectForKey:@"diffConPorts"];
        self.diffAbsPorts = [aDecoder decodeObjectForKey:@"diffAbsPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cmvNode_p forKey:@"cmvNode_p"];
    [aCoder encodeObject:self.deltaTimes forKey:@"deltaTimes"];
    [aCoder encodeDouble:self.mvDeltaTime forKey:@"mvDeltaTime"];
    [aCoder encodeObject:[self.diffConPorts copy] forKey:@"diffConPorts"];
    [aCoder encodeObject:[self.diffAbsPorts copy] forKey:@"diffAbsPorts"];
}

@end
