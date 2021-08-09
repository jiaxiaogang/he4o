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
    if (!_deltaTimes) _deltaTimes = [[NSMutableArray alloc] init];
    return _deltaTimes;
}

-(NSMutableArray *)diffBasePorts{
    if (!ISOK(_diffBasePorts, NSMutableArray.class)) _diffBasePorts = [[NSMutableArray alloc] initWithArray:_diffBasePorts];
    return _diffBasePorts;
}

-(NSMutableArray *)diffSubPorts{
    if (!ISOK(_diffSubPorts, NSMutableArray.class)) _diffSubPorts = [[NSMutableArray alloc] initWithArray:_diffSubPorts];
    return _diffSubPorts;
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
        self.diffBasePorts = [aDecoder decodeObjectForKey:@"diffBasePorts"];
        self.diffSubPorts = [aDecoder decodeObjectForKey:@"diffSubPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cmvNode_p forKey:@"cmvNode_p"];
    [aCoder encodeObject:self.deltaTimes forKey:@"deltaTimes"];
    [aCoder encodeDouble:self.mvDeltaTime forKey:@"mvDeltaTime"];
    [aCoder encodeObject:[self.diffBasePorts copy] forKey:@"diffBasePorts"];
    [aCoder encodeObject:[self.diffSubPorts copy] forKey:@"diffSubPorts"];
}

@end
