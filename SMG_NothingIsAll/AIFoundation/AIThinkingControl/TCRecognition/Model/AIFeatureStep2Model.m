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
    result.rectItems = [NSMutableArray new];
    return result;
}

//MARK:===============================================================
//MARK:                     < RectItem组 >
//MARK:===============================================================
-(void) updateRectItem:(NSInteger)absPId absAtConRect:(CGRect)absAtConRect {
    [self.rectItems addObject:[AIFeatureStep2Item_Rect new:absPId absAtConRect:absAtConRect]];
}

-(CGRect) getRectItem:(NSInteger)absPId {
    for (AIFeatureStep2Item_Rect *item in self.rectItems) {
        if (item.absPId == absPId) return item.absAtConRect;
    }
    return CGRectNull;
}

//MARK:===============================================================
//MARK:                     < ScalaDeltaItem组 >
//MARK:===============================================================
-(void) convertRectItems2ScalaDeltaItems:(AIFeatureStep2Model*)protoModel {
    //1. 将rectItems转成scalaDeltaItems。
    self.scalaDeltaItems = [SMGUtils convertArr:self.rectItems convertBlock:^id(AIFeatureStep2Item_Rect *obj) {
        
        //2. 取出abs在proto和ass中的范围。
        CGRect protoRect = [protoModel getRectItem:obj.absPId];
        CGRect assRect = obj.absAtConRect;
        if (CGRectIsNull(protoRect)) return nil;
        
        //3. 计算缩放scale、deltaX、deltaY。
        CGFloat scala = assRect.size.width / (float)protoRect.size.width;
        CGFloat assX = scala > 0 ? assRect.origin.x / scala : 0;
        CGFloat assY = scala > 0 ? assRect.origin.y / scala : 0;
        CGFloat deltaX = assX - protoRect.origin.x;
        CGFloat deltaY = assY - protoRect.origin.y;
        
        //4. 转为scaleDeltaItem并收集。
        return [AIFeatureStep2Item_ScalaDelta new:obj.absPId scala:scala delta:CGPointMake(deltaX, deltaY)];
    }];
}

@end
