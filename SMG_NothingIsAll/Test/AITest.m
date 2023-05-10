//
//  AITest.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/9/25.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AITest.h"

@implementation AITest

//MARK:===============================================================
//MARK:               < 异常单元测试 (常开,有异常时停在断点) >
//MARK:===============================================================

+(void) test1:(NSString*)aDS hnAlgDS:(NSString*)hnAlgDS{
    if (!Switch4AITest) return;
    if (![aDS isEqualToString:@" "] ||
        ![hnAlgDS isEqualToString:@" "]) {
        NSLog(@"自检1. 测下getHN经验时vDS匹配判断代码是否多余,多余告警");
    }
}

+(void) test2:(AIKVPointer*)pointer type:(AnalogyType)type at:(NSString*)at ds:(NSString*)ds{
    if (!Switch4AITest) return;
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
    if (!Switch4AITest) return;
    if (PitIsFo(pointer) || PitIsAlg(pointer)) {
        if (type != ATGreater && type != ATLess) {
            if (![ds isEqualToString:@" "]) {
                NSLog(@"自检3. 测生成非GL的AIKVPointer时的ds是否为" ",因为它影响node防重;");
            }
        }
    }
}

+(void) test4:(AIKVPointer*)pointer at:(NSString*)at isOut:(BOOL)isOut{
    if (!Switch4AITest) return;
    if (PitIsValue(pointer)) {
        if ([at isEqualToString:FLY_RDS] && !isOut) {
            NSLog(@"自检4. 行为飞稀疏码的isOut为false的问题");
        }
    }
}

+(void) test5:(AIKVPointer*)pointer type:(AnalogyType)type at:(NSString*)at{
    if (!Switch4AITest) return;
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
    if (!Switch4AITest) return;
    arr = ARRTOOK(arr);
    if (arr.count > 1) {
        NSLog(@"自检6. 测从conNodes取at&ds&type应唯一,否则查为何不同的node会类比抽象");
    }
}

+(void) test7:(NSArray*)arr type:(AnalogyType)type{
    if (!Switch4AITest) return;
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
    if (!Switch4AITest) return;
    for (AIKVPointer *item_p in content_ps) {
        if (item_p.type != ATDefault && item_p.type != type) {
            NSLog(@"自检8. 测构建Fo时,有不匹配type的元素原因(参考24022BUG4)");
        }
    }
}

+(void) test9:(AIFoNodeBase*)fo type:(AnalogyType)type{
    if (!Switch4AITest) return;
    if (type == ATPlus && [Fo2FStr(fo) containsString:@"Y距35"]) {
        NSLog(@"自检9. 测构建了Y距35的P节点原因(参考24057)");
    }
}

+(void) test10:(TOModelBase*)toModel{
    if (!Switch4AITest) return;
    //plan取得结果为actNo状态的自检;
    if(toModel.status == TOModelStatus_ActNo){
        WLog(@"自检10: Plan结果为已ActNo状态");
    }
}

+(void) test11:(AIShortMatchModel*)shortModel waitAlg_p:(AIKVPointer*)waitAlg_p{
    if (!Switch4AITest) return;
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
    if (!Switch4AITest) return;
    if (score > 1000 || score < -1000) {
        ELog(@"自检12: 评分异常");
    }
}

+(void) test13:(NSArray*)slowSolutionCansets {
    if (!Switch4AITest) return;
    if (slowSolutionCansets && slowSolutionCansets.count > 1000) {
        ELog(@"自检13: 慢思考候选集太长,建议限limit");
    }
}

+(void) test14:(CGFloat)near {
    if (!Switch4AITest) return;
    if (near == 0) {
        ELog(@"自检14: 怎么会有near=0的抽具象关联咧?查下是matchDic中没存着么?");
    }
}

+(void) test15:(AIMatchFoModel*)model {
    if (!Switch4AITest) return;
    if (model.realMaskFo.count != model.realDeltaTimes.count) {
        ELog(@"自检15: 经查AIMatchFoModel里的proto所需的两个数组不一样长度,有BUG,但下为什么不一样长,不一样长的话,就没法生成有效的order从而构建(完全)protoFo");
    }
}

+(void) test16:(CGFloat)algHDMatchValue {
    if (!Switch4AITest) return;
    if (algHDMatchValue == 0) {
        ELog(@"自检16: 概念相似度复用为0,但下原因");
    }
}

+(void) test17 {
    if (!Switch4AITest) return;
    NSLog(@"此处打到断点时,先稳步查看n28p07-末尾-未完成项,再继续");
    NSLog(@"核实下,H任务触发canset再类比的时机:targetAlg有反馈? (参考28071)");
    NSLog(@"核实下,H任务触发canset再类比的条件:要求targetFo或hDemand的状态? (参考28077-另外)");
}

