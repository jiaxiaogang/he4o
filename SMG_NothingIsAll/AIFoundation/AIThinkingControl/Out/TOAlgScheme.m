//
//  TOAlgScheme.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/4/19.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOAlgScheme.h"
#import "ThinkingUtils.h"
#import "AIKVPointer.h"
#import "AIAbsAlgNode.h"
#import "AINetAbsFoNode.h"
#import "AIPort.h"
#import "AINetIndex.h"

@implementation TOAlgScheme

//对一个rangeOrder进行行为化;
+(NSArray*) convert2Out:(NSArray*)curAlg_ps{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (ARRISOK(curAlg_ps)) {
        
        //2. 依次单个概念行为化
        for (AIKVPointer *curAlg_p in curAlg_ps) {
            NSArray *singleResult = [TOAlgScheme convert2Out_Single:curAlg_p];
            [theNV setNodeData:curAlg_p lightStr:@"o2"];
            //3. 行为化成功,则收集;
            if (ARRISOK(singleResult)) {
                [result addObjectsFromArray:singleResult];
            }else{
                
                //4. 有一个失败,则整个rangeOrder失败;
                return nil;
            }
        }
    }
    return result;
}


/**
 *  MARK:--------------------单个概念的行为化--------------------
 *  第1级: 直接判定curAlg_p为输出则收集;
 *  第2级: 直接对curAlg的cHav来行为化,成功则收集;
 *  第3级: 对curAlg下subValue和subAlg进行依次行为化,成功则收集;
 */
+(NSArray*) convert2Out_Single:(AIKVPointer*)curAlg_p{
    //1. 数据准备;
    if (!curAlg_p) {
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 第1级: 本身即是isOut时,直接行为化返回;
    if (curAlg_p.isOut) {
        [result addObject:curAlg_p];
    }else{
        //3. 第2级: 直接对当前概念进行cHav并行为化;
        AIAlgNodeBase *havAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:AnalogyInnerType_Hav algsType:curAlg_p.algsType dataSource:curAlg_p.dataSource];
        if (!havAlg) {
            NSLog(@"inner > error not found 有无大小 node");
        }
        [self convert2Out_RelativeAlg:havAlg success:^(AIFoNodeBase *havFo, NSArray *actions) {
            //4. hav行为化成功;
            [result addObjectsFromArray:actions];
        } failure:^{
            //5. 第3级: 对curAlg的(subAlg&subValue)分别判定; (目前仅支持a2+v1各一个)
            NSArray *subResult = ARRTOOK([self convert2Out_Single_Sub:curAlg_p]);
            [result addObjectsFromArray:subResult];
        }];
    }
    
    return result;
}

/**
 *  MARK:--------------------对单个概念的sub拆分行为化--------------------
 *  1. 对curAlg的(subAlg&subValue)分别判定;
 *  2. 目前仅支持 1 x subAlg + 1 x subValue (目前仅支持a2+v1各一个);
 *  3. TODO:支持"多个概念+多个value",建议"两个概念+两个value",然后,更复杂的情况用"抽象精简"和"具象展开"来解决;
 */
