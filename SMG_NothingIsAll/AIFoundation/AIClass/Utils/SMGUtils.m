//
//  SMGUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/19.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "SMGUtils.h"
#import "AIKVPointer.h"
#import "PINCache.h"
#import "XGRedisUtil.h"
#import "AIPort.h"
#import "XGRedis.h"
#import "AIPointer.h"

@implementation SMGUtils


//MARK:===============================================================
//MARK:                     < AIPointer >
//MARK:===============================================================
+(NSInteger) createPointerId:(NSString*)algsType dataSource:(NSString*)dataSource{
    return [self createPointerId:true algsType:algsType dataSource:dataSource];
}

+(NSInteger) createPointerId:(BOOL)updateLastId algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    NSInteger lastId = [SMGUtils getLastNetNodePointerId:algsType dataSource:dataSource];
    if (updateLastId) {
        [SMGUtils setNetNodePointerId:1 algsType:algsType dataSource:dataSource];
    }
    return lastId + 1;
}

+(NSInteger) getLastNetNodePointerId:(NSString*)algsType dataSource:(NSString*)dataSource{
    return [[NSUserDefaults standardUserDefaults] integerForKey:STRFORMAT(@"AIPointer_LastNetNodePointerId_KEY_%@_%@",algsType,dataSource)];
}

+(void) setNetNodePointerId:(NSInteger)count algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    NSInteger lastPId = [self getLastNetNodePointerId:algsType dataSource:dataSource];
    [[NSUserDefaults standardUserDefaults] setInteger:lastPId + count forKey:STRFORMAT(@"AIPointer_LastNetNodePointerId_KEY_%@_%@",algsType,dataSource)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(AIKVPointer*) createPointerForNode:(NSString*)folderName {
    return [self createPointer:folderName algsType:@"" dataSource:@""];
}

+(AIKVPointer*) createPointer:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    NSInteger pointerId = [SMGUtils createPointerId:algsType dataSource:dataSource];
    AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:pointerId folderName:folderName algsType:algsType dataSource:dataSource];
    return kvPointer;
}

+(AIKVPointer*) createPointerForAbsValue:(NSString*)key{
    NSInteger pointerId = [SMGUtils createPointerId:@"" dataSource:STRTOOK(key)];
    return [self createPointerForAbsValue:key pointerId:pointerId];
}

+(AIKVPointer*) createPointerForAbsValue:(NSString*)key pointerId:(NSInteger)pointerId{
    AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_ABSVALUE algsType:@"" dataSource:STRTOOK(key)];
    return kvPointer;
}

//Direction的mv分区pointer;(存引用序列)
+(AIKVPointer*) createPointerForDirection:(NSString*)mvAlgsType direction:(MVDirection)direction{
    NSInteger pointerId = 0;
    AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_DIRECTION(direction) algsType:mvAlgsType dataSource:nil];
    return kvPointer;
}

//生成小脑node指针;
//+(AIKVPointer*) createPointerForOutputNode:(NSString*)algsType dataSource:(NSString*)dataSource{
//    NSInteger pointerId = [SMGUtils createPointerId:algsType dataSource:dataSource];
//    AIKVPointer *pointer = [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_ABS_NODE algsType:algsType dataSource:dataSource isOut:true];
//    return pointer;
//}

//生成indexValue的指针;
+(AIKVPointer*) createPointerForValue:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut{
    NSInteger pointerId = [self createPointerId:algsType dataSource:dataSource];
    return [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_VALUE algsType:algsType dataSource:dataSource isOut:isOut];
}

+(AIKVPointer*) createPointerForValue:(NSInteger)pointerId algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut{
    return [AIKVPointer newWithPointerId:pointerId folderName:PATH_NET_VALUE algsType:algsType dataSource:dataSource isOut:isOut];
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
    }
}

