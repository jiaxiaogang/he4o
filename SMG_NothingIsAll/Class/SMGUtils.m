//
//  SMGUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGUtils.h"

@implementation SMGUtils

/**
 *  MARK:--------------------联想AILine点亮区域--------------------
 *  layerCount,节点层数;(0->自己)(1->自己和自己的抽象层)(2->自已,自己的抽象层,抽象层的其它实例,抽象层的抽象层)(>2:以此类推)
 */
+(NSMutableArray*) lightArea_1:(AIPointer*)lightPointer{
    return [self lightArea:lightPointer layerCount:1];
}
+(NSMutableArray*) lightArea_2:(AIPointer*)lightPointer{
    return [self lightArea:lightPointer layerCount:2];
}
+(NSMutableArray*) lightArea_3:(AIPointer*)lightPointer{
    return [self lightArea:lightPointer layerCount:3];
}
+(NSMutableArray*) lightArea:(AIPointer*)lightPointer layerCount:(NSInteger)layerCount{
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    if (lightPointer) {
        //0,取自己
        if (layerCount >= 0) {
            [mArr addObject:lightPointer];
        }
        
        //1,纵向取自己的抽象层
        if (layerCount >= 1) {
            [AICommonSenseStore searchSingleWhere:nil];
            
            
            [mArr addObject:lightPointer];
        }
        
        //2,取抽象层的实例
        if (layerCount >= 2) {
            if ([AILineStore searchWithSQL:nil]) {
                
            }
            [mArr addObject:lightPointer];
        }
    }
    return mArr;
}

@end


/**
 *  MARK:--------------------比较--------------------
 */
@implementation SMGUtils (Compare)

+(BOOL) compareItemA:(id)itemA itemB:(id)itemB{
    if (itemA == nil && itemB == nil) {
        return true;
    }else if(itemA == nil || itemB == nil || ![self compareKindClassWithItemA:itemA itemB:itemB]){
        return false;
    }else{
        if ([itemA isKindOfClass:[NSString class]]) {
            return [(NSString*)itemA isEqualToString:itemB];        //NSString
        }else if ([itemA isKindOfClass:[NSNumber class]]) {
            return [itemA isEqualToNumber:itemB];                   //NSNumber
        }else if ([itemA isKindOfClass:[NSValue class]]) {
            return [itemA isEqualToValue:itemB];                    //NSValue
        }else if ([itemA isKindOfClass:[NSArray class]]) {
            return [itemA isEqualToArray:itemB];                    //NSArray
        }else if ([itemA isKindOfClass:[NSDictionary class]]) {
            return [itemA isEqualToDictionary:itemB];               //NSDictionary
        }else if ([itemA isKindOfClass:[NSSet class]]) {
            return [itemA isEqualToSet:itemB];                      //NSSet
        }else if ([itemA isKindOfClass:[NSData class]]) {
            return [itemA isEqualToData:itemB];                     //NSData
        }else if ([itemA isKindOfClass:[NSDate class]]) {
            return [itemA isEqualToDate:itemB];                     //NSDate
        }else if ([itemA isKindOfClass:[NSAttributedString class]]) {
            return [itemA isEqualToAttributedString:itemB];         //NSAttributedString
        }else if ([itemA isKindOfClass:[NSIndexSet class]]) {
            return [itemA isEqualToIndexSet:itemB];                 //NSIndexSet
        }else if ([itemA isKindOfClass:[NSTimeZone class]]) {
            return [itemA isEqualToTimeZone:itemB];                 //NSTimeZone
        }else if ([itemA isKindOfClass:[NSHashTable class]]) {
            return [itemA isEqualToHashTable:itemB];                //NSHashTable
        }else if ([itemA isKindOfClass:[NSOrderedSet class]]) {
            return [itemA isEqualToOrderedSet:itemB];               //NSOrderedSet
        }else if ([itemA isKindOfClass:[NSDateInterval class]]) {
            return [itemA isEqualToDateInterval:itemB];             //NSDateInterval
        }else{
            return [itemA isEqual:itemB];                           //不识别的类型
        }
        //这里随后补上自定义的数据类型;例如feelModel 图片,声音等;
        //在自定义Model中实现重写isEqual:
    }
}


