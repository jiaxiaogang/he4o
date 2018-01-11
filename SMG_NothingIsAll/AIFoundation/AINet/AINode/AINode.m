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
        self.isAPorts = [aDecoder decodeObjectForKey:@"isAPorts"];
        self.subPorts = [aDecoder decodeObjectForKey:@"subPorts"];
        self.propertyPorts = [aDecoder decodeObjectForKey:@"propertyPorts"];
        self.methodPorts = [aDecoder decodeObjectForKey:@"methodPorts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.isAPorts forKey:@"isAPorts"];
    [aCoder encodeObject:self.subPorts forKey:@"subPorts"];
    [aCoder encodeObject:self.propertyPorts forKey:@"propertyPorts"];
    [aCoder encodeObject:self.methodPorts forKey:@"methodPorts"];
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
@implementation AIPropertyNode : AINode

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
@implementation AIMethodNode : AINode

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
@implementation AIChangeNode : AINode

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
