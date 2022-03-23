//
//  AIMatchFoModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/23.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIMatchFoModel.h"

@implementation AIMatchFoModel

+(AIMatchFoModel*) newWithMatchFo:(AIFoNodeBase*)matchFo matchFoValue:(CGFloat)matchFoValue lastMatchIndex:(NSInteger)lastMatchIndex cutIndex:(NSInteger)cutIndex{
    AIMatchFoModel *model = [[AIMatchFoModel alloc] init];
    model.matchFo = matchFo;
    model.matchFoValue = matchFoValue;
    model.lastMatchIndex = lastMatchIndex;
    model.cutIndex2 = cutIndex;
    return model;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.matchFo = [aDecoder decodeObjectForKey:@"matchFo"];
        self.matchFoValue = [aDecoder decodeFloatForKey:@"matchFoValue"];
        self.status = [aDecoder decodeIntegerForKey:@"status"];
        self.lastMatchIndex = [aDecoder decodeIntegerForKey:@"lastMatchIndex"];
        self.cutIndex2 = [aDecoder decodeIntegerForKey:@"cutIndex2"];
        self.matchFoStrong = [aDecoder decodeIntegerForKey:@"matchFoStrong"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.matchFo forKey:@"matchFo"];
    [aCoder encodeFloat:self.matchFoValue forKey:@"matchFoValue"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeInteger:self.lastMatchIndex forKey:@"lastMatchIndex"];
    [aCoder encodeInteger:self.cutIndex2 forKey:@"cutIndex2"];
    [aCoder encodeInteger:self.matchFoStrong forKey:@"matchFoStrong"];
}

@end
