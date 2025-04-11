//
//  AIFeatureStep2Item_ScaleDelta.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep2Item_ScaleDelta.h"

@implementation AIFeatureStep2Item_ScaleDelta

+(AIFeatureStep2Item_ScaleDelta*) new:(NSInteger)absPId scale:(CGFloat)scale delta:(CGPoint)delta {
    AIFeatureStep2Item_ScaleDelta *result = [AIFeatureStep2Item_ScaleDelta new];
    result.absPId = absPId;
    result.scale = scale;
    result.delta = delta;
    return result;
}

@end
