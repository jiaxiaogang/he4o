//
//  AIFeatureZenTiModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureZenTiModel.h"

@implementation AIFeatureZenTiModel

+(AIFeatureZenTiModel*) new:(AIKVPointer*)conT {
    AIFeatureZenTiModel *result = [[AIFeatureZenTiModel alloc] init];
    result.conT = conT;
    result.rectItems = [NSMutableArray new];
    return result;
}

//MARK:===============================================================
//MARK:                     < 收集数据组 >
//MARK:===============================================================
-(void) updateRectItem:(AIKVPointer*)absT absAtConRect:(CGRect)absAtConRect {
    [self.rectItems addObject:[AIFeatureZenTiItem_Rect new:absT absAtConRect:absAtConRect]];
}

-(CGRect) getRectItem:(AIKVPointer*)absT {
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        if ([item.absT isEqual:absT]) return item.rect;
    }
    return CGRectNull;
}

//MARK:===============================================================
//MARK:                     < 计算位置符合度组 >
//MARK:===============================================================
-(void) run4MatchDegree:(AIFeatureZenTiModel*)protoModel {
    //0. 存下protoT来，类比时要用下。
    self.protoT = protoModel.conT;
    
    //=============== step1: 缩放对齐（参考34136-TODO1）===============
    //1. 比例排序。
    NSArray *scaleSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return [self scale4RectItemAtProto:protoModel rectItem:obj];
    }];
    
    //2. 掐头去尾。
    NSArray *scaleValid = scaleSort.count > 3 ? ARR_SUB(scaleSort, scaleSort.count * 0.1, scaleSort.count * 0.8) : scaleSort;
    
    //3. 求平均scale。
    CGFloat pinJunScale = scaleValid.count == 0 ? 0 : [SMGUtils sumOfArr:scaleValid convertBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return [self scale4RectItemAtProto:protoModel rectItem:obj];
    }] / scaleValid.count;
    
    //4. 缩放对齐。
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        item.rect = CGRectMake(item.rect.origin.x / pinJunScale,item.rect.origin.y / pinJunScale,item.rect.size.width / pinJunScale, item.rect.size.height / pinJunScale);
    }
    
    //=============== step2: DeltaX对齐（参考34136-TODO2）===============
    //11. 缩放对齐后，然后根据deltaX排序。
    NSArray *deltaXSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return [self deltaX4RectItemAtProto:protoModel rectItem:obj];
    }];
    
    //12. 掐头去尾。
    NSArray *deltaXValid = deltaXSort.count > 3 ? ARR_SUB(deltaXSort, deltaXSort.count * 0.1, deltaXSort.count * 0.8) : deltaXSort;
    
    //13. 求平均deltaX。
    CGFloat pinJunDelteX = deltaXValid.count == 0 ? 0 : [SMGUtils sumOfArr:deltaXValid convertBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return [self deltaX4RectItemAtProto:protoModel rectItem:obj];
    }] / deltaXValid.count;
    
    //14. deltaX对齐。
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        item.rect = CGRectMake(item.rect.origin.x - pinJunDelteX, item.rect.origin.y,item.rect.size.width, item.rect.size.height);
    }
    
    //=============== step3: DeltaY对齐（参考34136-TODO3）===============
    //21. 缩放对齐后，然后根据deltaX排序。
    NSArray *deltaYSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return [self deltaY4RectItemAtProto:protoModel rectItem:obj];
    }];
    
    //22. 掐头去尾。
    NSArray *deltaYValid = deltaYSort.count > 3 ? ARR_SUB(deltaYSort, deltaYSort.count * 0.1, deltaYSort.count * 0.8) : deltaYSort;
    
    //23. 求平均deltaY。
    CGFloat pinJunDelteY = deltaYValid.count == 0 ? 0 : [SMGUtils sumOfArr:deltaYValid convertBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return [self deltaY4RectItemAtProto:protoModel rectItem:obj];
    }] / deltaYValid.count;
    
    //24. deltaY对齐。
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        item.rect = CGRectMake(item.rect.origin.x, item.rect.origin.y - pinJunDelteY,item.rect.size.width, item.rect.size.height);
    }
    
    //=============== step4: 求三个相近度（参考34136-TODO4）===============
    //31. 找出与proto最大的差距(span)值。
    CGFloat scaleMin = 99999999,scaleMax = -99999999;
    CGFloat deltaXMin = 99999999,deltaXMax = -99999999;
    CGFloat deltaYMin = 99999999,deltaYMax = -99999999;
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        CGFloat itemScale = [self scale4RectItemAtProto:protoModel rectItem:item];
        CGFloat itemDeltaX = [self deltaX4RectItemAtProto:protoModel rectItem:item];
        CGFloat itemDeltaY = [self deltaY4RectItemAtProto:protoModel rectItem:item];
        if (scaleMin > itemScale) scaleMin = itemScale;
        if (scaleMax < itemScale) scaleMax = itemScale;
        if (deltaXMin > itemDeltaX) deltaXMin = itemDeltaX;
        if (deltaXMax < itemDeltaX) deltaXMax = itemDeltaX;
        if (deltaYMin > itemDeltaY) deltaYMin = itemDeltaY;
        if (deltaYMax < itemDeltaY) deltaYMax = itemDeltaY;
    }
    CGFloat scaleSpan = scaleMax - scaleMin;
    CGFloat deltaXSpan = deltaXMax - deltaXMin;
    CGFloat deltaYSpan = deltaYMax - deltaYMin;
    
    //32. 根据item与proto的差距 / 最大差距 = 得出相近度。
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        CGFloat itemScale = [self scale4RectItemAtProto:protoModel rectItem:item];
        CGFloat itemDeltaX = [self deltaX4RectItemAtProto:protoModel rectItem:item];
        CGFloat itemDeltaY = [self deltaY4RectItemAtProto:protoModel rectItem:item];
        item.scaleMatchValue = 1 - (scaleSpan == 0 ? 0 : fabs(itemScale - 1) / scaleSpan);
        item.deltaXMatchValue = 1 - (deltaXSpan == 0 ? 0 : fabs(itemDeltaX) / deltaXSpan);
        item.deltaYMatchValue = 1 - (deltaYSpan == 0 ? 0 : fabs(itemDeltaY) / deltaYSpan);
    }
    
    //=============== step5: 该assT与protoT的这一块局部特征的“位置符合度” = 三个要素乘积（参考34136-TODO5）===============
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        item.itemMatchDegree = item.scaleMatchValue * item.deltaXMatchValue * item.deltaYMatchValue;
    }
    
    //=============== step6: 求当前assModel的综合位置符合度（参考34136-TODO6）===============
    self.modelMatchDegree = self.rectItems.count == 0 ? 0 : [SMGUtils sumOfArr:self.rectItems convertBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return obj.itemMatchDegree;
    }] / self.rectItems.count;
}

