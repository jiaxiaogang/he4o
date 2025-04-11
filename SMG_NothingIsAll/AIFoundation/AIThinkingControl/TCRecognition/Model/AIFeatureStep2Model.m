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
    
    //11. 统一缩放后，然后根据deltaX排序。
    NSArray *deltaXSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaX4RectItemAtProto:protoModel rectItem:obj pinJunScale:pinJunScale];
    }];
    
    //12. 掐头去尾。
    NSArray *deltaXValid = ARR_SUB(deltaXSort, deltaXSort.count * 0.1, deltaXSort.count * 0.8);
    
    //13. 求平均deltaX。
    CGFloat pinJunDelteX = deltaXValid.count == 0 ? 0 : [SMGUtils sumOfArr:deltaXValid convertBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaX4RectItemAtProto:protoModel rectItem:obj pinJunScale:pinJunScale];
    }] / deltaXValid.count;
    
    //21. 统一缩放后，然后根据deltaX排序。
    NSArray *deltaYSort = [SMGUtils sortSmall2Big:self.rectItems compareBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaY4RectItemAtProto:protoModel rectItem:obj pinJunScale:pinJunScale];
    }];
    
    //22. 掐头去尾。
    NSArray *deltaYValid = ARR_SUB(deltaYSort, deltaYSort.count * 0.1, deltaYSort.count * 0.8);
    
    //23. 求平均deltaY。
    CGFloat pinJunDelteY = deltaYValid.count == 0 ? 0 : [SMGUtils sumOfArr:deltaYValid convertBlock:^double(AIFeatureStep2Item_Rect *obj) {
        return [self deltaY4RectItemAtProto:protoModel rectItem:obj pinJunScale:pinJunScale];
    }] / deltaYValid.count;
    
    //31. 先缩放，后对齐，然后转换成AIFeatureStep2Item_ScaleDelta模型。
    
    
    
    
    //1. 将rectItems转成scaleDeltaItems。
    self.scaleDeltaItems = [SMGUtils convertArr:self.rectItems convertBlock:^id(AIFeatureStep2Item_Rect *obj) {
        
        //2. 取出abs在proto和ass中的范围。
        CGRect protoRect = [protoModel getRectItem:obj.absPId];
        CGRect assRect = obj.absAtConRect;
        if (CGRectIsNull(protoRect)) return nil;
        
        //3. 计算缩放scale、deltaX、deltaY。
        CGFloat scale = assRect.size.width / (float)protoRect.size.width;
        CGFloat assX = scale > 0 ? assRect.origin.x / scale : 0;
        CGFloat assY = scale > 0 ? assRect.origin.y / scale : 0;
        CGFloat deltaX = assX - protoRect.origin.x;
        CGFloat deltaY = assY - protoRect.origin.y;
        
        //4. 转为scaleDeltaItem并收集。
        return [AIFeatureStep2Item_ScaleDelta new:obj.absPId scale:scale delta:CGPointMake(deltaX, deltaY)];
    }];
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
    CGRect conAssRect = rectItem.absAtConRect;
    
    //2. 计算缩放scale。
    return conAssRect.size.width / (float)protoRect.size.width;
}

//返回 rectItem 在 conAssT 与 protoT 的deltaX偏移量。
-(CGFloat) deltaX4RectItemAtProto:(AIFeatureStep2Model*)protoModel rectItem:(AIFeatureStep2Item_Rect*)rectItem pinJunScale:(CGFloat)pinJunScale {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absPId];
    CGRect conAssRect = rectItem.absAtConRect;
    
    //2. 计算result。
    CGFloat conAssX = pinJunScale == 0 ? 0 : conAssRect.origin.x / pinJunScale;
    return conAssX - protoRect.origin.x;
}

//返回 rectItem 在 conAssT 与 protoT 的deltaY偏移量。
-(CGFloat) deltaY4RectItemAtProto:(AIFeatureStep2Model*)protoModel rectItem:(AIFeatureStep2Item_Rect*)rectItem pinJunScale:(CGFloat)pinJunScale {
    //1. 取出abs在proto和ass中的范围。
    CGRect protoRect = [protoModel getRectItem:rectItem.absPId];
    CGRect conAssRect = rectItem.absAtConRect;
    
    //2. 计算result。
    CGFloat conAssY = pinJunScale == 0 ? 0 : conAssRect.origin.y / pinJunScale;
    return conAssY - protoRect.origin.y;
}

@end
