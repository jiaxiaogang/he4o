//
//  AIFeatureStep2Item_ScalaDelta.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep2Item_ScalaDelta.h"

@implementation AIFeatureStep2Item_ScalaDelta

+(AIFeatureStep2Item_ScalaDelta*) new:(NSInteger)absPId scala:(CGFloat)scala delta:(CGPoint)delta {
    AIFeatureStep2Item_ScalaDelta *result = [AIFeatureStep2Item_ScalaDelta new];
    result.absPId = absPId;
    result.scala = scala;
    result.delta = delta;
    return result;
}

@end
