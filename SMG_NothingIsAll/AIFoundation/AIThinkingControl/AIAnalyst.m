//
//  AIAnalyst.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/10.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AIAnalyst.h"

@implementation AIAnalyst

/**
 *  MARK:--------------------时序对比--------------------
 *  @desc 初步对比候选集是否适用于protoFo (参考26128-第1步);
 *  @result 返回cansetFo前段匹配度 & 以及已匹配的cutIndex截点;
 *  @version
 *      2022.05.30: 匹配度公式改成: 匹配度总和/proto长度 (参考26128-1-4);
 *      2022.05.30: R和H模式复用封装 (参考26161);
 *      2022.06.11: 修复反思子任务没有protoFo用于analyst的BUG (参考26224-方案图);
 */
+(AISolutionModel*) compareRCansetFo:(AIKVPointer*)cansetFo_p pFo:(AIMatchFoModel*)pFo demand:(ReasonDemandModel*)demand {
    
    //TODOTOMORROW20220611: 根据pFo,从protoFo中取出相应的帧数组;
    
    
    
    
    //1. 数据准备;
    BOOL isRoot = !demand.baseOrGroup;
    TOFoModel *demandBaseFo = (TOFoModel*)demand.baseOrGroup;
    AIFoNodeBase *maskFo = [SMGUtils searchNode:isRoot ? demand.protoFo : demand.regroupFo];
    
    //2. 已发生个数 (protoFo所有都是已发生) (参考26128-模型);
    NSInteger maskAleardayCount = isRoot ? maskFo.count : demandBaseFo.actionIndex;
    
    //3. 匹配判断;
    return [self compareCansetFo:cansetFo_p maskFo:maskFo maskAleardayCount:maskAleardayCount needBackMatch:false];
}

+(AISolutionModel*) compareHCansetFo:(AIKVPointer*)cansetFo_p targetFo:(TOFoModel*)targetFoM {
    //1. 数据准备;
    AIFoNodeBase *maskFo = [SMGUtils searchNode:targetFoM.content_p];
    
    //2. 已发生个数 (targetFo已行为化部分即已发生) (参考26161-模型);
    NSInteger maskAleardayCount = targetFoM.actionIndex;
    
    //3. 匹配判断;
    return [self compareCansetFo:cansetFo_p maskFo:maskFo maskAleardayCount:maskAleardayCount needBackMatch:true];
}

/**
 *  MARK:--------------------对比时序--------------------
 *  _param maskFo               : R时传入protoFo; H时传入targetFo;
 *  @param maskAleardayCount    : mask已发生个数 (R.proto全已发生,H.actionIndex前已发生);
 *  @param needBackMatch        : 是否需要后段匹配 (R不需要,H需要);
 */
