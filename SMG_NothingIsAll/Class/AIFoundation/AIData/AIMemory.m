//
//  AIMemory.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMemory.h"

@implementation AIMemory


+(void)initialize{
    [super initialize];
    [self setUserCalculateForCN:@"mindValue"];
}

-(id)userGetValueForModel:(LKDBProperty *)property{
    if([property.sqlColumnName isEqualToString:@"mindValue"] && self.mindValue != nil){
        [AIMindValue insertToDB:self.mindValue];
        return @(self.mindValue.rowid);
    }
    return nil;
}

-(void)userSetValueForModel:(LKDBProperty *)property value:(id)value {
    if([property.sqlColumnName isEqualToString:@"mindValue"]) {
        self.mindValue = [AIMindValue ai_searchSingleWithRowId:[STRTOOK(value) intValue]];
    }
}


@end
