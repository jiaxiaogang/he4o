//
//  AINode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINode.h"

//MARK:===============================================================
//MARK:                     < AINode >
//MARK:===============================================================
@implementation AINode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.dataType = [aDecoder decodeObjectForKey:@"dataType"];
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
        self.propertyPorts = [aDecoder decodeObjectForKey:@"propertyPorts"];
        self.bePropertyPorts = [aDecoder decodeObjectForKey:@"bePropertyPorts"];
        self.changePorts = [aDecoder decodeObjectForKey:@"changePorts"];
        self.logicPorts = [aDecoder decodeObjectForKey:@"logicPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.dataType forKey:@"dataType"];
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.propertyPorts forKey:@"propertyPorts"];
    [aCoder encodeObject:self.bePropertyPorts forKey:@"bePropertyPorts"];
    [aCoder encodeObject:self.changePorts forKey:@"changePorts"];
    [aCoder encodeObject:self.logicPorts forKey:@"logicPorts"];
}

-(NSMutableArray *)absPorts{
    if (_absPorts == nil) {
        _absPorts = [[NSMutableArray alloc] init];
    }
    return _absPorts;
}

-(NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [[NSMutableArray alloc] init];
    }
    return _conPorts;
}

-(NSMutableArray *)propertyPorts{
    if (_propertyPorts == nil) {
        _propertyPorts = [[NSMutableArray alloc] init];
    }
    return _propertyPorts;
}

-(NSMutableArray *)bePropertyPorts{
    if (_bePropertyPorts == nil) {
        _bePropertyPorts = [[NSMutableArray alloc] init];
    }
    return _bePropertyPorts;
}

-(NSMutableArray *)changePorts{
    if (_changePorts == nil) {
        _changePorts = [[NSMutableArray alloc] init];
    }
    return _changePorts;
}

-(NSMutableArray *)logicPorts{
    if (_logicPorts == nil) {
        _logicPorts = [[NSMutableArray alloc] init];
    }
    return _logicPorts;
}

@end


//MARK:===============================================================
//MARK:                     < AIValueNode >
//MARK:===============================================================
@implementation AIValueNode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.from = [aDecoder decodeFloatForKey:@"from"];
        self.to = [aDecoder decodeFloatForKey:@"to"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.from forKey:@"from"];
    [aCoder encodeFloat:self.to forKey:@"to"];
}

@end


//MARK:===============================================================
//MARK:                     < AILogicNode >
//MARK:===============================================================
@implementation AILogicNode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.resultPorts = [aDecoder decodeObjectForKey:@"resultPorts"];
        self.target = [aDecoder decodeObjectForKey:@"target"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.resultPorts forKey:@"resultPorts"];
    [aCoder encodeObject:self.target forKey:@"target"];
}

@end


//MARK:===============================================================
//MARK:                     < AIChangeNode >
//MARK:===============================================================
@implementation AIChangeNode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.fromValue = [aDecoder decodeFloatForKey:@"fromValue"];
        self.toValue = [aDecoder decodeFloatForKey:@"toValue"];
        self.target = [aDecoder decodeObjectForKey:@"target"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.fromValue forKey:@"fromValue"];
    [aCoder encodeFloat:self.toValue forKey:@"toValue"];
    [aCoder encodeObject:self.target forKey:@"target"];
}

@end
