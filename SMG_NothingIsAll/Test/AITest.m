//
//  AITest.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/9/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AITest.h"

@implementation AITest

+(void) test1:(NSString*)aDS hnAlgDS:(NSString*)hnAlgDS{
    if (![aDS isEqualToString:@" "] ||
        ![hnAlgDS isEqualToString:@" "]) {
        NSLog(@"自检1. 测下getHN经验时vDS匹配判断代码是否多余,多余告警");
    }
}

+(void) test2:(AIKVPointer*)pointer type:(AnalogyType)type at:(NSString*)at ds:(NSString*)ds{
    if (PitIsFo(pointer) || PitIsAlg(pointer)) {
        if (type == ATGreater || type == ATLess) {
            if ([@"AIVisionAlgs" isEqualToString:at]){
                if (![ds isEqualToString:@"sizeWidth"] &&
                    ![ds isEqualToString:@"sizeHeight"] &&
                    ![ds isEqualToString:@"colorRed"] &&
                    ![ds isEqualToString:@"colorBlue"] &&
                    ![ds isEqualToString:@"colorGreen"] &&
                    ![ds isEqualToString:@"radius"] &&
                    ![ds isEqualToString:@"direction"] &&
                    ![ds isEqualToString:@"distance"] &&
                    ![ds isEqualToString:@"distanceY"] &&
                    ![ds isEqualToString:@"speed"] &&
                    ![ds isEqualToString:@"border"] &&
                    ![ds isEqualToString:@"posX"] &&
                    ![ds isEqualToString:@"posY"]) {
                    NSLog(@"自检2. 测生成GL的AIKVPointer时的ds是否正常赋值,因为它影响node防重;");
                }
            }
        }
    }
}

+(void) test3:(AIKVPointer*)pointer type:(AnalogyType)type ds:(NSString*)ds{
    if (PitIsFo(pointer) || PitIsAlg(pointer)) {
        if (type != ATGreater && type != ATLess) {
            if (![ds isEqualToString:@" "]) {
                NSLog(@"自检3. 测生成非GL的AIKVPointer时的ds是否为" ",因为它影响node防重;");
            }
        }
    }
}

+(void) test4:(AIKVPointer*)pointer at:(NSString*)at isOut:(BOOL)isOut{
    if (PitIsValue(pointer)) {
        if ([at isEqualToString:FLY_RDS] && !isOut) {
            NSLog(@"自检4. 行为飞稀疏码的isOut为false的问题");
        }
    }
}

+(void) test5:(AIKVPointer*)pointer type:(AnalogyType)type at:(NSString*)at{
    if (PitIsFo(pointer) || PitIsAlg(pointer)) {
        if (type == ATGreater || type == ATLess) {
            if (![@"AIVisionAlgs" isEqualToString:at] &&
                ![FLY_RDS isEqualToString:at]) {
                NSLog(@"自检5. 测生成GL的AIKVPointer时的at是否正常赋值,因为它影响node防重");
            }
        }
    }
}

+(void) test6:(NSArray*)arr{
    arr = ARRTOOK(arr);
    if (arr.count > 1) {
        NSLog(@"自检6. 测从conNodes取at&ds&type应唯一,否则查为何不同的node会类比抽象");
    }
}

+(void) test7:(NSArray*)arr type:(AnalogyType)type{
    if (type == ATPlus || type == ATSub) {
        NSArray *types = [SMGUtils removeRepeat:[SMGUtils convertArr:arr convertBlock:^id(AIKVPointer *obj) {
            return @(obj.type);
        }]];
        if (types.count > 1) {
            NSLog(@"自检7. 测构建SPFo时,元素有两种类型的原因(参考24022BUG3)");
        }
    }
}

+(void) test8:(NSArray*)content_ps type:(AnalogyType)type{
    for (AIKVPointer *item_p in content_ps) {
        if (item_p.type != ATDefault && item_p.type != type) {
            NSLog(@"自检8. 测构建Fo时,有不匹配type的元素原因(参考24022BUG4)");
        }
    }
}

@end
