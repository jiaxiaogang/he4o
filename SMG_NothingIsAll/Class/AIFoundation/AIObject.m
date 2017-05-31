//
//  AIObject.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

@implementation AIObject

/**
 *  MARK:--------------------Store--------------------
 */
+(void)initialize{
    [self removePropertyWithColumnName:@"pointer"];
}

+(BOOL) isContainParent{
    return true;
}

/**
 *  MARK:--------------------method--------------------
 */
+(id) initWithContent:(id)content{
    return [[AIObject alloc] init];
}

-(AIPointer*) pointer{
    if (_pointer == nil) {
        _pointer = [AIPointer initWithClass:self.class withId:self.rowid];
    }
    return _pointer;
}

-(BOOL) isEqual:(id)obj{
    if (obj && [obj isKindOfClass:[AIObject class]]) {
        return [self.pointer isEqual:((AIObject*)obj).pointer];//对比指针地址
    }
    return false;
}

-(void) print{
    NSLog(@"%@",self);
}


@end


/**
 *  MARK:--------------------本地存储--------------------
 */
@implementation AIObject (Store)

+ (id) ai_searchSingleWithRowId:(NSInteger)rowid {
    return [self.class searchSingleWithWhere:[DBUtils sqlWhere_RowId:rowid] orderBy:nil];
}

+ (void) ai_insertToDB:(id)obj{
    [self.class insertToDB:obj];
}

+ (BOOL) ai_updateToDB:(NSObject *)model where:(id)where {
    return [self.class updateToDB:model where:where];
}

@end
