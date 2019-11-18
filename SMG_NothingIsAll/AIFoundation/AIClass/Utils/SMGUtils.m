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
#import "AIAlgNodeBase.h"
#import "XGWedis.h"

@implementation SMGUtils

//MARK:===============================================================
//MARK:                     < PointerId >
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

//MARK:===============================================================
//MARK:                     < AIPointer >
//MARK:===============================================================

//Node
+(AIKVPointer*) createPointerForNode:(NSString*)folderName{
    return [self createPointer:folderName algsType:DefaultAlgsType dataSource:DefaultDataSource isOut:false isMem:false];
}
+(AIKVPointer*) createPointer:(NSString*)folderName algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem{
    NSInteger pointerId = [SMGUtils createPointerId:algsType dataSource:dataSource];
    AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:pointerId folderName:folderName algsType:algsType dataSource:dataSource isOut:isOut isMem:isMem];
    return kvPointer;
}

//Direction的mv分区pointer;(存引用序列)
+(AIKVPointer*) createPointerForDirection:(NSString*)mvAlgsType direction:(MVDirection)direction{
    NSInteger pointerId = 0;
    AIKVPointer *kvPointer = [AIKVPointer newWithPointerId:pointerId folderName:kPN_DIRECTION((long)direction) algsType:mvAlgsType dataSource:DefaultDataSource isOut:false isMem:false];
    return kvPointer;
}

//生成小脑CanOut指针;
+(AIKVPointer*) createPointerForCerebelCanOut{
    AIKVPointer *pointer = [AIKVPointer newWithPointerId:0 folderName:kPN_CEREBEL_CANOUT algsType:DefaultAlgsType dataSource:DefaultDataSource isOut:false isMem:false];
    return pointer;
}

//生成indexValue的指针;
+(AIKVPointer*) createPointerForValue:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut{
    NSInteger pointerId = [self createPointerId:algsType dataSource:dataSource];
    return [AIKVPointer newWithPointerId:pointerId folderName:kPN_VALUE algsType:algsType dataSource:dataSource isOut:isOut isMem:false];
}

+(AIKVPointer*) createPointerForValue:(NSInteger)pointerId algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut{
    return [AIKVPointer newWithPointerId:pointerId folderName:kPN_VALUE algsType:algsType dataSource:dataSource isOut:isOut isMem:false];
}

+(AIKVPointer*) createPointerForIndex{
    NSInteger pointerId = 0;
    return [AIKVPointer newWithPointerId:pointerId folderName:kPN_INDEX algsType:DefaultAlgsType dataSource:DefaultDataSource isOut:false isMem:false];
}

+(AIKVPointer*) createPointerForData:(NSString*)algsType dataSource:(NSString*)dataSource{
    NSInteger pointerId = 0;
    return [AIKVPointer newWithPointerId:pointerId folderName:kPN_DATA algsType:algsType dataSource:dataSource isOut:false isMem:false];
}

+(AIKVPointer*) createPointerForAlg:(NSString*)folderName dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem{
    NSInteger pointerId = [SMGUtils createPointerId:DefaultAlgsType dataSource:dataSource];
    return [AIKVPointer newWithPointerId:pointerId folderName:folderName algsType:AlgNodeAlgsType(pointerId) dataSource:dataSource isOut:isOut isMem:isMem];
}

@end


/**
 *  MARK:--------------------比较--------------------
 */
@implementation SMGUtils (Compare)

