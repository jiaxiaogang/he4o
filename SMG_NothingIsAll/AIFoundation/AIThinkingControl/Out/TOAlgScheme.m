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

@implementation TOAlgScheme

//对一个rangeOrder进行行为化;
+(NSArray*) convert2Out:(NSArray*)curAlg_ps{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (ARRISOK(curAlg_ps)) {
        
        //2. 依次单个祖母行为化
        for (AIKVPointer *curAlg_p in curAlg_ps) {
            NSArray *singleResult = [TOAlgScheme convert2Out_Single:curAlg_p];
            
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

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================


/**
 *  MARK:--------------------单个祖母的行为化--------------------
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
        //3. 第2级: 直接对当前祖母进行cHav并行为化;
        AIAlgNodeBase *havAlg = [ThinkingUtils dataOut_GetCHavAlgNode:curAlg_p.algsType dataSource:curAlg_p.dataSource];
        [self convert2Out_HavAlg:havAlg success:^(AIFoNodeBase *havFo, NSArray *actions) {
            //4. hav行为化成功;
            [result addObjectsFromArray:actions];
        } failure:^{
            //5. 第3级: 对curAlg的(subAlg&subValue)分别判定; (目前仅支持a2+v1各一个)
            AIAlgNodeBase *curAlg = [SMGUtils searchObjectForPointer:curAlg_p fileName:FILENAME_Node time:cRedisNodeTime];
            if (!curAlg) {
                return;
            }
            
            //6. 将curAlg.content_ps提取为subAlg_p和subValue_p;
            if (curAlg.content_ps.count == 2) {
                AIKVPointer *first_p = ARR_INDEX(curAlg.content_ps, 0);
                AIKVPointer *second_p = ARR_INDEX(curAlg.content_ps, 1);
                AIKVPointer *subAlg_p = nil;
                AIKVPointer *subValue_p = nil;
                if ([PATH_NET_ALG_ABS_NODE isEqualToString:first_p.folderName]) {
                    subAlg_p = first_p;
                }else if([PATH_NET_ALG_ABS_NODE isEqualToString:second_p.folderName]){
                    subAlg_p = second_p;
                }
                if([PATH_NET_VALUE isEqualToString:first_p.folderName]){
                    subValue_p = first_p;
                }else if([PATH_NET_VALUE isEqualToString:second_p.folderName]){
                    subValue_p = second_p;
                }
                if (!subAlg_p || !subValue_p) {
                    return;
                }
                
                //7. 两个值各自分配成功,对subHavAlg行为化; (坚果树会掉坚果);
                AIAlgNodeBase *subHavAlg = [ThinkingUtils dataOut_GetCHavAlgNode:subAlg_p.algsType dataSource:subAlg_p.dataSource];
                [self convert2Out_HavAlg:subHavAlg success:^(AIFoNodeBase *havFo, NSArray *subHavActions) {
                    [result addObjectsFromArray:subHavActions];
                    
                    //8. 两个值各自分配成功,对subValue行为化; (坚果会掉到树下,我们可以飞过去吃) 参考图109_subView行为化;
                    if (ISOK(havFo, AINetAbsFoNode.class)) {
                        AINetAbsFoNode *subHavFo = (AINetAbsFoNode*)havFo;
                        
                        //9. 从subHavFo联想其"具象序列":conSubHavFo; (仅支持一个)
                        AIFoNodeBase *conSubHavFo = [ThinkingUtils getNodeFromPort:ARR_INDEX(subHavFo.conPorts, 0)];
                        if (ISOK(conSubHavFo, AIFoNodeBase.class)) {
                            
                            //10. 从conSubHavFo中,找到与conSubHavFo.subValue作为预测信息;
                            for (AIKVPointer *order_p in conSubHavFo.orders_kvp) {
                                
                                if ([ThinkingUtils checkHavConAlg:order_p absAlg:subAlg_p]) {
                                    AIAlgNodeBase *forecastAlg = [SMGUtils searchObjectForPointer:order_p fileName:FILENAME_Node time:cRedisNodeTime];
                                    if (forecastAlg) {
                                        for (AIKVPointer *forecast_p in forecastAlg.content_ps) {
                                            if ([STRTOOK(forecast_p.identifier) isEqualToString:subValue_p.identifier]) {
                                                //11. 将诉求信息:subValue与预测信息:conSubHavFo.subValue进行类比,并得出cLess/cGreater;
                                                [SMGUtils searchObjectForPointer:subValue_p fileName:FILENAME_Value time:cRedisValueTime];
                                                
                                                
                                                [SMGUtils searchObjectForPointer:forecast_p fileName:FILENAME_Value time:cRedisValueTime];
                                                
                                                
                                                //对以上两个值进行对比,并得出是要找cLess或cGreater;
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } failure:nil];
            }
        }];
        
        
        ////1. 根据havAlg构建成ThinkOutAlgModel
        ////2. 将DemandModel->TOMvModel->TOFoModel->TOAlgModel的模型结构化关系整理清晰;
        
    }
    
    return result;
}

/**
 *  MARK:--------------------对单个havAlg进行行为化--------------------
 *  1. 先根据havAlg取到havFo;
 *  2. 再判断havFo中的rangeOrder的行为化;
 *  @param success : 行为化成功则返回(havFo + 行为序列); (havFo notnull, actions notnull)
 */
+(void) convert2Out_HavAlg:(AIAlgNodeBase*)havAlg success:(void(^)(AIFoNodeBase *havFo,NSArray *actions))success failure:(void(^)())failure{
    //1. 数据检查
    if (!havAlg) {
        failure();
        return;
    }
    
    //2. 根据havAlg联想时序,并找出新的解决方案,与新的行为化的祖母,与新的条件祖母;
    for (NSInteger i = 0; i < cHavNoneAssFoCount; i ++) {
        AIPort *refPort = ARR_INDEX(havAlg.refPorts, i);
        AIFoNodeBase *havFo = [SMGUtils searchObjectForPointer:refPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
        
        //3. 取出havFo除第一个和最后一个之外的中间rangeOrder
        if (havFo != nil && havFo.orders_kvp.count > 2) {
            NSArray *foRangeOrder = ARR_SUB(havFo.orders_kvp, 1, havFo.orders_kvp.count - 2);
            NSArray *foResult = [TOAlgScheme convert2Out:foRangeOrder];
            if (ARRISOK(foResult)) {
                success(havFo,foResult);
                return;
            }
        }
    }
    failure();
}

@end
