//
//  DBUtils.m
//  SMG2
//
//  Created by 贾  on 2017/4/1.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DBUtils.h"

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