+(AISolutionModel*) compareCansetFo:(AIKVPointer*)cansetFo_p maskFo:(AIFoNodeBase*)maskFo maskAleardayCount:(NSInteger)maskAleardayCount needBackMatch:(BOOL)needBackMatch{
    //1. 数据准备;
    AISolutionModel *result = nil;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    NSInteger lastMatchAtProtoIndex = -1;   //proto的匹配进度;
    CGFloat sumMatchValue = 0;              //累计匹配度;
    NSInteger cansetCutIndex = -1;          //canset的cutIndex,也已在proto中发生;
    
    //2. 前段: cansetFo从前到后,分别在proto中找匹配;
    for (NSInteger i = 0; i < cansetFo.count; i++) {
        AIKVPointer *cansetA_p = ARR_INDEX(cansetFo.content_ps, i);
        CGFloat itemMatchValue = 0;
        
        //3. 继续从proto后面未找过的部分里,找匹配;
        for (NSInteger j = lastMatchAtProtoIndex + 1; j < maskAleardayCount; j++) {
            AIKVPointer *protoA_p = ARR_INDEX(maskFo.content_ps, j);
            
            //4. 对比两个概念匹配度;
            itemMatchValue = [self compareCansetAlg:cansetA_p protoAlg:protoA_p];
            
            //5. 匹配成功,则更新匹配进度,并break报喜;
            if (itemMatchValue > 0) {
                lastMatchAtProtoIndex = j;
                break;
            }
        }
        
        //6. 匹配成功时: 结算这一位,继续下一位;
        if (itemMatchValue > 0) {
            sumMatchValue += itemMatchValue;
        }else{
            //7. 前中段截点: 匹配不到时,说明前段结束,前段proto全含canset,到cansetCutIndex为截点 (参考26128-1-1);
            cansetCutIndex = i - 1;
            break;
        }
    }
    
    //8. 计算前段匹配度 (参考26128-1-4);
    CGFloat frontMatchValue = sumMatchValue / maskAleardayCount;
    
    //9. 找到了`前中段`截点 => 则初步为有效方案 (参考26128-1-3);
    if (cansetCutIndex != -1 && frontMatchValue > 0) {
        
        //10. 后段: 从canset后段,找maskFo目标 (R不需要后段匹配,H需要);
        if (needBackMatch) {
            //a. 数据准备mask目标帧
            CGFloat backMatchValue = 0;//后段匹配度
            NSInteger cansetTargetIndex = -1;//canset目标下标
            AIKVPointer *actionIndexA_p = ARR_INDEX(maskFo.content_ps, maskAleardayCount);
            
            //b. 分别对canset后段,对比两个概念匹配度;
            for (NSInteger i = cansetCutIndex + 1; i < cansetFo.count; i++) {
                AIKVPointer *cansetA_p = ARR_INDEX(cansetFo.content_ps, i);
                CGFloat checkBackMatchValue = [self compareCansetAlg:cansetA_p protoAlg:actionIndexA_p];
                
                //c. 匹配成功时: 记下匹配度和目标下标;
                if (checkBackMatchValue > 0) {
                    backMatchValue = checkBackMatchValue;
                    cansetTargetIndex = i;
                    break;
                }
            }
            
            //d. 后段成功;
            if (cansetTargetIndex > -1) {
                result = [AISolutionModel newWithCansetFo:cansetFo_p maskFo:maskFo.pointer frontMatchValue:frontMatchValue backMatchValue:backMatchValue cutIndex:cansetCutIndex targetIndex:cansetTargetIndex];
            }
            if (!result) NSLog(@"itemCanset不适用当前场景:%ld",cansetFo_p.pointerId);
        }else{
            //11. 后段: R不判断后段;
            result = [AISolutionModel newWithCansetFo:cansetFo_p maskFo:maskFo.pointer frontMatchValue:frontMatchValue backMatchValue:1 cutIndex:cansetCutIndex targetIndex:cansetFo.count];
        }
    }
    return result;
}

/**
 *  MARK:--------------------对比两个概念匹配度--------------------
 *  @result 返回0到1 (0:完全不一样 & 1:完全一样) (参考26127-TODO5);
 *  @version
 *      2022.06.08: 排序公式改为sumNear / nearCount (参考2619j-TODO5);
 */
+(CGFloat) compareCansetAlg:(AIKVPointer*)cansetAlg_p protoAlg:(AIKVPointer*)protoAlg_p{
    //1. 数据准备;
    AIAlgNodeBase *cansetAlg = [SMGUtils searchNode:cansetAlg_p];
    AIAlgNodeBase *protoAlg = [SMGUtils searchNode:protoAlg_p];
    AIKVPointer *cansetFirstV_p = ARR_INDEX(cansetAlg.content_ps, 0);
    AIKVPointer *protoFirstV_p = ARR_INDEX(protoAlg.content_ps, 0);
    NSString *cansetAT = cansetFirstV_p.algsType;
    NSString *protoAT = protoFirstV_p.algsType;
    
    //2. 先对比二者是否同区;
    if (![cansetAT isEqualToString:protoAT]) {
        return 0;
    }
    
    //3. 找出二者稀疏码同标识的;
    __block CGFloat sumNear = 0;
    __block int nearCount = 0;
    for (AIKVPointer *cansetV in cansetAlg.content_ps) {
        for (AIKVPointer *protoV in protoAlg.content_ps) {
            if ([cansetV.dataSource isEqualToString:protoV.dataSource]) {
                
                //4. 对比稀疏码相近度 & 并累计;
                CGFloat near = [self compareCansetValue:cansetV protoValue:protoV];
                if (near < 1) {
                    sumNear += near;
                    nearCount ++;
                }
            }
        }
    }
    return nearCount > 0 ? sumNear / nearCount : 1;
}

/**
 *  MARK:--------------------对比稀疏码相近度--------------------
 *  @result 返回0到1 (0:稀疏码完全不同, 1稀疏码完全相同) (参考26127-TODO6);
 */
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p{
    //1. 取稀疏码值;
    double cansetData = [NUMTOOK([AINetIndex getData:cansetV_p]) doubleValue];
    double protoData = [NUMTOOK([AINetIndex getData:protoV_p]) doubleValue];
    
    //2. 计算出nearV (参考25082-公式1);
    double delta = fabs(cansetData - protoData);
    double span = [AINetIndex getIndexSpan:protoV_p.algsType ds:protoV_p.dataSource isOut:protoV_p.isOut];
    double nearV = (span == 0) ? 1 : (1 - delta / span);
    return nearV;
}

@end
