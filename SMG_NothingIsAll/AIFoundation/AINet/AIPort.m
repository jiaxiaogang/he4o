//
//  AIPort.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPort.h"
#import "AIKVPointer.h"

@implementation AIPort


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.target_p = [coder decodeObjectForKey:@"target_p"];
        self.strong = [coder decodeObjectForKey:@"strong"];
        self.header = [coder decodeObjectForKey:@"header"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.target_p forKey:@"target_p"];
    [coder encodeObject:self.strong forKey:@"strong"];
    [coder encodeObject:self.header forKey:@"header"];
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

-(void) strongPlus{
    self.strong.value ++;
}

-(BOOL) isEqual:(AIPort*)object{
    if (ISOK(object, AIPort.class)) {
        if (self.target_p) {
            return [self.target_p isEqual:object.target_p];
        }
    }
    return false;
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


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.value = [coder decodeIntegerForKey:@"value"];
        self.updateTime = [coder decodeDoubleForKey:@"updateTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.value forKey:@"value"];
    [coder encodeDouble:self.updateTime forKey:@"updateTime"];
}

@end
