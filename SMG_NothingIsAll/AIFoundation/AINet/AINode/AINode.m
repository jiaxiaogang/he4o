//
//  AINode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINode.h"

//MARK:===============================================================
//MARK:                     < AINodeBase >
//MARK:===============================================================
@implementation AINodeBase

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.subPorts = [aDecoder decodeObjectForKey:@"subPorts"];
        self.propertyPorts = [aDecoder decodeObjectForKey:@"propertyPorts"];
        self.methodPorts = [aDecoder decodeObjectForKey:@"methodPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.subPorts forKey:@"subPorts"];
    [aCoder encodeObject:self.propertyPorts forKey:@"propertyPorts"];
    [aCoder encodeObject:self.methodPorts forKey:@"methodPorts"];
}

-(NSMutableArray *)subPorts{
    if (_subPorts == nil) {
        _subPorts = [[NSMutableArray alloc] init];
    }
    return _subPorts;
}

-(NSMutableArray *)propertyPorts{
    if (_propertyPorts == nil) {
        _propertyPorts = [[NSMutableArray alloc] init];
    }
    return _propertyPorts;
}

-(NSMutableArray *)methodPorts{
    if (_methodPorts == nil) {
        _methodPorts = [[NSMutableArray alloc] init];
    }
    return _methodPorts;
}

@end


//MARK:===============================================================
//MARK:                     < AINode >
//MARK:===============================================================
@implementation AINode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.isAPorts = [aDecoder decodeObjectForKey:@"isAPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.isAPorts forKey:@"isAPorts"];
}

-(NSMutableArray *)isAPorts{
    if (_isAPorts == nil) {
        _isAPorts = [[NSMutableArray alloc] init];
    }
    return _isAPorts;
}

@end


//MARK:===============================================================
//MARK:                     < AIIntanceNode >
//MARK:===============================================================
@implementation AIIntanceNode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.instanceOf = [aDecoder decodeObjectForKey:@"instanceOf"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.instanceOf forKey:@"instanceOf"];
}

@end


//MARK:===============================================================
//MARK:                     < AIPropertyNode >
//MARK:===============================================================
@implementation AIPropertyNode

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.isClass = [aDecoder decodeObjectForKey:@"isClass"];
        self.valueIs = [aDecoder decodeObjectForKey:@"valueIs"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.isClass forKey:@"isClass"];
    [aCoder encodeObject:self.valueIs forKey:@"valueIs"];
}

@end


//MARK:===============================================================
//MARK:                     < AIMethodNode >
//MARK:===============================================================
@implementation AIMethodNode

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
