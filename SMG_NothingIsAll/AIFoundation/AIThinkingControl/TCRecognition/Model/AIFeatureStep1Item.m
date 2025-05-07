//
//  AIFeatureStep1Item.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/7.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep1Item.h"

@implementation AIFeatureStep1Item

+(id) new:(CGRect)bestGVAtProtoTRect matchValue:(CGFloat)matchValue matchDegree:(CGFloat)matchDegree {
    AIFeatureStep1Item *result = [AIFeatureStep1Item new];
    result.bestGVAtProtoTRect = bestGVAtProtoTRect;
    result.matchValue = matchValue;
    result.matchDegree = matchDegree;
    return result;
}

@end
