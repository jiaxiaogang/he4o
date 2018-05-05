//
//  AIPort.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPort.h"
#import "AINode.h"
#import "AIKVPointer.h"

@implementation AIPort


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.pointer = [coder decodeObjectForKey:@"pointer"];
        self.strong = [coder decodeObjectForKey:@"strong"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.pointer forKey:@"pointer"];
    [coder encodeObject:self.strong forKey:@"strong"];
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(AIPortStrong *)strong{
    if (_strong == nil) {
        _strong = [[AIPortStrong alloc] init];
    }
    return _strong;
}

+(AIPort*) newWithNode:(AINode*)node{
    AIPort *port = [[AIPort alloc] init];
    if (node) {
        port.pointer = node.pointer;
    }
    return port;
}

-(NSComparisonResult) compare:(AIPort*)port{
    if (ISOK(port, AIPort.class)) {
        if (self.strong) {
            NSComparisonResult strongResult = [self.strong compare:port.strong];
            if (strongResult == NSOrderedSame) {
                if (ISOK(self.pointer, AIKVPointer.class)) {
                    if (ISOK(port.pointer, AIKVPointer.class)) {
                        if (self.pointer.pointerId > port.pointer.pointerId) {
                            return NSOrderedAscending;
                        }else if(self.pointer.pointerId < port.pointer.pointerId){
                            return NSOrderedDescending;
                        }else{
                            return NSOrderedSame;
                        }
                    }
                }else{
                    return strongResult;
                }
            }else{
                return strongResult;
            }
        }
    }
    return NSOrderedAscending;
}

@end




//MARK:===============================================================
//MARK:                     < AIPortStrong >
//MARK:===============================================================
@implementation AIPortStrong


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

-(NSComparisonResult) compare:(AIPortStrong*)strong{
    if (ISOK(strong, AIPortStrong.class)) {
        if (self.value > strong.value) {
            return NSOrderedAscending;
        }else if(self.value < strong.value){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }
    return NSOrderedAscending;
}


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

@end