//+(BOOL) compareItemA:(id)itemA itemB:(id)itemB{
//    if (itemA == nil && itemB == nil) {
//        return true;
//    }else if(itemA == nil || itemB == nil || ![self compareKindClassWithItemA:itemA itemB:itemB]){
//        return false;
//    }else{
//        if ([itemA isKindOfClass:[NSString class]]) {
//            return [(NSString*)itemA isEqualToString:itemB];        //NSString
//        }else if ([itemA isKindOfClass:[NSNumber class]]) {
//            return [itemA isEqualToNumber:itemB];                   //NSNumber
//        }else if ([itemA isKindOfClass:[NSValue class]]) {
//            return [itemA isEqualToValue:itemB];                    //NSValue
//        }else if ([itemA isKindOfClass:[NSArray class]]) {
//            return [itemA isEqualToArray:itemB];                    //NSArray
//        }else if ([itemA isKindOfClass:[NSDictionary class]]) {
//            return [itemA isEqualToDictionary:itemB];               //NSDictionary
//        }else if ([itemA isKindOfClass:[NSSet class]]) {
//            return [itemA isEqualToSet:itemB];                      //NSSet
//        }else if ([itemA isKindOfClass:[NSData class]]) {
//            return [itemA isEqualToData:itemB];                     //NSData
//        }else if ([itemA isKindOfClass:[NSDate class]]) {
//            return [itemA isEqualToDate:itemB];                     //NSDate
//        }else if ([itemA isKindOfClass:[NSAttributedString class]]) {
//            return [itemA isEqualToAttributedString:itemB];         //NSAttributedString
//        }else if ([itemA isKindOfClass:[NSIndexSet class]]) {
//            return [itemA isEqualToIndexSet:itemB];                 //NSIndexSet
//        }else if ([itemA isKindOfClass:[NSTimeZone class]]) {
//            return [itemA isEqualToTimeZone:itemB];                 //NSTimeZone
//        }else if ([itemA isKindOfClass:[NSHashTable class]]) {
//            return [itemA isEqualToHashTable:itemB];                //NSHashTable
//        }else if ([itemA isKindOfClass:[NSOrderedSet class]]) {
//            return [itemA isEqualToOrderedSet:itemB];               //NSOrderedSet
//        }else if ([itemA isKindOfClass:[NSDateInterval class]]) {
//            return [itemA isEqualToDateInterval:itemB];             //NSDateInterval
//        }else{
//            return [itemA isEqual:itemB];                           //不识别的类型
//        }
//    }
//}
//
//+(BOOL) compareArrayA:(NSArray*)arrA arrayB:(NSArray*)arrB{
//    if (arrA == nil && arrB == nil) {
//        return true;
//    }else if(!ARRISOK(arrA) || !ARRISOK(arrB)){
//        return false;
//    }else{
//        for (NSObject *itemA in arrA) {
//            BOOL find = false;
//            for (NSObject *itemB in arrB) {
//                if ([itemA isEqual:itemB]) {
//                    find = true;
//                    break;
//                }
//            }
//            if (!find) {
//                return false;
//            }
//        }
//        return true;
//    }
//}
//
//+(BOOL) compareItemA:(id)itemA containsItemB:(id)itemB{
//    if (itemB == nil) {
//        return true;
//    }else if(itemA == nil || ![self compareKindClassWithItemA:itemA itemB:itemB]){
//        return false;
//    }else{
//        if ([itemA isKindOfClass:[NSString class]]) {
//            return [(NSString*)itemA containsString:itemB];        //NSString
//        }else if ([itemA isKindOfClass:[NSArray class]]) {
//            BOOL itemAContainsItemB = true;//默认true;查到一个不包含设为false;
//            for (id bItem in itemB) {
//                BOOL aItemContainsBItem = false;//默认fale;查到一个包含设为true;
//                for (id aItem in itemA) {
//                    if ([self compareItemA:aItem containsItemB:bItem]) {
//                        aItemContainsBItem = true;
//                        break;
//                    }
//                }
//                if (!aItemContainsBItem) {
//                    itemAContainsItemB = false;
//                }
//            }
//            //return [itemA containsObject:itemB];
//            return itemAContainsItemB;                    //NSArray
//        }else if ([itemA isKindOfClass:[NSDictionary class]]) {
//            for (NSString *key in [(NSDictionary*)itemB allKeys]) { //NSDictionary
//                if(![SMGUtils compareItemA:[(NSDictionary*)itemA objectForKey:key] containsItemB:[(NSDictionary*)itemB objectForKey:key]]){
//                    return false;
//                }
//            }
//            return true;
//        }else if ([itemA isKindOfClass:[NSSet class]]) {
//            return [itemA containsObject:itemB];                      //NSSet
//        }else if ([itemA isKindOfClass:[NSDate class]]) {
//            return [itemA containsDate:itemB];                     //NSDate
//        }else if ([itemA isKindOfClass:[NSIndexSet class]]) {
//            return [itemA containsIndexes:itemB];                 //NSIndexSet
//        }else if ([itemA isKindOfClass:[NSHashTable class]]) {
//            return [itemA containsObject:itemB];                //NSHashTable
//        }else if ([itemA isKindOfClass:[NSOrderedSet class]]) {
//            return [itemA containsObject:itemB];               //NSOrderedSet
//        }else{
//            return [SMGUtils compareItemA:itemA itemB:itemB];       //不识别的类型
//        }
//    }
//}
//
//
///**
// *  MARK:--------------------对比itemA和itemB是否有继承关系或同类型(NSObject除外)--------------------
// */
//+(BOOL) compareKindClassWithItemA:(id)itemA itemB:(id)itemB{
//    if (itemA == nil && itemB == nil) {
//        return true;
//    }else if(itemA == nil || itemB == nil){
//        return false;
//    }else{
//        if ([itemA isKindOfClass:[NSArray class]]) {
//            return [itemB isKindOfClass:[NSArray class]];
//        }else if([itemA isKindOfClass:[NSString class]]){
//            return [itemB isKindOfClass:[NSString class]];
//        }else if([itemA isKindOfClass:[NSDictionary class]]){
//            return [itemB isKindOfClass:[NSDictionary class]];
//        }else{
//            BOOL isSeem = ([itemA class] == [itemB class]);
//            BOOL isKind = ([itemA isKindOfClass:[itemB class]] || [itemB isKindOfClass:[itemA class]]);
//            return isSeem || isKind;
//        }
//    }
//}


