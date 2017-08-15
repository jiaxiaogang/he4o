//
//  AIPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@implementation AIPointer

+(AIPointer*) initWithClass:(Class)pC withId:(NSInteger)pI {    
    NSDictionary *where = [[NSDictionary alloc] initWithObjectsAndKeys:NSStringFromClass(pC),@"pClass",@(pI),@"pId", nil];
    AIPointer *value = [AIPointer searchSingleWithWhere:where orderBy:nil];
    if (value) {
        return value;
    }else{
        value = [[AIPointer alloc] init];
        value.pClass = NSStringFromClass(pC);
        value.pId = pI;
        [AIPointer insertToDB:value];
        return value;
    }
}

/**
 *  MARK:--------------------public--------------------
 */
-(BOOL) isEqual:(id)object{//重写指针对比地址方法;
    if (object && [object isKindOfClass:[AIPointer class]]) {
        BOOL classIsEqual = [STRTOOK(self.pClass) isEqual:((AIPointer*)object).pClass];
        BOOL idIsEqual = self.pId == ((AIPointer*)object).pId;
        return classIsEqual && idIsEqual;
    }
    return false;
}

-(id) content{
    Class class = NSClassFromString(STRTOOK(self.pClass));
    if (class) {
        return [class searchSingleWithWhere:[DBUtils sqlWhere_RowId:self.pId] orderBy:nil];
    }
    return nil;
}

@end
