//
//  AIFeatureStep2Item.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep2Item.h"

@implementation AIFeatureStep2Item

+(AIFeatureStep2Item*) new:(NSInteger)absPId absAtConRect:(CGRect)absAtConRect {
    AIFeatureStep2Item *result = [[AIFeatureStep2Item alloc] init];
    result.absPId = absPId;
    result.absAtConRect = absAtConRect;
    return result;
}

@end