+(NSArray*) convert2Out_Single_Sub:(AIKVPointer*)curAlg_p{
    //1. 数据检查准备;
    AIAlgNodeBase *curAlg = [SMGUtils searchNode:curAlg_p];
    if (!curAlg) return nil;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 将curAlg.content_ps提取为subAlg_p和subValue_p;
    if (curAlg.content_ps.count == 2) {
        AIKVPointer *first_p = ARR_INDEX(curAlg.content_ps, 0);
        AIKVPointer *second_p = ARR_INDEX(curAlg.content_ps, 1);
        AIKVPointer *subAlg_p = nil;
        AIKVPointer *subValue_p = nil;
        if ([kPN_ALG_ABS_NODE isEqualToString:first_p.folderName]) {
            subAlg_p = first_p;
        }else if([kPN_ALG_ABS_NODE isEqualToString:second_p.folderName]){
            subAlg_p = second_p;
        }
        if([kPN_VALUE isEqualToString:first_p.folderName]){
            subValue_p = first_p;
        }else if([kPN_VALUE isEqualToString:second_p.folderName]){
            subValue_p = second_p;
        }
        if (!subAlg_p || !subValue_p) return nil;
        
        //3. 先对subHavAlg行为化; (坚果树会掉坚果);
        AIAlgNodeBase *subHavAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:AnalogyInnerType_Hav algsType:subAlg_p.algsType dataSource:subAlg_p.dataSource];
        [self convert2Out_RelativeAlg:subHavAlg success:^(AIFoNodeBase *havFo, NSArray *subHavActions) {
            
            //4. 再对subValue行为化; (坚果会掉到树下,我们可以飞过去吃) 参考图109_subValue行为化;
            if (!ISOK(havFo, AINetAbsFoNode.class)) return;
            AINetAbsFoNode *subHavFo = (AINetAbsFoNode*)havFo;
            
            //5. 从subHavFo联想其"具象序列":conSubHavFo;
            //TODO: 目前仅支持一个,随后要支持三个左右;
            AIFoNodeBase *conSubHavFo = [ThinkingUtils getNodeFromPort:ARR_INDEX(subHavFo.conPorts, 0)];
            if (!ISOK(conSubHavFo, AIFoNodeBase.class)) return;
            
            //6. 从conSubHavFo中,找到与forecastAlg_p预测概念指针;
            AIKVPointer *forecastAlg_p = nil;
            for (AIKVPointer *item_p in conSubHavFo.content_ps) {
                
                //7. 判断item_p是subAlg的具象节点;
                if ([ThinkingUtils containsConAlg:item_p absAlg:subAlg_p]) {
                    forecastAlg_p = item_p;
                    break;
                }
            }
            if (!forecastAlg_p) return;
            
            //8. 取出"预测"概念信息;
            AIAlgNodeBase *forecastAlg = [SMGUtils searchNode:forecastAlg_p];
            if (!forecastAlg) return;
            
            //8. 进一步取出预测微信息;
            AIKVPointer *forecastValue_p = [ThinkingUtils filterPointer:forecastAlg.content_ps identifier:subValue_p.identifier];
            if (!forecastValue_p) return;
            
            //9. 将诉求信息:subValue与预测信息:forecastValue进行类比;
            NSNumber *subValue = NUMTOOK([AINetIndex getData:subValue_p]);
            NSNumber *forecastValue = NUMTOOK([AINetIndex getData:forecastValue_p]);
            NSComparisonResult compareResult = [subValue compare:forecastValue];
            
            //10. 得出是要找cLess或cGreater;
            if (compareResult == NSOrderedSame) {
                [result addObjectsFromArray:subHavActions];//成功A;
                return;
            }else{
                AnalogyInnerType type = (compareResult == NSOrderedAscending) ? AnalogyInnerType_Greater : AnalogyInnerType_Less;
                AIAlgNodeBase *glAlg = [ThinkingUtils dataOut_GetAlgNodeWithInnerType:type algsType:subValue_p.algsType dataSource:subValue_p.dataSource];
                [self convert2Out_RelativeAlg:glAlg success:^(AIFoNodeBase *havFo, NSArray *actions) {
                    //TODO:有些预测确定,有些不那么确定;(未必就可以直接添加到行为中)
                    [result addObjectsFromArray:subHavActions];
                    [result addObjectsFromArray:actions];//成功B;
                } failure:nil];
            }
        } failure:nil];
    }
    return result;
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

/**
 *  MARK:--------------------"相对概念"的行为化--------------------
 *  1. 先根据havAlg取到havFo;
 *  2. 再判断havFo中的rangeOrder的行为化;
 *  @param success : 行为化成功则返回(havFo + 行为序列); (havFo notnull, actions notnull)
 */
+(void) convert2Out_RelativeAlg:(AIAlgNodeBase*)relativeAlg success:(void(^)(AIFoNodeBase *havFo,NSArray *actions))success failure:(void(^)())failure{
    //1. 数据检查
    if (!relativeAlg) {
        if (failure) failure();
        return;
    }
    
    //2. 找引用"相对概念"的内存中"相对时序",并行为化; (注: 一般不存在内存相对概念,此处代码应该不会执行);
    NSArray *memRefPorts = [SMGUtils searchObjectForPointer:relativeAlg.pointer fileName:kFNMemRefPorts time:cRTMemPort];
    BOOL memSuccess = [self convert2Out_RelativeFo_ps:[SMGUtils convertPointersFromPorts:memRefPorts] success:success];
    
    //3. 根据havAlg联想时序,并找出新的解决方案,与新的行为化的概念,与新的条件概念;
    if (!memSuccess) {
        NSArray *hdRefPorts = ARR_SUB(relativeAlg.refPorts, 0, cHavNoneAssFoCount);
        BOOL hdSuccess = [self convert2Out_RelativeFo_ps:[SMGUtils convertPointersFromPorts:hdRefPorts] success:success];
        
        //4. 行为化失败;
        if (!hdSuccess) {
            if (failure) failure();
        }
    }
}

/**
 *  MARK:--------------------"相对时序"的行为化--------------------
 *  @param relativeFo_ps    : 相对时序地址;
 *  @param success          : 回调传回: 相对时序 & 行为化结果;
 *  @result                 : 只要有一条行为化成功则返回true,否则false;
 *  注:
 *      1. 参数: 由方法调用者保证传入的是"相对时序"而不是普通时序
 *      2. 流程: 取出相对时序,并取rangeOrder,行为化并返回
 */
+(BOOL) convert2Out_RelativeFo_ps:(NSArray*)relativeFo_ps success:(void(^)(AIFoNodeBase *havFo,NSArray *actions))success {
    //1. 数据准备
    relativeFo_ps = ARRTOOK(relativeFo_ps);
    
    //2. 逐个尝试行为化
    for (AIPointer *relativeFo_p in relativeFo_ps) {
        AIFoNodeBase *relativeFo = [SMGUtils searchNode:relativeFo_p];
        
        //3. 取出havFo除第一个和最后一个之外的中间rangeOrder
        if (relativeFo != nil && relativeFo.content_ps.count > 2) {
            NSArray *foRangeOrder = ARR_SUB(relativeFo.content_ps, 1, relativeFo.content_ps.count - 2);
            NSArray *foResult = [TOAlgScheme convert2Out:foRangeOrder];
            if (ARRISOK(foResult)) {
                success(relativeFo,foResult);
                return true;
            }
        }
    }
    return false;
}

@end
