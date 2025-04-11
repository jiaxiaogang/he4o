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
//MARK:                     < ScaleDeltaItem组 >
//MARK:===============================================================
-(void) convertRectItems2ScaleDeltaItems:(AIFeatureStep2Model*)protoModel {
    //=============== step1: 缩放对齐 ===============
    //1. 比例排序。
    NSArray *scaleSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self scale4RectItemAtProto:protoModel rectItem:obj];
    }];
    
    //2. 掐头去尾。
    NSArray *scaleValid = ARR_SUB(scaleSort, scaleSort.count * 0.1, scaleSort.count * 0.8);
    
    //3. 求平均scale。
    CGFloat pinJunScale = scaleValid.count == 0 ? 0 : [SMGUtils sumOfArr:scaleValid convertBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self scale4RectItemAtProto:protoModel rectItem:obj];
    }] / scaleValid.count;
    
    //4. 缩放对齐。
    for (AIFeatureStep2Item_Rect *item in self.rectItems) {
        item.rect = CGRectMake(item.rect.origin.x / pinJunScale,item.rect.origin.y / pinJunScale,item.rect.size.width / pinJunScale, item.rect.size.height / pinJunScale);
    }
    
    //=============== step2: DeltaX对齐 ===============
    //11. 缩放对齐后，然后根据deltaX排序。
    NSArray *deltaXSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaX4RectItemAtProto:protoModel rectItem:obj];
    }];
    
    //12. 掐头去尾。
    NSArray *deltaXValid = ARR_SUB(deltaXSort, deltaXSort.count * 0.1, deltaXSort.count * 0.8);
    
    //13. 求平均deltaX。
    CGFloat pinJunDelteX = deltaXValid.count == 0 ? 0 : [SMGUtils sumOfArr:deltaXValid convertBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaX4RectItemAtProto:protoModel rectItem:obj];
    }] / deltaXValid.count;
    
    //14. deltaX对齐。
    for (AIFeatureStep2Item_Rect *item in self.rectItems) {
        item.rect = CGRectMake(item.rect.origin.x - pinJunDelteX, item.rect.origin.y,item.rect.size.width, item.rect.size.height);
    }
    
    //=============== step3: DeltaY对齐 ===============
    //21. 缩放对齐后，然后根据deltaX排序。
    NSArray *deltaYSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaY4RectItemAtProto:protoModel rectItem:obj];
    }];
    
    //22. 掐头去尾。
    NSArray *deltaYValid = ARR_SUB(deltaYSort, deltaYSort.count * 0.1, deltaYSort.count * 0.8);
    
    //23. 求平均deltaY。
    CGFloat pinJunDelteY = deltaYValid.count == 0 ? 0 : [SMGUtils sumOfArr:deltaYValid convertBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaY4RectItemAtProto:protoModel rectItem:obj];
    }] / deltaYValid.count;
    
    //24. deltaY对齐。
    for (AIFeatureStep2Item_Rect *item in self.rectItems) {
        item.rect = CGRectMake(item.rect.origin.x, item.rect.origin.y - pinJunDelteY,item.rect.size.width, item.rect.size.height);
    }
    
    //=============== step4: 求三个相近度 ===============
    //31. 找出与proto最大的差距(span)值。
    
    //32. 根据item与proto的差距 / 最大差距 = 得出相近度。
    
}

-(void) rankScanaDeltaItems {
    
}

//MARK:===============================================================
//MARK:                     < PrivateMethod >
//MARK:===============================================================

//返回 rectItem 在 conAssT 与 protoT 的缩放比例。
-(CGFloat) scale4RectItemAtProto:(AIFeatureStep2Model*)protoModel rectItem:(AIFeatureStep2Item_Rect*)rectItem {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absPId];
    CGRect conAssRect = rectItem.rect;
    
    //2. 计算缩放scale。
    return conAssRect.size.width / (float)protoRect.size.width;
}

//返回 rectItem 在 conAssT 与 protoT 的deltaX偏移量。
-(CGFloat) deltaX4RectItemAtProto:(AIFeatureStep2Model*)protoModel rectItem:(AIFeatureStep2Item_Rect*)rectItem {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absPId];
    
    //2. 计算result。
    return rectItem.rect.origin.x - protoRect.origin.x;
}

//返回 rectItem 在 conAssT 与 protoT 的deltaY偏移量。
-(CGFloat) deltaY4RectItemAtProto:(AIFeatureStep2Model*)protoModel rectItem:(AIFeatureStep2Item_Rect*)rectItem {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absPId];
    
    //2. 计算result。
    return rectItem.rect.origin.y - protoRect.origin.y;
}

@end
