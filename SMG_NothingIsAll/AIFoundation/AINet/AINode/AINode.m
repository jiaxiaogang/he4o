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
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
        self.propertyPorts = [aDecoder decodeObjectForKey:@"propertyPorts"];
        self.bePropertyPorts = [aDecoder decodeObjectForKey:@"bePropertyPorts"];
        self.changePorts = [aDecoder decodeObjectForKey:@"changePorts"];
        self.logicPorts = [aDecoder decodeObjectForKey:@"logicPorts"];
        self.beLogicPorts = [aDecoder decodeObjectForKey:@"beLogicPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.absPorts forKey:@"absPorts"];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.propertyPorts forKey:@"propertyPorts"];
    [aCoder encodeObject:self.bePropertyPorts forKey:@"bePropertyPorts"];
    [aCoder encodeObject:self.changePorts forKey:@"changePorts"];
    [aCoder encodeObject:self.logicPorts forKey:@"logicPorts"];
    [aCoder encodeObject:self.beLogicPorts forKey:@"beLogicPorts"];
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

-(NSMutableArray *)beLogicPorts{
    if (_beLogicPorts == nil) {
        _beLogicPorts = [[NSMutableArray alloc] init];
    }
    return _beLogicPorts;
}

@end



//MARK:===============================================================
//MARK:                     < AICMVNode >
//MARK:===============================================================
@implementation AICMVNode : AINode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.cmvModel = [aDecoder decodeObjectForKey:@"cmvModel"];
        self.changePorts = [aDecoder decodeObjectForKey:@"changePorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cmvModel forKey:@"cmvModel"];
    [aCoder encodeObject:self.changePorts forKey:@"changePorts"];
}

@end
