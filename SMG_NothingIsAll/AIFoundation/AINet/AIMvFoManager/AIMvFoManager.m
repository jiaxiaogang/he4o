//
//  AIMvFoManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIMvFoManager.h"
#import "AINetAbsFoUtils.h"

@implementation AIMvFoManager

/**
 *  MARK:--------------------创建fo和mv的指向--------------------
 *  @param mv notnull
 */
-(AIFoNodeBase*) create:(NSTimeInterval)inputTime order:(NSArray*)order mv:(AICMVNodeBase*)mv{
    //1. foNode;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mv.urgentTo_p]) integerValue];
    AIFoNodeBase *foNode = [AIMvFoManager createConFo_NoRepeat:order noRepeatArea_ps:nil difStrong:urgentTo];

    //2. 将mv.inputTime传入,在relateFo之前,将inputTime赋值fo.mvDeltaTime;
    if (ARRISOK(order)) {
        AIShortMatchModel_Simple *lastOrderTime = ARR_INDEX_REVERSE(order, 0);
        foNode.mvDeltaTime = inputTime - lastOrderTime.inputTime;
    }
    
    //3. 互指向
    [AINetUtils relateFo:foNode mv:mv];

    //4. 返回给thinking
    return foNode;
}

-(AICMVNodeBase*) createConMv:(NSArray*)imvAlgsArr {
    //1. 数据解析 & 打包cmvNode;
    __block AICMVNodeBase *cmvNode = nil;
    [ThinkingUtils parserAlgsMVArr:imvAlgsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        //2. 打包cmvNode (imv的价值节点先放内存中);
        cmvNode = [self createConMv:urgentTo_p delta_p:delta_p at:algsType];
    }];
    return cmvNode;
}

/**
 *  MARK:--------------------mvNode构建器--------------------
 *  @version
 *      2023.08.09: 支持全局防重 (参考30095-方案3);
 */
-(AICMVNodeBase*) createConMv:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p at:(NSString*)at {
    //1. 数据
    if (!urgentTo_p || !delta_p || !at) return nil;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:urgentTo_p]) integerValue];
    NSArray *content_ps = @[urgentTo_p, delta_p];
    NSArray *sort_ps = [SMGUtils sortPointers:content_ps];
    
    //2. 全局防重;
    AICMVNodeBase *result = [AINetIndexUtils getAbsoluteMatching_General:content_ps sort_ps:sort_ps except_ps:nil getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
        return [AINetUtils refPorts_All4Value:item_p];
    } at:at ds:DefaultDataSource type:ATDefault];
    
    //3. 无则新构建;
    if (!ISOK(result, AICMVNodeBase.class)) {
        result = [[AICMVNode alloc] init];
        result.pointer = [SMGUtils createPointer:kPN_CMV_NODE algsType:at dataSource:DefaultDataSource isOut:false type:ATDefault];
        result.delta_p = delta_p;
        result.urgentTo_p = urgentTo_p;
    }
    
    //4. 增强关联;
    [AINetUtils insertRefPorts_AllMvNode:result value_p:result.delta_p difStrong:1];//引用插线
    [AINetUtils insertRefPorts_AllMvNode:result value_p:result.urgentTo_p difStrong:1];//引用插线
    [theNet setMvNodeToDirectionReference:result difStrong:urgentTo];//difStrong暂时先相等;

    //5. 存储cmvNode
    [SMGUtils insertNode:result];
    return result;
}

/**
 *  MARK:--------------------创建具象cansetFo (支持场景内防重)--------------------
 *  @desc 构建canset时不应全局防重,而是只以场景内防重 (不然这些canset的SPEFF值就窜了,比如在北京吃龙虾不行,在家是可以的) (参考3101b-todo5);
 */
+(AIFoNodeBase*) createConFoForCanset:(NSArray*)order sceneFo:(AIFoNodeBase*)sceneFo sceneTargetIndex:(NSInteger)sceneTargetIndex {
    NSArray *oldCansets = [sceneFo getConCansets:sceneTargetIndex];
    return [self createConFo_NoRepeat:order noRepeatArea_ps:oldCansets difStrong:1];
}

/**
 *  MARK:--------------------通用创建具象fo方法 (支持限定防重范围)--------------------
 *  @param noRepeatArea_ps : 防重范围 (传nil时为全局防重);
 *  @param difStrong : 默认传1,有特别要求时自定传什么值;
 */
+(AIFoNodeBase*) createConFo_NoRepeat:(NSArray*)order noRepeatArea_ps:(NSArray*)noRepeatArea_ps difStrong:(NSInteger)difStrong{
    //1. 防重_取本地全局绝对匹配;
    NSArray *content_ps = [AINetAbsFoUtils convertOrder2Alg_ps:order];
    AIFoNodeBase *result = [AINetIndexUtils getAbsoluteMatching_ValidPs:content_ps sort_ps:content_ps except_ps:nil noRepeatArea_ps:noRepeatArea_ps getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
        return [AINetUtils refPorts_All4Alg:itemAlg];
    } at:DefaultAlgsType ds:DefaultDataSource type:ATDefault];
    
    //TODOTOMORROW20241022: 这里也会有重复canset;
    
    NSString *newDesc = Pits2FStr(content_ps);
    for (AIKVPointer *oldCanset in noRepeatArea_ps) {
        AIFoNodeBase *oldFo = [SMGUtils searchNode:oldCanset];
        NSString *oldDesc = Pits2FStr(oldFo.content_ps);
        if (!result && [newDesc isEqualToString:oldDesc]) {
            //此处等FZ1013重跑跑不断点后,说明canset重复的bug彻底好了,到时此日志可删掉 (参考33107);
            ELog(@"发现内容重复 更新入scene: %@",Fo2FStr(oldFo));
        }
    }
    
    //2. 有则加强关联;
    if (ISOK(result, AIFoNodeBase.class)) {
        [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
    }else{
        //3. 无则新构建;
        result = [self createConFo:order difStrong:difStrong];
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------构建conFo--------------------
 *  @result notnull
 *  @callers
 *      1. 新帧输入时,构建matchAFo;
 *      2. 新帧输入时,构建protoFo;
 */
+(AIFrontOrderNode*) createConFo:(NSArray*)order difStrong:(NSInteger)difStrong{
    //1. foNode
    AIFrontOrderNode *foNode = [[AIFrontOrderNode alloc] init];

    //2. pointer (最终生成conFo时,全是ATDefault类型);
    foNode.pointer = [SMGUtils createPointer:kPN_FRONT_ORDER_NODE algsType:DefaultAlgsType dataSource:DefaultDataSource isOut:false type:ATDefault];

    //3. content_ps
    NSArray *content_ps = [AINetAbsFoUtils convertOrder2Alg_ps:order];
    
    //4. foNode.orders收集
    [foNode setContent_ps:content_ps];

    //5. foNode引用conAlg;
    [AINetUtils insertRefPorts_AllFoNode:foNode.pointer order_ps:foNode.content_ps ps:foNode.content_ps difStrong:difStrong];
    
    //6. 提取findAbsNode的deltaTimes;
    foNode.deltaTimes = [AINetAbsFoUtils convertOrder2DeltaTimes:order];
    
    //7. 存储foNode
    [SMGUtils insertNode:foNode];
    [AITest test8:foNode.content_ps type:ATDefault];
    return foNode;
}

@end
