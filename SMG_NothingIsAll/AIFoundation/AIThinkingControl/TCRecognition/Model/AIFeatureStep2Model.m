//
//  AIFeatureStep2Model.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep2Model.h"

@implementation AIFeatureStep2Model

+(AIFeatureStep2Model*) new:(NSInteger)conPId {
    AIFeatureStep2Model *result = [[AIFeatureStep2Model alloc] init];
    result.conPId = conPId;
    result.items = [NSMutableArray new];
    return result;
}

-(void) updateItem:(NSInteger)absPId absAtConRect:(CGRect)absAtConRect {
    [self.items addObject:[AIFeatureStep2Item new:absPId absAtConRect:absAtConRect]];
}

-(CGRect) getItemRect:(NSInteger)absPId {
    for (AIFeatureStep2Item *item in self.items) {
        if (item.absPId == absPId) return item.absAtConRect;
    }
    return CGRectNull;
}

@end
