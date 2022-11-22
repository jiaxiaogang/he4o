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

+(void) test9:(AIFoNodeBase*)fo type:(AnalogyType)type{
    if (type == ATPlus && [Fo2FStr(fo) containsString:@"Y距35"]) {
        NSLog(@"自检9. 测构建了Y距35的P节点原因(参考24057)");
    }
}

+(void) test10:(TOModelBase*)toModel{
    //plan取得结果为actNo状态的自检;
    if(toModel.status == TOModelStatus_ActNo){
        WLog(@"自检10: Plan结果为已ActNo状态");
    }
}

+(void) test11:(AIShortMatchModel*)shortModel waitAlg_p:(AIKVPointer*)waitAlg_p{
    //2523c-理性反馈,的旧有mIsC方式没问题,但新matchAlgs+partAlgs的方式却有BUG;
    //怀疑是反馈这块有匹配不到的问题,但又复现不了,所以此处写test11来测试下,希望能复现,报到错;
    if (shortModel && waitAlg_p) {
        NSArray *recognitionAlgs = [TIUtils getMatchAndPartAlgPsByModel:shortModel];
        NSArray *mAbs = Ports2Pits([AINetUtils absPorts_All:shortModel.protoAlg]);
        BOOL oldMIsC = [mAbs containsObject:waitAlg_p];
        BOOL newMIsC = [recognitionAlgs containsObject:waitAlg_p];
        
        if (oldMIsC && !newMIsC) {
            ELog(@"复现成功,二者不一样: 对比下mAbs和recognitionAlgs,看下区别,为什么导致newMIsC未匹配到");
        }
    }
}

+(void) test12:(CGFloat)score {
    if (score > 1000 || score < -1000) {
        ELog(@"自检12: 评分异常");
    }
}

+(void) test13:(NSArray*)slowSolutionCansets {
    if (slowSolutionCansets && slowSolutionCansets.count > 1000) {
        ELog(@"自检13: 慢思考候选集太长,建议限limit");
    }
}

+(void) test14:(CGFloat)near {
    if (near == 0) {
        ELog(@"自检14: 怎么会有near=0的抽具象关联咧?查下是matchDic中没存着么?");
    }
}

+(void) test15:(AIMatchFoModel*)model {
    if (model.realMaskFo.count != model.realDeltaTimes.count) {
        ELog(@"自检15: 经查AIMatchFoModel里的proto所需的两个数组不一样长度,有BUG,但下为什么不一样长,不一样长的话,就没法生成有效的order从而构建(完全)protoFo");
    }
}

+(void) test16:(CGFloat)algHDMatchValue {
    if (algHDMatchValue == 0) {
        ELog(@"自检16: 概念相似度复用为0,但下原因");
    }
}

@end
