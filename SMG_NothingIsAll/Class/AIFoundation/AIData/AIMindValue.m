//
//  AIMindValue.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/5.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIMindValue.h"

@implementation AIMindValue

+(AIMindValue*) initWithType:(MindType)type value:(CGFloat)value sourcePointer:(AIPointer*)pointer{
    AIMindValue *mindV = [[AIMindValue alloc] init];//注!!!:随后添加去重处理;
    mindV = [[AIMindValue alloc] init];
    mindV.type = type;
    mindV.value = value;
    mindV.sourcePointer = pointer;
    return mindV;
}

@end
