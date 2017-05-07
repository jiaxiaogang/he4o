//
//  CharStore.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "CharStore.h"
#import "StoreHeader.h"

@implementation CharStore

+(NSString*) searchString:(NSArray*)rowIdArr{
    if (ARRISOK(rowIdArr)) {
        NSMutableString *mStr = [[NSMutableString alloc] init];
        for (NSString *rowId in rowIdArr) {
            CharModel *charModel = [CharModel searchSingleWithWhere:[DBUtils sqlWhere_RowId:[STRTOOK(rowId) integerValue]] orderBy:nil];
            if (charModel) {
                [mStr appendString:STRTOOK(charModel.value)];
            }else{
                [mStr appendFormat:@"|_%@_|",rowId];
            }
        }
        return mStr;
    }
    return nil;
}


+(NSArray*) insertString:(NSString*)string{
    if (STRISOK(string)) {
        NSMutableArray *mArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < string.length; i++) {
            NSString *value = [string substringWithRange:NSMakeRange(i,1)];
            
            CharModel *localModel = [CharModel searchSingleWithWhere:[DBUtils sqlWhere_K:@"value" V:value] orderBy:nil];
            if (localModel) {
                [mArr addObject:STRFORMAT(@"%ld",(long)localModel.rowid)];
            }else{
                CharModel *newModel = [[CharModel alloc] init];
                newModel.value = value;
                [CharModel insertToDB:newModel];
                [mArr addObject:STRFORMAT(@"%ld",(long)newModel.rowid)];
            }
        }
        return mArr;
    }
    return nil;
}

@end
