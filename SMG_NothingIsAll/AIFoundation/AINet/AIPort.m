//
//  AIPort.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPort.h"
#import "AINode.h"

@implementation AIPort


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.pointer = [coder decodeObjectForKey:@"pointer"];
        self.strong = [coder decodeObjectForKey:@"strong"];
        self.dataType = [coder decodeObjectForKey:@"dataType"];
        self.dataSource = [coder decodeObjectForKey:@"dataSource"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.pointer forKey:@"pointer"];
    [coder encodeObject:self.strong forKey:@"strong"];
    [coder encodeObject:self.dataType forKey:@"dataType"];
    [coder encodeObject:self.dataSource forKey:@"dataSource"];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
+(AIPort*) newWithNode:(AINode*)node{
    AIPort *port = [[AIPort alloc] init];
    if (node) {
        port.pointer = node.pointer;
        port.dataType = node.dataType;
        port.dataSource = node.dataSource;
    }
    return port;
}

@end


@implementation AIPortStrong

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.value = [coder decodeIntForKey:@"value"];
        self.updateTime = [coder decodeDoubleForKey:@"updateTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.value forKey:@"value"];
    [coder encodeDouble:self.updateTime forKey:@"updateTime"];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) updateValue {
    long long nowTime = [[NSDate date] timeIntervalSince1970];
    if (nowTime > self.updateTime) {
        self.value -= MAX(0, (nowTime - self.updateTime) / 86400);//(目前先每天减1;)
    }
    self.updateTime = nowTime;
}

@end
