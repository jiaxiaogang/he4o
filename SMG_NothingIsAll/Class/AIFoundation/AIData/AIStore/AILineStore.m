//
//  AILineStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILineStore.h"

@implementation AILineStore

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
