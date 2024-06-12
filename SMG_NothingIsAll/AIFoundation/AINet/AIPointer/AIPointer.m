//
//  AIPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@implementation AIPointer

/**
 *  MARK:--------------------public--------------------
 */
-(BOOL) isEqual:(AIPointer*)object{//重写指针对比地址方法;
    if (POINTERISOK(object)) {
        //0. 现在mv有两种节点类型,可能是M也可能是A,所以此处兼容一下,只要algsType和urgent一致,则返回true;
        //注: 等以后M彻底废弃改用A了,此处可去掉
        if ((self.pointerId == 1 && object.pointerId == 13) || (self.pointerId == 13 && object.pointerId == 1)) {
            NSLog(@"TODOTOMORROW20240612: 判断一下二者,能返回true");
        }
        
        //1. 对比
        if (self.pointerId == object.pointerId && self.params.count == object.params.count) {
            for (NSString *key in self.params.allKeys) {
                BOOL itemEqual = STRTOOK([self.params objectForKey:key]).hash == STRTOOK([object.params objectForKey:key]).hash;
                if (!itemEqual) {
                    return false;//发现不同
                }
            }
            return true;//未发现不同,全一样;
        }
    }
    return false;
}

-(NSMutableDictionary *)params{
    if (_params == nil) {
        _params = [[NSMutableDictionary alloc] init];
    }
    return _params;
}

-(NSString*) filePath{
    return STRFORMAT(@"%@_%ld",self.params,(long)self.pointerId);
}

-(NSString*) identifier{
    return STRFORMAT(@"%@",self.params);
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointerId = [aDecoder decodeIntegerForKey:@"pointerId"];
        self.params = [aDecoder decodeObjectForKey:@"params"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.pointerId forKey:@"pointerId"];
    [aCoder encodeObject:self.params forKey:@"params"];
}

-(id) paramForKey:(NSString*)key{
    return [DICTOOK(self.params) objectForKey:STRTOOK(key)];
}

/**
 *  MARK:--------------------NSCopying--------------------
 */
- (id)copyWithZone:(NSZone __unused *)zone {
    AIPointer *copy = [[AIPointer alloc] init];
    copy.pointerId = self.pointerId;
    copy.params = self.params;
    return copy;
}

@end