+(BOOL) compareItemA:(id)itemA containsItemB:(id)itemB{
    if (itemB == nil) {
        return true;
    }else if(itemA == nil || ![self compareKindClassWithItemA:itemA itemB:itemB]){
        return false;
    }else{
        if ([itemA isKindOfClass:[NSString class]]) {
            return [(NSString*)itemA containsString:itemB];        //NSString
        }else if ([itemA isKindOfClass:[NSArray class]]) {
            BOOL itemAContainsItemB = true;//默认true;查到一个不包含设为false;
            for (id bItem in itemB) {
                BOOL aItemContainsBItem = false;//默认fale;查到一个包含设为true;
                for (id aItem in itemA) {
                    if ([self compareItemA:aItem containsItemB:bItem]) {
                        aItemContainsBItem = true;
                        break;
                    }
                }
                if (!aItemContainsBItem) {
                    itemAContainsItemB = false;
                }
            }
            //return [itemA containsObject:itemB];
            return itemAContainsItemB;                    //NSArray
        }else if ([itemA isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in [(NSDictionary*)itemB allKeys]) { //NSDictionary
                if(![SMGUtils compareItemA:[(NSDictionary*)itemA objectForKey:key] containsItemB:[(NSDictionary*)itemB objectForKey:key]]){
                    return false;
                }
            }
            return true;
        }else if ([itemA isKindOfClass:[NSSet class]]) {
            return [itemA containsObject:itemB];                      //NSSet
        }else if ([itemA isKindOfClass:[NSDate class]]) {
            return [itemA containsDate:itemB];                     //NSDate
        }else if ([itemA isKindOfClass:[NSIndexSet class]]) {
            return [itemA containsIndexes:itemB];                 //NSIndexSet
        }else if ([itemA isKindOfClass:[NSHashTable class]]) {
            return [itemA containsObject:itemB];                //NSHashTable
        }else if ([itemA isKindOfClass:[NSOrderedSet class]]) {
            return [itemA containsObject:itemB];               //NSOrderedSet
        }else{
            return [SMGUtils compareItemA:itemA itemB:itemB];       //不识别的类型
        }
        //这里随后补上自定义的数据类型;例如feelModel 图片,声音等;
        //在自定义Model中实现重写isEqual:
    }
}


/**
 *  MARK:--------------------对比itemA和itemB是否有继承关系或同类型(NSObject除外)--------------------
 */
+(BOOL) compareKindClassWithItemA:(id)itemA itemB:(id)itemB{
    if (itemA == nil && itemB == nil) {
        return true;
    }else if(itemA == nil || itemB == nil){
        return false;
    }else{
        if ([itemA isKindOfClass:[NSArray class]]) {
            return [itemB isKindOfClass:[NSArray class]];
        }else if([itemA isKindOfClass:[NSString class]]){
            return [itemB isKindOfClass:[NSString class]];
        }else if([itemA isKindOfClass:[NSDictionary class]]){
            return [itemB isKindOfClass:[NSDictionary class]];
        }else{
            BOOL isSeem = ([itemA class] == [itemB class]);
            BOOL isKind = ([itemA isKindOfClass:[itemB class]] || [itemB isKindOfClass:[itemA class]]);
            return isSeem || isKind;
        }
    }
}

@end



@implementation DBUtils

/**
 *  MARK:--------------------SQL语句之rowId--------------------
 */
+(NSString*) sqlWhere_RowId:(NSInteger)rowid{
    return [NSString stringWithFormat:@"rowid='%ld'",(long)rowid];
}

+(NSString*) sqlWhere_K:(id)columnName V:(id)value{
    return [NSString stringWithFormat:@"%@='%@'",columnName,value];
}

+(NSDictionary*) sqlWhereDic_K:(id)columnName V:(id)value{
    if (value) {
        return [[NSDictionary alloc] initWithObjectsAndKeys:value,STRTOOK(columnName), nil];
    }
    return nil;
}

@end



@implementation MathUtils

+(CGFloat) getNegativeTen2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue{
    return [self getValueWithOriRange:oriRange targetRange:UIFloatRangeMake(-10, 10) oriValue:oriValue];
}
+(CGFloat) getZero2TenWithOriRange:(UIFloatRange)oriRange oriValue:(CGFloat)oriValue{
    return [self getValueWithOriRange:oriRange targetRange:UIFloatRangeMake(0, 10) oriValue:oriValue];
}
+(CGFloat) getValueWithOriRange:(UIFloatRange)oriRange targetRange:(UIFloatRange)targetRange oriValue:(CGFloat)oriValue{
    //1,数据范围检查;
    oriValue = MAX(oriValue, MIN(oriValue, oriRange.maximum));
    //2,checkValue所在的值
    CGFloat percent = 0;
    if (oriRange.minimum != oriValue) {
        percent = (oriValue - oriRange.minimum) / (oriRange.maximum - oriRange.minimum);
    }
    //3,返回变换值
    return (targetRange.maximum - targetRange.minimum) * percent + targetRange.minimum;
}

@end



@implementation FeelTextUtils

+(NSInteger) getLength:(NSString*)text{
    if (STRISOK(text)) {
        return text.length;
    }
    return 0;
}

@end



@implementation TextStoreUtils

/**
 *  MARK:--------------------获取句子中未知词数--------------------
 *
 *  参数:
 *      1,knowRangeArr: 扫描到的所有词
 *      2,fromIndex:    从哪里开始扫描(正反双向都扫)
 *      3,sentence:     句子
 *
 *  返回值:NSNumber数组
 *
 */
