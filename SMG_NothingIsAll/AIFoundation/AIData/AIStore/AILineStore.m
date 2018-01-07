//
//  AILineStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILineStore.h"
#import "AIPort.h"
#import "AISqlPointer.h"
#import "AILine.h"
#import "AILineStrong.h"

@implementation AILineStore

/**
 *  MARK:--------------------IO--------------------
 */
+(NSMutableArray*) searchPointers:(NSArray*)pointers count:(NSInteger)count{
    return [self searchPointers:pointers count:count complare:^BOOL(NSArray *aps, NSArray *bps) {
        return [self isEqual:aps bPointers:bps];
    } complareType:nil];
}

+(NSMutableArray*) searchPointersByClass:(NSArray*)pointers count:(NSInteger)count{
    return [self searchPointers:pointers count:count complare:^BOOL(NSArray *aps, NSArray *bps) {
        return [self isEqual:aps bPointers:bps complare:^BOOL(AIPointer *ap, AIPointer *bp) {
            if ([ap isKindOfClass:[AISqlPointer class]] && [bp isKindOfClass:[AISqlPointer class]]) {
                AISqlPointer *aSqlPointer = (AISqlPointer*)ap;
                AISqlPointer *bSqlPointer = (AISqlPointer*)bp;
                return [STRTOOK(aSqlPointer.pClass) isEqualToString:bSqlPointer.pClass];
            }
            return [ap isEqual:bp];
        }];
    } complareType:nil];
}

+(NSMutableArray*) searchPointersByClass:(NSArray*)pointers type:(AILineType)type count:(NSInteger)count {
    return [self searchPointers:pointers count:count complare:^BOOL(NSArray *aps, NSArray *bps) {
        return [self isEqual:aps bPointers:bps complare:^BOOL(AIPointer *ap, AIPointer *bp) {
            if ([ap isKindOfClass:[AISqlPointer class]] && [bp isKindOfClass:[AISqlPointer class]]) {
                AISqlPointer *aSqlPointer = (AISqlPointer*)ap;
                AISqlPointer *bSqlPointer = (AISqlPointer*)bp;
                return [STRTOOK(aSqlPointer.pClass) isEqualToString:bSqlPointer.pClass];
            }
            return [ap isEqual:bp];
        }];
    } complareType:^BOOL(AILineType curType) {
        return type == curType;
    }];
}

+(NSMutableArray*) searchPointer:(AIPointer*)pointer count:(NSInteger)count{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *lines = ARRTOOK([[self getModelClass] searchWithWhere:nil]);
    for (AILine *line in lines) {
        for (AIPointer *lP in ARRTOOK(line.port.pointers)) {
            if ([lP isEqual:pointer]) {
                [arr addObject:line];
                if (arr.count >= count) {
                    return arr;
                }
            }
        }
    }
    
    return arr;
}

+(NSMutableArray*) searchPointer:(AIPointer*)pointer energy:(CGFloat)energy{
    NSMutableArray *havArr = [[NSMutableArray alloc] init];
    NSMutableArray *validArr = [[NSMutableArray alloc] init];
    
    NSArray *lines = ARRTOOK([[self getModelClass] searchWithWhere:nil]);
    for (AILine *line in lines) {
        for (AIPointer *lP in ARRTOOK(line.port.pointers)) {
            if ([lP isEqual:pointer]) {
                [havArr addObject:line];
            }
        }
    }
    
    //1,根据网络强度排序
    NSArray *sortHavArr = [havArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AILine *aiLine1 = (AILine*)obj1;
        AILine *aiLine2 = (AILine*)obj2;
        if(aiLine1.type == ALT_IsA){
            return true;
        }
        if(aiLine2.type == ALT_IsA){
            return false;
        }
        
        return aiLine1.strong.value > aiLine2.strong.value;
    }];
    
    //2,将网络强度高的点亮
    for (AILine *line in sortHavArr) {
        
        //3,计算当前line需要能量值
        CGFloat curNeedEnergy = 0;
        if (line.type != ALT_IsA) {
            curNeedEnergy = [SMGUtils aiLine_GetLightEnergy:line.strong.value];
        }
        //4,点亮并消耗掉能量
        if (energy > curNeedEnergy) {
            [validArr addObject:line];
            energy -= curNeedEnergy;
        }
        
        //5,将无限层的关联加入进来;
        
        //6,
    }
    
    return validArr;
}

+(void) insert:(AIObject *)data{
    [self insert:data awareness:false];
    //可以考虑把SMGUtils里的createLine方法中插网口的操作移到这里;现在不移;今后再说;//xxx
}

/**
 *  MARK:--------------------method--------------------
 */
+(Class)getModelClass{
    return [AILine class];
}

+(BOOL) isEqual:(NSArray*)aPointers bPointers:(NSArray*)bPointers{
    return [AILineStore isEqual:aPointers bPointers:bPointers complare:^BOOL(AIPointer *ap, AIPointer *bp) {
        return [ap isEqual:bp];
    }];
}

+(BOOL) isEqual:(NSArray*)aPointers bPointers:(NSArray*)bPointers complare:(BOOL(^)(AIPointer *ap,AIPointer *bp))complare{
    if (ARRISOK(aPointers) && ARRISOK(bPointers)) {
        BOOL isEqual = true;
        for (AIPointer *ap in ARRTOOK(aPointers)) {
            BOOL bsContainAP = false;
            for (AIPointer *bp in bPointers) {
                if (complare && complare(ap,bp)) {
                    bsContainAP = true;
                    break;
                }
            }
            if (bsContainAP == false) {
                isEqual = false;
                break;
            }
        }
        return isEqual;
    }
    return false;
}

+(NSMutableArray*) searchPointers:(NSArray*)pointers count:(NSInteger)count complare:(BOOL(^)(NSArray *aps,NSArray *bps))complare complareType:(BOOL(^)(AILineType curType))complareType {
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    if (ARRISOK(pointers)) {
        NSArray *lines = ARRTOOK([[self getModelClass] searchWithWhere:nil]);
        for (AILine *line in lines) {
            //对比指针数组
            BOOL isEqual_Pointers = true;
            if(complare){
                isEqual_Pointers = complare(pointers,line.port.pointers);
            }
            //对比类型
            BOOL isEqual_Type = true;
            if(complareType){
                isEqual_Type = complareType(line.type);
            }
            //收集有效神经网络
            if (isEqual_Pointers && isEqual_Type) {
                [mArr addObject:line];
                if (mArr.count >= count) {
                    return mArr;
                }
            }
        }
    }
    return mArr;
}

@end
