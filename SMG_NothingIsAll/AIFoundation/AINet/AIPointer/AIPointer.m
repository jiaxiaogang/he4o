//
//  AIPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@interface AIPointer ()

@end

@implementation AIPointer

/**
 *  MARK:--------------------public--------------------
 */
-(BOOL) isEqual:(AIPointer*)object{//重写指针对比地址方法;
    if (POINTERISOK(object)) {
        //1. 对比pointerId
        BOOL pointerIdEqual = (self.pointerId == object.pointerId);
        //2. 对比params
        if (pointerIdEqual && self.params.count == object.params.count) {
            for (NSString *key in self.params.allKeys) {
                BOOL itemEqual = [STRTOOK([self.params objectForKey:key]) isEqualToString:[object.params objectForKey:key]];
                if (!itemEqual) {
                    return false;//发现不同
                }
            }
        }
        //3. params相同时返回pointerIdEqual
        return pointerIdEqual;
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

@end
