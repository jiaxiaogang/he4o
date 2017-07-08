//
//  AILaw.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AILaw.h"

@implementation AILaw

+(void) ai_insertToDB:(id)obj{
    if (obj && [obj isKindOfClass:[AILaw class]]) {
        ((AILaw*)obj).count ++;//存取时计数器+1;
    }
    [super ai_insertToDB:obj];
}

+(id)ai_searchSingleWithRowId:(NSInteger)rowid{
    AILaw *law = [super ai_searchSingleWithRowId:rowid];
    if (law) {
        law.count ++;//存取时计数器+1;
        [self ai_updateToDB:law where:[DBUtils sqlWhere_RowId:law.rowid]];
    }
    return law;
}

@end
