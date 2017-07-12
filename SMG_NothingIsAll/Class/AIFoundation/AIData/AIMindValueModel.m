//
//  AIMindValueModel.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMindValueModel.h"

@implementation AIMindValueModel

+(AIMindValueModel*) initWithType:(MindType)type value:(CGFloat)value sourcePointer:(AIPointer*)pointer{
    AIMindValueModel *mindV = [[AIMindValueModel alloc] init];//注!!!:随后添加去重处理;
    mindV = [[AIMindValueModel alloc] init];
    mindV.type = type;
    mindV.value = value;
    mindV.sourcePointer = pointer;
    return mindV;
}

@end
