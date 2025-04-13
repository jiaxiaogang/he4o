//
//  AIFeatureStep2Item.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep2Item_Rect.h"

@implementation AIFeatureStep2Item_Rect

+(AIFeatureStep2Item_Rect*) new:(AIKVPointer*)absT absAtConRect:(CGRect)absAtConRect {
    AIFeatureStep2Item_Rect *result = [[AIFeatureStep2Item_Rect alloc] init];
    result.absT = absT;
    result.absAtConRect = absAtConRect;
    result.rect = absAtConRect;
    return result;
}

@end