+(BOOL) compareArrayA:(NSArray*)arrA arrayB:(NSArray*)arrB{
    if (arrA == nil && arrB == nil) {
        return true;
    }else if(!ARRISOK(arrA) || !ARRISOK(arrB)){
        return false;
    }else{
        for (NSObject *itemA in arrA) {
            BOOL find = false;
            for (NSObject *itemB in arrB) {
                if ([itemA isEqual:itemB]) {
                    find = true;
                    break;
                }
            }
            if (!find) {
                return false;
            }
        }
        return true;
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

/**
 *  MARK:--------------------比较pA是否比pB大--------------------
 */
+(NSComparisonResult) comparePointerA:(AIPointer*)pA pointerB:(AIPointer*)pB{
    //1. 数据检查
    BOOL aIsOk = ISOK(pA, AIKVPointer.class);
    BOOL bIsOk = ISOK(pB, AIKVPointer.class);
    if (!aIsOk || !bIsOk) {
        return (aIsOk == bIsOk) ? NSOrderedAscending : (aIsOk ? NSOrderedAscending : NSOrderedDescending);
    }
    
    //2. 比较大小(一级比pointerId,二级比algsType,三级比dataSource)
    if ([pA isEqual:pB]) {
        return NSOrderedSame;
    }else{
        if (pA.pointerId > pB.pointerId) {
            return NSOrderedAscending;
        }else if(pA.pointerId < pB.pointerId){
            return NSOrderedDescending;
        }else{
            return [XGRedisUtil compareStrA:pA.identifier strB:pB.identifier];
        }
    }
}

/**
 *  MARK:--------------------比较refsA是否比refsB大--------------------
 */
+(NSComparisonResult) compareRefsA_p:(NSArray*)refsA_p refsB_p:(NSArray*)refsB_p{
    //1. 数据检查 & 准备
    refsA_p = ARRTOOK(refsA_p);
    refsB_p = ARRTOOK(refsB_p);
    NSInteger aLength = refsA_p.count;
    NSInteger bLength = refsB_p.count;
    
    //2. 比较大小
    for (NSInteger i = 0; i < MIN(aLength, bLength); i++) {
        AIKVPointer *itemA = ARR_INDEX(refsA_p, i);
        AIKVPointer *itemB = ARR_INDEX(refsB_p, i);
        NSNumber *aNum = [SMGUtils searchObjectForPointer:itemA fileName:FILENAME_Value];
        NSNumber *bNum = [SMGUtils searchObjectForPointer:itemB fileName:FILENAME_Value];
        NSComparisonResult result = [NUMTOOK(aNum) compare:NUMTOOK(bNum)] ;
        if (result != NSOrderedSame) {
            return result;
        }
    }
    
    //3. 前面都一样
    return aLength > bLength ? NSOrderedAscending : aLength < bLength ? NSOrderedDescending : NSOrderedSame;
}

//类比port:1级强度,2级pointerId;
+(NSComparisonResult) comparePortA:(AIPort*)pA portB:(AIPort*)pB{
    //1. 数据检查
    BOOL aIsOk = ISOK(pA, AIPort.class);
    BOOL bIsOk = ISOK(pB, AIPort.class);
    if (!aIsOk || !bIsOk) {
        return (aIsOk == bIsOk) ? NSOrderedSame : (aIsOk ? NSOrderedAscending : NSOrderedDescending);
    }
    
    //2. 比较大小(一级比pointerId,二级比algsType,三级比dataSource)
    if (pA.strong) {
        NSComparisonResult strongResult = [pA.strong compare:pB.strong];
        if (strongResult == NSOrderedSame) {
            if (ISOK(pA.target_p, AIKVPointer.class)) {
                if (ISOK(pB.target_p, AIKVPointer.class)) {
                    if (pA.target_p.pointerId > pB.target_p.pointerId) {
                        return NSOrderedAscending;
                    }else if(pA.target_p.pointerId < pB.target_p.pointerId){
                        return NSOrderedDescending;
                    }else{
                        return NSOrderedSame;
                    }
                }
            }else{
                return strongResult;
            }
        }else{
            return strongResult;
        }
    }
    return NSOrderedAscending;
}

/**
 *  MARK:--------------------比较intA是否比intB大--------------------
 */
+(NSComparisonResult) compareIntA:(NSInteger)intA intB:(NSInteger)intB{
    return intA > intB ? NSOrderedAscending : intA < intB ? NSOrderedDescending : NSOrderedSame;
}


/**
 *  MARK:--------------------比较floatA是否比floatB大--------------------
 */
+(NSComparisonResult) compareFloatA:(CGFloat)floatA floatB:(CGFloat)floatB{
    return floatA > floatB ? NSOrderedAscending : floatA < floatB ? NSOrderedDescending : NSOrderedSame;
}


@end



@implementation SMGUtils (DB)

/**
 *  MARK:--------------------SQL语句之rowId--------------------
 */
+(NSString*) sqlWhere_RowId:(NSInteger)rowid{
    return [NSString stringWithFormat:@"rowid='%ld'",(long)rowid];
}

//+(NSString*) sqlWhere_K:(id)columnName V:(id)value{
//    return [NSString stringWithFormat:@"%@='%@'",columnName,value];
//}
//
//+(NSDictionary*) sqlWhereDic_K:(id)columnName V:(id)value{
//    if (value) {
//        return [[NSDictionary alloc] initWithObjectsAndKeys:value,STRTOOK(columnName), nil];
//    }
//    return nil;
//}

+(id) searchObjectForPointer:(AIPointer*)pointer fileName:(NSString*)fileName{
    return [self searchObjectForPointer:pointer fileName:fileName time:0];
}

+(id) searchObjectForPointer:(AIPointer*)pointer fileName:(NSString*)fileName time:(double)time{
    if (ISOK(pointer, AIPointer.class)) {
        return [self searchObjectForFilePath:pointer.filePath fileName:fileName time:time];
    }
    return nil;
}

+(id) searchObjectForFilePath:(NSString*)filePath fileName:(NSString*)fileName time:(double)time{
    //1. 数据检查
    filePath = STRTOOK(filePath);
    
    //2. 优先取redis
    NSString *redisKey = STRFORMAT(@"%@/%@",filePath,fileName);//随后去掉前辍
    id redisObj = [[XGRedis sharedInstance] objectForKey:redisKey];
    if (redisObj != nil) {
        return redisObj;
    }
    
    //3. 再取disk
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:filePath];
    id diskObj = [cache objectForKey:fileName];
    if (time > 0 && diskObj) {
        [[XGRedis sharedInstance] setObject:diskObj forKey:redisKey time:time];
    }
    return diskObj;
}

+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName{
    [self insertObject:obj rootPath:rootPath fileName:fileName time:0];
}
+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName time:(double)time{
    //1. 存disk
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:STRTOOK(rootPath)];
    [cache setObject:obj forKey:STRTOOK(fileName)];
    
    //2. 存redis
    [[XGRedis sharedInstance] setObject:obj forKey:STRFORMAT(@"%@/%@",rootPath,fileName) time:time];//随后去掉(redisKey)前辍
}

@end



//MARK:===============================================================
//MARK:                     < MathUtils >
//MARK:===============================================================
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

//MARK:===============================================================
//MARK:                     < SMGUtils (Contains) >
//MARK:===============================================================
@implementation SMGUtils (Contains)

+(BOOL) containsSub_ps:(NSArray*)sub_ps parent_ps:(NSArray*)parent_ps{
    sub_ps = ARRTOOK(sub_ps);
    for (AIPointer *sub_p in sub_ps) {
        if (![self containsSub_p:sub_p parent_ps:parent_ps]) {
            return false;
        }
    }
    return true;
}

+(BOOL) containsSub_p:(AIPointer*)sub_p parent_ps:(NSArray*)parent_ps{
    if (ISOK(sub_p, AIPointer.class) && ARRISOK(parent_ps)) {
        for (AIPointer *parent_p in parent_ps) {
            if ([sub_p isEqual:parent_p]) {
                return true;
            }
        }
    }
    return false;
}

@end
