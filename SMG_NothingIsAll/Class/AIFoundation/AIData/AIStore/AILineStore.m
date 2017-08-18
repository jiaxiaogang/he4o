//
//  AILineStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILineStore.h"

@implementation AILineStore

/**
 *  MARK:--------------------IO--------------------
 */
+(AILine*) searchSinglePointers:(NSArray*)pointers{
    if (ARRISOK(pointers)) {
        NSArray *lines = ARRTOOK([[self getModelClass] searchWithWhere:nil]);
        for (AILine *line in lines) {
            BOOL isEqual = [self isEqual:pointers bPointers:line.pointers];
            if (isEqual) {
                return line;
            }
        }
    }
    return nil;
}

+(NSMutableArray*) searchPointer:(AIPointer*)pointer count:(NSInteger)count{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *lines = ARRTOOK([[self getModelClass] searchWithWhere:nil]);
    for (AILine *line in lines) {
        for (AIPointer *lP in ARRTOOK(line.pointers)) {
            if ([STRTOOK(lP.pClass) isEqualToString:pointer.pClass] && lP.pId == pointer.pId) {
                [arr addObject:line];
                if (arr.count >= count) {
                    return arr;
                }
            }
        }
    }
    
    return arr;
}

+(NSMutableArray*) searchPointer:(AIPointer*)pointer energy:(NSInteger)energy{
    NSMutableArray *havArr = [[NSMutableArray alloc] init];
    NSMutableArray *validArr = [[NSMutableArray alloc] init];
    
    NSArray *lines = ARRTOOK([[self getModelClass] searchWithWhere:nil]);
    for (AILine *line in lines) {
        for (AIPointer *lP in ARRTOOK(line.pointers)) {
            if ([STRTOOK(lP.pClass) isEqualToString:pointer.pClass] && lP.pId == pointer.pId) {
                [havArr addObject:line];
            }
        }
    }
    for (AILine *line in havArr) {
        //1,根据网络强度排序
        
        //2,将网络强度高的点亮
        [validArr addObject:line];
        
        //3,将无限层的关联加入进来;
        
        //4,
    }
    
    return validArr;
}

+(void) insert:(AIObject *)data{
    [self insert:data awareness:false];
}

/**
 *  MARK:--------------------method--------------------
 */
+(Class)getModelClass{
    return [AILine class];
}

+(BOOL) isEqual:(NSArray*)aPointers bPointers:(NSArray*)bPointers{
    if (ARRISOK(aPointers) && ARRISOK(bPointers)) {
        BOOL isEqual = true;
        for (AIPointer *ap in ARRTOOK(aPointers)) {
            BOOL bsContainAP = false;
            for (AIPointer *bp in bPointers) {
                if ([STRTOOK(ap.pClass) isEqualToString:bp.pClass] && ap.pId == bp.pId) {
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

@end
