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
#import "AIAlgNodeBase.h"
#import "AIFoNodeBase.h"
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

//单个祖母的行为化
+(NSArray*) convert2Out_Single:(AIKVPointer*)curAlg_p{
    //1. 数据准备;
    if (!curAlg_p) {
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 本身即是isOut时,直接行为化返回;
    if (curAlg_p.isOut) {
        [result addObject:curAlg_p];
    }else{
        //3. 直接对当前祖母进行cHav并行为化;
        AIAlgNodeBase *havAlg = [ThinkingUtils dataOut_GetCHavAlgNode:curAlg_p.algsType dataSource:curAlg_p.dataSource];
        NSArray *havAlgResult = [self convert2Out_HavAlg:havAlg];
        
        //4. hav行为化成功;
        if (ARRISOK(havAlgResult)) {
            [result addObjectsFromArray:havAlgResult];
        }else{
            //5. hav行为化失败,则对curAlg的subAlg & subValue分别判定; (目前仅支持a2+v1各一个)
            AIAlgNodeBase *curAlg = [SMGUtils searchObjectForPointer:curAlg_p fileName:FILENAME_Node time:cRedisNodeTime];
            if (!curAlg) {
                return nil;
            }
            if (curAlg.content_ps.count == 2) {
                AIKVPointer *first_p = ARR_INDEX(curAlg.content_ps, 0);
                AIKVPointer *second_p = ARR_INDEX(curAlg.content_ps, 1);
                AIKVPointer *subAlg_p = nil;
                AIKVPointer *subValue_p = nil;
                if ([PATH_NET_ALG_ABS_NODE isEqualToString:first_p.folderName]) {
                    subAlg_p = first_p;
                }else if([PATH_NET_VALUE isEqualToString:first_p.folderName]){
                    subValue_p = first_p;
                }else if([PATH_NET_ALG_ABS_NODE isEqualToString:second_p.folderName]){
                    subAlg_p = second_p;
                }else if([PATH_NET_VALUE isEqualToString:second_p.folderName]){
                    subValue_p = second_p;
                }
                
                //6. 两个值各自分配成功则进入下一步;
                if (subAlg_p && subValue_p) {
                    
                    //7. 对subHavAlg行为化; (成功则收集,并开始进行 "变化" 行为化);
                    AIAlgNodeBase *subHavAlg = [ThinkingUtils dataOut_GetCHavAlgNode:subAlg_p.algsType dataSource:subAlg_p.dataSource];
                    NSArray *subHavResult = [self convert2Out_HavAlg:subHavAlg];
                    if (ARRISOK(subHavResult)) {
                        [result addObjectsFromArray:subHavResult];
                        
                        
                        //TODOTOMORROW:
                        //8. 对subValue进行cGreater/cLess
                        //简单暴力方案:
                        //此处还未发现具象坚果,所以只需先判定,subValue的cGreater和cLess是可以被变化的,即可;
                        
                        //精细靠谱方案:
                        //1. 我们从subFo中,读取到我们所得到的结果,便是 "预测信息";
                        //2. 将 "预测信息" 中的对应标识的"预测subValue",与 "诉求信息" subValue进行对比;
                        //3. 将此两者信息进行类比,得出一个cGreater/cLess,后判定其行为化可行与否;
                        
                    }
                }
            }
        }
        
        ////1. 根据havAlg构建成ThinkOutAlgModel
        ////2. 将DemandModel->TOMvModel->TOFoModel->TOAlgModel的模型结构化关系整理清晰;
        
    }
    
    return result;
}

//对单个havAlg进行行为化
+(NSArray*) convert2Out_HavAlg:(AIAlgNodeBase*)havAlg{
    //1. 数据检查
    if (!havAlg) {
        return nil;
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
                return foResult;
            }
        }
    }
    return nil;
}

@end