+(void) test18:(NSDictionary*)newIndexDic newCanset:(AIFoNodeBase*)newCanset absFo:(AIFoNodeBase*)absFo {
    if (!Switch4AITest) return;
    for (NSNumber *key in newIndexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        NSInteger conIndex = NUMTOOK([newIndexDic objectForKey:key]).integerValue;
        AIKVPointer *conAlg = ARR_INDEX(newCanset.content_ps, conIndex);
        AIKVPointer *absAlg = ARR_INDEX(absFo.content_ps, absIndex);
        if (![TOUtils mIsC_1:conAlg c:absAlg]) {
            ELog(@"检查newCanset的indexDic有误");
        }
    }
}

+(void) test19:(AISPStrong*)newSPStrong {
    if (!Switch4AITest) return;
    if (newSPStrong.sStrong < 0 || newSPStrong.pStrong < 0) {
        ELog(@"检查newSPStrong有误,肯定是前面少计数了,导致后面的P太大,而前面的SP之和反而小于它");
    }
}

+(void) test20:(AIFoNodeBase*)newCanset newSPDic:(NSDictionary*)newSPDic {
    if (!Switch4AITest) return;
    if (newCanset.count != newSPDic.count) {
        ELog(@"检查newSPDic有误,它的长度不等于absCanset长度,查下原因");
    }
}

+(void) test21:(BOOL)refrectionResult {
    if (!Switch4AITest) return;
    if (!refrectionResult) {
        ELog(@"调试下反思未通过的原因,此处仅为了保证反思有失败时,且失败的原因合理");
    }
}

+(void) test22 {
    if (!Switch4AITest) return;
    ELog(@"发现indexDic在absIndex下找不到conIndex,查下为什么没映射到?是不是识别时全含判断错了?");
}

+(void) test23:(NSDictionary*)pmDic cmDic:(NSDictionary*)cmDic matchIndex:(NSInteger)matchIndex {
    if (!Switch4AITest) return;
    if (![pmDic objectForKey:@(matchIndex)] || ![cmDic objectForKey:@(matchIndex)]) {
        ELog(@"matchIndex在前段条件判断中,未找到proto或canset的映射,查下原因 (H任务跳转多了是否有找不着的可能?)");
    }
}

+(void) test24:(NSArray*)absArrForEmptyAlgOfAbsCountCheck {
    if (!Switch4AITest) return;
    if (!ARRISOK(absArrForEmptyAlgOfAbsCountCheck)) {
        ELog(@"构建空抽象时,它的具象概念们的抽象没有共同抽象! (查下Canset识别算法,它有共同抽象才被全含匹配到,如果匹配了,但却没共同抽象,显然有问题)");
    }
}

+(void) test25:(AIAlgNodeBase*)absAlg conAlgs:(NSArray*)conAlgs {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (AINodeBase *con in conAlgs) {
            if (absAlg.pId != con.pId && ![absAlg.conMatchDic objectForKey:@(con.pId)]) {
                ELog(@"alg抽具象关联后: 二者的匹配度未保存,查下为什么匹配度没写存上 abs:%ld con:%ld",absAlg.pId,con.pId);
            }
        }
    });
}

+(void) test26:(NSDictionary*)matchDic checkA:(AIKVPointer*)checkA {
    if (![matchDic objectForKey:@(checkA.pointerId)]) {
        ELog(@"复用概念匹配度失败,查下为什么");
    }
}


//MARK:===============================================================
//MARK:    < 回测必经点测试 (常关,每个轮回测时打开,触发则关,未触发者为异常) >
//MARK:===============================================================
+(void) test101:(AIFoNodeBase*)absCansetFo proto:(AIFoNodeBase*)proto conCanset:(AIFoNodeBase*)conCanset{
    if (!Switch4AITest) return;
    WLog(@"必经点测试: 触发canset再抽象执行到;\n\tabsCanset %@ from:\n\tproto:%@\n\tconConset:%@",Fo2FStr(absCansetFo),Fo2FStr(proto),Fo2FStr(conCanset));
}

+(void) test102:(AIFoNodeBase*)cansetFo {
    if (!Switch4AITest) return;
    //测试27222-1,TCSolution取得抽象canset;
    if (AINetAbsFoNode.class == cansetFo.class) {
        WLog(@"必经点测试: 读取到抽象canset: %@",NSStringFromClass(cansetFo.class));
    }
}

@end
