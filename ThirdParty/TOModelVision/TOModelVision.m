//
//  TOModelVision.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/5/11.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TOModelVision.h"
#import "TOModelBase.h"
#import "PerceptDemandModel.h"
#import "ReasonDemandModel.h"
#import "AIMatchFoModel.h"
#import "TOModelVisionUtil.h"
#import "UnorderItemModel.h"

@implementation TOModelVision

+(NSString*) cur2Root:(TOModelBase*)curModel{
    //1. 数据准备
    NSMutableString *mStr = [[NSMutableString alloc] init];
    TOModelBase *single = curModel;
    
    //2. 递归取值
    while (single) {
        NSString *singleStr = [self singleVision:single];
        
        //3. 当前/base有效时,插入首部一行;
        if (STRISOK(singleStr)) {
            if (STRISOK(mStr)) [mStr insertString:@"\n   ↑\n" atIndex:0];
            [mStr insertString:singleStr atIndex:0];
        }
        single = single.baseOrGroup;
    }
    
    //4. 头尾
    [mStr insertString:@"\n︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹\n" atIndex:0];
    [mStr appendString:@"\n︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺\n"];
    return mStr;
}

/**
 *  MARK:--------------------从当前到sub可视化日志--------------------
 *  @version
 *      2021.06.03: 修复singleDesc为空时,appendString:nil,闪退的问题;
 */
+(NSString*) cur2Sub:(TOModelBase*)curModel{
    //1. 数据准备
    NSMutableString *result = [[NSMutableString alloc] init];
    
    //2. 转为无序列表模型
    NSMutableArray *unorderModels = [TOModelVisionUtil convertCur2Sub2UnorderModels:curModel];
    
    //3. 转为logStr
    for (UnorderItemModel *unorder in unorderModels) {
        
        //4. 将unorderModel转为line日志;
        NSMutableString *line = [[NSMutableString alloc] init];
        [line appendString:@"\n"];//换行
        for (int i = 0; i < unorder.tabNum; i++) [line appendString:@"  "];//缩进
        [line appendString:STRFORMAT(@"%@ ",[TOModelVisionUtil getUnorderPrefix:unorder.tabNum])];//无序列标
        [line appendString:STRTOOK([self singleVision:unorder.data])];//内容
        
        //5. 收集line
        [result appendString:line];
    }
    
    //6. 头尾
    [result insertString:@"\n︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹︹" atIndex:0];
    [result appendString:@"\n︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺︺\n"];
    return result;
}

/**
 *  MARK:--------------------单model转str--------------------
 *  @version
 *      2021.06.01: 支持ReasonDemandModel;
 *  @result notnull
 */
+(NSString*) singleVision:(TOModelBase*)model{
    //1. 取content_p
    AIKVPointer *content_p = nil;
    NSString *isInfectedDesc = @"";
    if (ISOK(model, ReasonDemandModel.class)) {
        ReasonDemandModel *rData = (ReasonDemandModel*)model;
        content_p = rData.protoOrRegroupFo;
    } else if(ISOK(model, TOFoModel.class)){
        TOFoModel *foModel = (TOFoModel*)model;
        content_p = foModel.cansetFrom;
        isInfectedDesc = foModel.isInfected ? @" 传染" : @" 唤醒";
    } else if(ISOK(model, TOModelBase.class)){
        content_p = model.content_p;
    }
    
    //2. 转成str
    if (content_p) {
        if (PitIsFo(content_p)) {
            AIFoNodeBase *node = [SMGUtils searchNode:content_p];
            return STRFORMAT(@"%@: %@->%@ (%@ | %@)%@",NSStringFromClass(model.class),Pit2FStr(content_p),Mvp2Str(node.cmvNode_p),content_p.typeStr,TOStatus2Str(model.status),isInfectedDesc);
        }else{
            return STRFORMAT(@"%@: %@ (%@ | %@)%@",NSStringFromClass(model.class),Pit2FStr(content_p),content_p.typeStr,TOStatus2Str(model.status),isInfectedDesc);
        }
    }else{
        return STRFORMAT(@"%@",NSStringFromClass(model.class));
    }
}

@end