-(void) run4MatchValue:(AIKVPointer*)protoT {
    //0. 存下protoT来，类比时要用下。
    self.protoT = protoT;
    
    //1. self就是protoT时，直接设为匹配度1。
    if ([self.conT isEqual:protoT]) {
        self.modelMatchValue = 1;
        return;
    }
    
    //2. 别的assT则计算综合平均匹配度。
    for (AIFeatureZenTiItem_Rect *item in self.rectItems) {
        AIFeatureNode *absT = [SMGUtils searchNode:item.absT];
        
        //3. assT与absT的匹配度 * assT与protoT的匹配度 = assT与protoT的匹配度。
        item.itemMatchValue = [absT getConMatchValue:self.conT] * [absT getConMatchValue:protoT];
    }
    
    //4. 求出整体特征：assT 与 protoT 的综合匹配度。
    self.modelMatchValue = self.rectItems.count == 0 ? 0 : [SMGUtils sumOfArr:self.rectItems convertBlock:^double(AIFeatureZenTiItem_Rect *obj) {
        return obj.itemMatchValue;
    }] / self.rectItems.count;
}

//MARK:===============================================================
//MARK:                     < PrivateMethod >
//MARK:===============================================================

//返回 rectItem 在 conAssT 与 protoT 的缩放比例。
-(CGFloat) scale4RectItemAtProto:(AIFeatureZenTiModel*)protoModel rectItem:(AIFeatureZenTiItem_Rect*)rectItem {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absT];
    CGRect conAssRect = rectItem.rect;
    
    //2. 计算缩放scale。
    return protoRect.size.width == 0 ? : conAssRect.size.width / (float)protoRect.size.width;
}

//返回 rectItem 在 conAssT 与 protoT 的deltaX偏移量。
-(CGFloat) deltaX4RectItemAtProto:(AIFeatureZenTiModel*)protoModel rectItem:(AIFeatureZenTiItem_Rect*)rectItem {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absT];
    
    //2. 计算result。
    return rectItem.rect.origin.x - protoRect.origin.x;
}

//返回 rectItem 在 conAssT 与 protoT 的deltaY偏移量。
-(CGFloat) deltaY4RectItemAtProto:(AIFeatureZenTiModel*)protoModel rectItem:(AIFeatureZenTiItem_Rect*)rectItem {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absT];
    
    //2. 计算result。
    return rectItem.rect.origin.y - protoRect.origin.y;
}

@end
