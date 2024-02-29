//
//  DirectIndexDic.m
//  SMG_NothingIsAll
//
//  Created by jia on 2024/2/29.
//  Copyright © 2024 XiaoGang. All rights reserved.
//

#import "DirectIndexDic.h"

@implementation DirectIndexDic

+(id) newOkToAbs:(NSDictionary*)indexDic {
    DirectIndexDic *result = [self newNoToAbs:indexDic];
    result.toAbs = true;
    return result;
}
+(id) newNoToAbs:(NSDictionary*)indexDic {
    DirectIndexDic *result = [[DirectIndexDic alloc] init];
    result.indexDic = indexDic;
    return result;
}

@end