//+(NSArray*) getUnknownWordCount:(NSArray*)knowRangeArr fromIndex:(NSInteger)fromIndex withSentence:(NSString*)sentence{
//    //数据检查
//    NSMutableArray *valueArr = nil;
//
//    knowRangeArr = ARRTOOK(knowRangeArr);
//
//    fromIndex = MAX(fromIndex, 0);
//    fromIndex = MIN(sentence.length - 1, fromIndex);
//
//    if (!STRISOK(sentence)) return valueArr;
//
//    //向前找
//    for (NSUInteger i = fromIndex; i > 0; i--) {
//
//    }
//
//    //向后找
//    for (NSUInteger i = 0; i < knowRangeArr.count; <#increment#>) {
//
//    }
//    knowRangeArr[0];
//    if (knowRangeArr) {
//
//    }
//}

/**
 *  MARK:--------------------SMGRange_RemoveDuplicates--------------------
 */
////获取无重复noDupRangeArr
//+(NSMutableArray*) getNoDupRangeArr:(NSArray*)dupRangeArr fromIndex:(NSInteger)fromIndex{
//    //向前找
//
//    //向后找
//}

//获取包含index的最长的range
+(SMGRange*) getMaximumRangeFromRangeArr:(NSArray*)rangeArr containsIndex:(NSInteger)index {
    NSArray *containsIndexRangeArr = [self getRangeArrFromRangeArr:rangeArr containsIndex:index];
    if (ARRISOK(containsIndexRangeArr)) {
        SMGRange *curRange = nil;
        for (SMGRange *item in containsIndexRangeArr) {
            if (!curRange || curRange.length < item.length) {
                curRange = item;
            }
        }
        return curRange;
    }
    return nil;
}

//筛选出RangeArr中包含Index的;(RangeArr需要是有序的,否则找不全)
+(NSArray*) getRangeArrFromRangeArr:(NSArray*)rangeArr containsIndex:(NSInteger)index {
    NSMutableArray *valueArr = nil;
    if (ARRISOK(rangeArr)) {
        BOOL start = false;
        for (SMGRange *item in rangeArr) {
            if ([self containsIndex:index atRange:item]) {
                start = true;
                if (valueArr == nil) valueArr = [[NSMutableArray alloc] init];
                [valueArr addObject:item];
            }else{
                if (start) {
                    break;
                }
            }
        }
    }
    return valueArr;
}

/**
 *  MARK:--------------------ContainsIndex_AtRange--------------------
 */
//RangeArr是否包含Index(RangeArr需要是去重后的RangeArr)
+(BOOL) containsIndex:(NSInteger)index atRangeArr:(NSArray*)rangeArr{
    if (ARRISOK(rangeArr)) {
        for (SMGRange *range in rangeArr) {
            if ([self containsIndex:index atRange:range]) {
                return true;
            }
        }
    }
    return false;
}

//SMGRange是否包含Index
+(BOOL) containsIndex:(NSInteger)index atRange:(SMGRange*)range{
    return (range && index >= range.location && index < range.location + range.length);
}




@end


@implementation MindValueUtils

+(AIMindValueModel*) getMindValue_HungerLevelChanged:(AIHungerLevelChangedModel*)model{
    if (model == nil) return nil;
    
    CGFloat mVD = 0;
    if (model.state == HungerState_Unplugged) {
        mVD = [MathUtils getValueWithOriRange:UIFloatRangeMake(0, 100) targetRange:UIFloatRangeMake(-10, 0) oriValue:model.level * model.level];//(饿一滴血)
    }else if (model.state == HungerState_Charging) {//充电中
        mVD = [MathUtils getValueWithOriRange:UIFloatRangeMake(0, 100) targetRange:UIFloatRangeMake(10, 0) oriValue:model.level * model.level];//(饱一滴血)
    }
    
    //2,分析决策 & 产生需求
    AIMindValueModel *mindValue = [[AIMindValueModel alloc] init];
    mindValue.type = MindType_Hunger;
    mindValue.value = mVD;
    mindValue.sourcePointer = model.pointer;
    return mindValue;
}

//+(AIMindValueModel*) getMindValue_HungerStateChanged:(AIHungerStateChangedModel*)model{
//    CGFloat mVD = 0;
//    if (model.state == HungerState_Unplugged) {
//        mVD = [MathUtils getValueWithOriRange:UIFloatRangeMake(0, 100) targetRange:UIFloatRangeMake(-10, 0) oriValue:model.level * model.level];//(饿一滴血)
//    }else if (model.state == HungerState_Charging) {//充电中
//        mVD = [MathUtils getValueWithOriRange:UIFloatRangeMake(0, 100) targetRange:UIFloatRangeMake(10, 0) oriValue:model.level * model.level];//(饱一滴血)
//    }
//    
//    //2,分析决策 & 产生需求
//    AIMindValueModel *mindValue = [[AIMindValueModel alloc] init];
//    mindValue.type = MindType_Hunger;
//    mindValue.value = mVD;
//    return mindValue;
//}

@end
