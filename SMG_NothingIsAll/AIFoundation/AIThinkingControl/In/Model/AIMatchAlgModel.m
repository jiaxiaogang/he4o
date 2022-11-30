//
//  AIMatchAlgModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/1/15.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AIMatchAlgModel.h"

@implementation AIMatchAlgModel

//+(AIMatchAlgModel*) newWithMatchAlg:(AIKVPointer*)matchAlg matchCount:(int)matchCount sumNear:(CGFloat)sumNear nearCount:(int)nearCount sumRefStrong:(int)sumRefStrong{
//    AIMatchAlgModel *model = [[AIMatchAlgModel alloc] init];
//    model.matchCount = matchCount;
//    model.matchAlg = matchAlg;
//    model.sumNear = sumNear;
//    model.nearCount = nearCount;
//    model.sumRefStrong = sumRefStrong;
//    return model;
//}

/**
 *  MARK:--------------------获取相近度--------------------
 */
-(CGFloat) matchValue {
    return self.nearCount > 0 ? self.sumNear / self.nearCount : 1;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.matchAlg = [aDecoder decodeObjectForKey:@"matchAlg"];
        self.matchCount = [aDecoder decodeIntForKey:@"matchCount"];
        self.sumNear = [aDecoder decodeFloatForKey:@"sumNear"];
        self.nearCount = [aDecoder decodeIntForKey:@"nearCount"];
        self.sumRefStrong = [aDecoder decodeIntForKey:@"sumRefStrong"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.matchAlg forKey:@"matchAlg"];
    [aCoder encodeInt:self.matchCount forKey:@"matchCount"];
    [aCoder encodeFloat:self.sumNear forKey:@"sumNear"];
    [aCoder encodeInt:self.nearCount forKey:@"nearCount"];
    [aCoder encodeInt:self.sumRefStrong forKey:@"sumRefStrong"];
}

@end
