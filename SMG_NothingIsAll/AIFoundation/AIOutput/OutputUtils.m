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

@end
