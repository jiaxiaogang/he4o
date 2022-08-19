//
//  AIMatchFoModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/23.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIMatchFoModel.h"

@implementation AIMatchFoModel

+(AIMatchFoModel*) newWithMatchFo:(AIKVPointer*)matchFo maskFo:(AIKVPointer*)maskFo matchFoValue:(CGFloat)matchFoValue colStableScore:(CGFloat)colStableScore indexDic:(NSDictionary*)indexDic cutIndex:(NSInteger)cutIndex{
    AIMatchFoModel *model = [[AIMatchFoModel alloc] init];
    model.matchFo = matchFo;
    model.maskFo = maskFo;
    model.matchFoValue = matchFoValue;
    model.colStableScore = colStableScore;
    model.indexDic = indexDic;
    model.cutIndex2 = cutIndex;
    model.scoreCache = defaultScore; //评分缓存默认值;
    return model;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.matchFo = [aDecoder decodeObjectForKey:@"matchFo"];
        self.maskFo = [aDecoder decodeObjectForKey:@"maskFo"];
        self.matchFoValue = [aDecoder decodeFloatForKey:@"matchFoValue"];
        self.colStableScore = [aDecoder decodeFloatForKey:@"colStableScore"];
        self.status = [aDecoder decodeIntegerForKey:@"status"];
        self.indexDic = [aDecoder decodeObjectForKey:@"indexDic"];
        self.cutIndex2 = [aDecoder decodeIntegerForKey:@"cutIndex2"];
        self.matchFoStrong = [aDecoder decodeIntegerForKey:@"matchFoStrong"];
        self.scoreCache = [aDecoder decodeFloatForKey:@"scoreCache"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.matchFo forKey:@"matchFo"];
    [aCoder encodeObject:self.maskFo forKey:@"maskFo"];
    [aCoder encodeFloat:self.matchFoValue forKey:@"matchFoValue"];
    [aCoder encodeFloat:self.colStableScore forKey:@"colStableScore"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeObject:self.indexDic forKey:@"indexDic"];
    [aCoder encodeInteger:self.cutIndex2 forKey:@"cutIndex2"];
    [aCoder encodeInteger:self.matchFoStrong forKey:@"matchFoStrong"];
    [aCoder encodeFloat:self.scoreCache forKey:@"scoreCache"];
}

@end