/**
 *  MARK:--------------------比较refsA是否比refsB大--------------------
 */
//+(NSComparisonResult) compareRefsA_p:(NSArray*)refsA_p refsB_p:(NSArray*)refsB_p{
//    //1. 数据检查 & 准备
//    refsA_p = ARRTOOK(refsA_p);
//    refsB_p = ARRTOOK(refsB_p);
//    NSInteger aLength = refsA_p.count;
//    NSInteger bLength = refsB_p.count;
//    
//    //2. 比较大小
//    for (NSInteger i = 0; i < MIN(aLength, bLength); i++) {
//        AIKVPointer *itemA = ARR_INDEX(refsA_p, i);
//        AIKVPointer *itemB = ARR_INDEX(refsB_p, i);
//        NSNumber *aNum = [SMGUtils searchObjectForPointer:itemA fileName:kFNValue];
//        NSNumber *bNum = [SMGUtils searchObjectForPointer:itemB fileName:kFNValue];
//        NSComparisonResult result = [NUMTOOK(aNum) compare:NUMTOOK(bNum)] ;
//        if (result != NSOrderedSame) {
//            return result;
//        }
//    }
//    
//    //3. 前面都一样
//    return aLength > bLength ? NSOrderedAscending : aLength < bLength ? NSOrderedDescending : NSOrderedSame;
//}

+(NSComparisonResult) comparePointerA:(AIPointer*)pA pointerB:(AIPointer*)pB{
    //1. 数据检查
    BOOL aIsOk = ISOK(pA, AIKVPointer.class);
    BOOL bIsOk = ISOK(pB, AIKVPointer.class);
    if (!aIsOk || !bIsOk) {
        return (aIsOk == bIsOk) ? NSOrderedSame : (aIsOk ? NSOrderedDescending : NSOrderedAscending);
    }
    
    //2. PointerId越大越排前面
    if (pA.pointerId > pB.pointerId) {
        return NSOrderedDescending;
    }else if(pA.pointerId < pB.pointerId){
        return NSOrderedAscending;
    }else{
        return [XGRedisUtil compareStrA:pA.identifier strB:pB.identifier];
    }
}

+(NSComparisonResult) comparePortA:(AIPort*)pA portB:(AIPort*)pB{
    //1. 数据检查
    BOOL aIsOk = ISOK(pA, AIPort.class);
    BOOL bIsOk = ISOK(pB, AIPort.class);
    if (!aIsOk || !bIsOk) {
        return (aIsOk == bIsOk) ? NSOrderedSame : (aIsOk ? NSOrderedDescending : NSOrderedAscending);
    }
    
    //2. 默认按StrongValue从大到小排序 (self.strongValue越大越排前面)
    if (pA.strong.value > pB.strong.value) {
        return NSOrderedDescending;
    }else if(pA.strong.value < pB.strong.value){
        return NSOrderedAscending;
    }else{
        return [SMGUtils comparePointerA:pA.target_p pointerB:pB.target_p];
    }
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
    //isMem临时先这么判断,后续再改 (由各方法自行传入);
    BOOL isMem = [kFNMemNode isEqualToString:fileName] || [kFNMemAbsPorts isEqualToString:fileName] || [kFNMemConPorts isEqualToString:fileName] || [kFNMemRefPorts isEqualToString:fileName];
    return [self searchObjectForFilePath:filePath fileName:fileName time:time isMem:isMem];
}

