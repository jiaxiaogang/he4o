//
//  AIFeatureZenTiItem.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureZenTiItem_Rect.h"

@implementation AIFeatureZenTiItem_Rect

+(AIFeatureZenTiItem_Rect*) new:(AIKVPointer*)absT absAtConRect:(CGRect)absAtConRect {
    AIFeatureZenTiItem_Rect *result = [[AIFeatureZenTiItem_Rect alloc] init];
    result.absT = absT;
    result.absAtConRect = absAtConRect;
    result.rect = absAtConRect;
    return result;
}

@end
