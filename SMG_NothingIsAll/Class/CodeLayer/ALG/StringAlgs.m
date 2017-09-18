//
//  StringAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "StringAlgs.h"
#import "AIFuncModel.h"

@implementation StringAlgs

+(NSUInteger) length:(NSString*)str{
    str = STRTOOK(str);
    return str.length;
}

+(NSMutableArray*) algs{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    //length:
    AIFuncModel *model = [[AIFuncModel alloc] init];
    model.funcClass = StringAlgs.class;
    model.funcSel = @selector(length:);
    [arr addObject:model];
    
    return arr;
}

@end