+(id) searchObjectForFilePath:(NSString*)filePath fileName:(NSString*)fileName time:(double)time isMem:(BOOL)isMem{
    //1. 数据检查
    filePath = STRTOOK(filePath);
    
    //2. 优先取redis
    NSString *key = STRFORMAT(@"%@/%@",filePath,fileName);//随后去掉前辍
    id result = [[XGRedis sharedInstance] objectForKey:key];
    
    //3. 再取wedis
    if (result == nil) {
        result = [[XGWedis sharedInstance] objectForKey:key];
        
        //4. 最后取disk
        if (result == nil && !isMem) {
            PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:filePath];
            result = [cache objectForKey:fileName];
        }
        
        //5. 存到redis (wedis/disk)
        if (time > 0 && result) {
            [[XGRedis sharedInstance] setObject:result forKey:key time:time];
        }
    }
    return result;
}

//+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName{
//    [self insertObject:obj rootPath:rootPath fileName:fileName time:0 saveDB:true];
//}
+(void) insertObject:(NSObject*)obj pointer:(AIPointer*)pointer fileName:(NSString*)fileName time:(double)time{
    if (ISOK(pointer, AIPointer.class)) {
        [self insertObject:obj rootPath:pointer.filePath fileName:fileName time:time saveDB:!pointer.isMem];
    }
}
+(void) insertObject:(NSObject*)obj rootPath:(NSString*)rootPath fileName:(NSString*)fileName time:(double)time saveDB:(BOOL)saveDB{
    //1. 存disk (异步持久化)
    NSString *key = STRFORMAT(@"%@/%@",rootPath,fileName);
    if (saveDB) {
        [[XGWedis sharedInstance] setObject:obj forKey:key];
        [[XGWedis sharedInstance] setSaveBlock:^(NSDictionary *dic) {
            dic = DICTOOK(dic);
            for (NSString *saveKey in dic.allKeys) {
                NSObject *saveObj = [dic objectForKey:saveKey];
                
                NSArray *saveKeyArr = ARRTOOK([saveKey componentsSeparatedByString:@"/"]);
                NSString *saveFileName = ARR_INDEX(saveKeyArr, saveKeyArr.count - 1);
                saveFileName = STRTOOK(saveFileName);
                NSString *saveRootPath = STRTOOK(SUBSTR2INDEX(saveKey, (saveKey.length - saveFileName.length - 1)));
                PINDiskCache *cache = [[PINDiskCache alloc] initWithName:@"" rootPath:saveRootPath];
                [cache setObject:saveObj forKey:saveFileName];
            }
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            for (NSString *key in dic.allKeys) {
                NSLog(@">>>>>>>>>WriteDisk,%@",[key stringByReplacingOccurrencesOfString:cachePath withString:@""]);
            }
            
        }];
    }
    
    //2. 存redis
    [[XGRedis sharedInstance] setObject:obj forKey:key time:time];//随后去掉(redisKey)前辍
}

+(id) searchNode:(AIPointer*)pointer {
    if (ISOK(pointer, AIPointer.class)) {
        return [self searchObjectForFilePath:pointer.filePath fileName:kFNNode_All(pointer.isMem) time:cRTNode_All(pointer.isMem)];
    }
    return nil;
}

