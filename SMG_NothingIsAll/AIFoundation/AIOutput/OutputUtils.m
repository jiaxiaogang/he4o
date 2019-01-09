//
//  OutputUtils.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "OutputUtils.h"
#import "OutputModel.h"
#import "Output.h"

@implementation OutputUtils

+(NSString*) convertOutType2dataSource:(NSString*)algsType {
    if ([@"AICharAlgsModel" isEqualToString:algsType]) {
        return TEXT_RDS;
    }else{
        return nil;//暂不支持其它类型输出;
    }
}

+(void) output_Face:(AIMoodType)type{
    //1. 数据
    const char *chars = nil;
    if (type == AIMoodType_Anxious) {
        chars = [@"T_T" UTF8String];
    }else if(type == AIMoodType_Satisfy){
        chars = [@"^_^" UTF8String];
    }
    if (chars) {
        //2. 将输出入网
        NSMutableArray *models = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 3; i++) {
            OutputModel *model = [[OutputModel alloc] init];
            model.rds = TEXT_RDS;
            model.data = @(chars[i]);
            [models addObject:model];
        }
        
        [Output output_Reactor:models];
    }
}

@end
