//
//  AISqlPointer.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AISqlPointer.h"

@implementation AISqlPointer

-(id) initWithPId:(NSInteger)pId{
    self = [super init];
    if (self) {
        self.pId = pId;
    }
    return self;
}

+(AISqlPointer*) initWithClass:(Class)pC withId:(NSInteger)pI {
    
    /*
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
     */
    
    //原先去重并insert了,但其实这个去重会自动作;不需要;并且这里直接insert会出问题;因为此时的PId很多是0;
    AISqlPointer *pointer = [[AISqlPointer alloc] init];
    pointer.pClass = NSStringFromClass(pC);
    pointer.pId = pI;
    return pointer;
    
}

/**
 *  MARK:--------------------public--------------------
 */
-(BOOL) isEqual:(AISqlPointer*)object{//重写指针对比地址方法;
    if (ISOK(object, AISqlPointer.class)) {
        BOOL classIsEqual = [STRTOOK(self.pClass) isEqual:((AISqlPointer*)object).pClass];
        BOOL idIsEqual = self.pId == ((AISqlPointer*)object).pId;
        return classIsEqual && idIsEqual;
    }
    return false;
}

-(id) content{
    Class class = NSClassFromString(STRTOOK(self.pClass));
    if (class) {
        return [class searchSingleWithWhere:[SMGUtils sqlWhere_RowId:self.pId] orderBy:nil];
    }
    return nil;
}



/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.pClass = [aDecoder decodeObjectForKey:@"pClass"];
        self.pId = [aDecoder decodeIntegerForKey:@"pId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.pClass forKey:@"pClass"];
    [aCoder encodeInteger:self.pId forKey:@"pId"];
}

@end
