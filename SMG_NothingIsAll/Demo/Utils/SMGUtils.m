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

@implementation SMGUtils

//MARK:===============================================================
//MARK:                     < 联想AILine点亮区域 >
//MARK:===============================================================
+(NSMutableArray*) lightArea_Vertical_1:(AIObject*)lightModel{
    return [self lightArea_Vertical:lightModel layerCount:1];
}
+(NSMutableArray*) lightArea_Vertical_2:(AIObject*)lightModel{
    return [self lightArea_Vertical:lightModel layerCount:2];
}

+(NSMutableArray*) lightArea_Vertical:(AIObject*)lightModel energy:(NSInteger)energy{
    return nil;
}

+(NSMutableArray*) lightArea_Vertical:(AIObject*)lightModel layerCount:(NSInteger)layerCount{
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    if (lightModel) {
        //0,取自己
        if (layerCount >= 0) {
            
        }
        
        //1,纵向取自己的抽象层
        if (layerCount >= 1) {
            //取是什么,能什么等常识知识;
        }
        
        //2,取抽象层的实例
        if (layerCount >= 2) {
            //根据AILine.Strong来取靠前的实例;
        }
    }
    return mArr;
}

//参考:N4P17-横向点亮
+(NSMutableArray*) lightArea_Horizontal:(AIObject*)lightModel{
    //参考:N4P18;通用的感觉算法
    if (lightModel) {
        //1,取10000个意识流数据
        NSMutableArray *sameClassArr = [[NSMutableArray alloc] init];
        NSArray *lines = nil;
        
        //2,找到当前类似的项
        
        //3,lightModel的AILine
        if (ARRISOK(lines)) {
            for (AILine *lightLine in lines) {
                
            }
        }else{
            //3,规律Law
            for (AIObject *sameObj in sameClassArr) {
                //AILineStore searchPointer:sameObj.pointer count:
            }
        }
    }
    return nil;
}

+(NSMutableArray*) lightArea_AILineTypeIsLawWithLightModels:(NSArray*)lightModels{
    
    if (ARRISOK(lightModels)) {
        //1,搜索其它相同网络
        NSMutableArray *pointers = [[NSMutableArray alloc] init];
        for (AIObject *lightModel in lightModels) {
            [pointers addObject:nil];
        }
        NSArray *lines = nil;
        
        //2,生成抽象AILaw数据
    }
    return nil;
}

+(void) lightArea_AILineTypeIsLaw:(ThinkModel*)thinkModel{
    if (thinkModel) {
        //1,纵向点亮 (收集Law)
        //有初始方向
        //无初始方向
    }
}

+(NSMutableArray*) lightArea_LightModels:(NSArray*)lightModels{
    
    if (ARRISOK(lightModels)) {
        //1,从CommonSence取包含的常识;
        
        //2,取10000个意识流数据
        
        //3,......
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < AILine >
//MARK:===============================================================
+(CGFloat) aiLine_GetLightEnergy:(CGFloat)strongValue{
    if (strongValue < 2) {
        return 1000;
    }else if(strongValue < 5){
        return 5;
    }else if(strongValue < 10){
        return 2;
    }else if(strongValue < 50){
        return 0.1f;
    }else if(strongValue < 100){
        return 0.01f;
    }else{
        return 0.001f;
    }
}


/**
 *  MARK:--------------------生产神经网络--------------------
 */
//+(AILine*) ailine_CreateLine:(NSArray*)aiObjs type:(AILineType)type{
//    if (ARRISOK(aiObjs)) {
//        //1. 创建网线并存
//        AILine *line = AIMakeLine(type, aiObjs);
//        [AILineStore insert:line];
//        //2. 插网线
//        if (ARRISOK(aiObjs)) {
//            for (AIObject *obj in aiObjs) {
//                if (ISOK(obj, AIObject.class)) {
//                    [obj connectLine:line save:true];
//                }
//            }
//        }
//        return line;
//    }else{
//        NSLog(@"_______SMGUtils.CreateLine.ERROR (pointersIsNil!)");
//        return nil;
//    }
//}

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

/**
 *  MARK:--------------------比较pA是否比pB大--------------------
 */
+(NSComparisonResult) comparePointerA:(AIKVPointer*)pA pointerB:(AIKVPointer*)pB{
    //1. 数据检查
    BOOL aIsOk = ISOK(pA, AIKVPointer.class);
    BOOL bIsOk = ISOK(pB, AIKVPointer.class);
    if (!aIsOk || !bIsOk) {
        return (aIsOk == bIsOk) ? NSOrderedSame : (aIsOk ? NSOrderedAscending : NSOrderedDescending);
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
            return [XGRedisUtil compareStrA:[NSString stringWithFormat:@"%@%@",pA.algsType,pA.dataSource] strB:[NSString stringWithFormat:@"%@%@",pB.algsType,pB.dataSource]];
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
        NSComparisonResult result = [NUMTOOK(aNum) compare:bNum];
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
            if (ISOK(pA.pointer, AIKVPointer.class)) {
                if (ISOK(pB.pointer, AIKVPointer.class)) {
                    if (pA.pointer.pointerId > pB.pointer.pointerId) {
                        return NSOrderedAscending;
                    }else if(pA.pointer.pointerId < pB.pointer.pointerId){
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

@end



@implementation SMGUtils (DB)

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

+(id) searchObjectForPointer:(AIKVPointer*)pointer fileName:(NSString*)fileName{
    return [self searchObjectForPointer:pointer fileName:fileName time:0];
}

+(id) searchObjectForPointer:(AIKVPointer*)pointer fileName:(NSString*)fileName time:(double)time{
    if (ISOK(pointer, AIKVPointer.class)) {
        //1. 优先取redis
        NSString *redisKey = STRFORMAT(@"%@/%@",pointer.filePath,fileName);
        id redisObj = [[XGRedis sharedInstance] objectForKey:redisKey];
        if (redisObj != nil) {
            return redisObj;
        }
        
        //2. 再取disk
        PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:pointer.filePath];
        id diskObj = [cache objectForKey:fileName];
        if (time > 0) {
            [[XGRedis sharedInstance] setObject:diskObj forKey:redisKey time:time];
        }
        return diskObj;
    }
    return nil;
}

+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName{
    [self insertObject:obj rootPath:rootPath fileName:fileName time:0];
}
+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName time:(double)time{
    //1. 存disk
    PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:STRTOOK(rootPath)];
    [cache setObject:obj forKey:STRTOOK(fileName)];
    
    //2. 存redis
    if (time > 0) {
        [[XGRedis sharedInstance] setObject:obj forKey:STRFORMAT(@"%@/%@",rootPath,fileName) time:time];
    }
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