+(void) insertNode:(AINodeBase*)node{
    if (ISOK(node, AINodeBase.class)) {
        [self insertObject:node pointer:node.pointer fileName:kFNNode_All(node.pointer.isMem) time:cRTNode_All(node.pointer.isMem)];
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

+(BOOL) containsSub_p:(AIPointer*)sub_p parentPorts:(NSArray*)parentPorts{
    NSArray *parent_ps = [SMGUtils convertPointersFromPorts:parentPorts];
    return [SMGUtils containsSub_p:sub_p parent_ps:parent_ps];
}

@end


//MARK:===============================================================
//MARK:                     < SMGUtils (convert) >
//MARK:===============================================================
@implementation SMGUtils (Convert)

+(NSArray*) convertPointersFromPorts:(NSArray*)ports{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (AIPort *port in ARRTOOK(ports)) {
        if (ISOK(port, AIPort.class) && ISOK(port.target_p, AIPointer.class)) {
            [result addObject:port.target_p];
        }
    }
    return result;
}

+(NSString*) convertPointers2String:(NSArray*)pointers{
    NSMutableString *mStr = [[NSMutableString alloc] init];
    for (AIPointer *p in ARRTOOK(pointers)) {
        [mStr appendFormat:@"%@_%ld,",p.identifier,p.pointerId];
    }
    return mStr;
}

+(NSMutableArray*) convertValuePs2MicroValuePs:(NSArray*)value_ps{
    //1. 数据准备
    NSMutableArray *mic_ps = [[NSMutableArray alloc] init];
    
    //2. 逐个收集
    for (AIKVPointer *value_p in value_ps) {
        
        //3. 概念嵌套时
        if ([kPN_ALG_ABS_NODE isEqualToString:value_p.folderName]) {
            AIAlgNodeBase *algNode = [SMGUtils searchNode:value_p];
            
            //4. 递归取嵌套的value_ps
            if (ISOK(algNode, AIAlgNodeBase.class)) {
                [mic_ps addObjectsFromArray:[self convertValuePs2MicroValuePs:algNode.content_ps]];
            }
        }
        
        //5. 非概念嵌套时,直接收集;
        [mic_ps addObject:value_p];
    }
    return mic_ps;
}


@end


//MARK:===============================================================
//MARK:                     < SMGUtils (Sort) >
//MARK:===============================================================
@implementation SMGUtils (Sort)

+(NSArray*) sortPointers:(NSArray*)ps{
    ps = ARRTOOK(ps);
    return [ps sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [SMGUtils comparePointerA:obj1 pointerB:obj2];
    }];
}

@end


//MARK:===============================================================
//MARK:                     < SMGUtils (Remove) >
//MARK:===============================================================
@implementation SMGUtils (Remove)

+(NSMutableArray*) removeSub_ps:(NSArray*)sub_ps parent_ps:(NSMutableArray*)parent_ps{
    sub_ps = ARRTOOK(sub_ps);
    for (AIPointer *sub_p in sub_ps) {
        parent_ps = [self removeSub_p:sub_p parent_ps:parent_ps];
    }
    return parent_ps;
}

+(NSMutableArray*) removeSub_p:(AIPointer*)sub_p parent_ps:(NSMutableArray*)parent_ps{
    if (ISOK(sub_p, AIPointer.class) && ARRISOK(parent_ps)) {
        for (NSInteger i = 0; i < parent_ps.count; i++) {
            AIPointer *parent_p = ARR_INDEX(parent_ps, i);
            if ([sub_p isEqual:parent_p]) {
                [parent_ps removeObjectAtIndex:i];
                break;
            }
        }
    }
    return parent_ps;
}

+(NSMutableArray*) filterSame_ps:(NSArray*)a_ps parent_ps:(NSArray*)b_ps{
    a_ps = ARRTOOK(a_ps);
    b_ps = ARRTOOK(b_ps);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (AIPointer *a_p in a_ps) {
        if ([self containsSub_p:a_p parent_ps:b_ps]) {
            [result addObject:a_p];
        }
    }
    return result;
}

//一次将parent_ps中,所有某指针移除; (数组中是允许有多个重复指针的)
//+(NSMutableArray*) removeAllSub_p:(AIPointer*)sub_p parent_ps:(NSMutableArray*)parent_ps{
//    if (ISOK(sub_p, AIPointer.class) && ARRISOK(parent_ps)) {
//        for (AIPointer *parent_p in parent_ps) {
//            if ([sub_p isEqual:parent_p]) {
//                [parent_ps removeObject:parent_p];
//                return parent_ps;
//            }
//        }
//    }
//    return parent_ps;
//}

@end
