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
 *  MARK:--------------------时序比对--------------------
 *  @desc 初步比对候选集是否适用于protoFo (参考26128-第1步);
 *  @result 返回cansetFo前段匹配度 & 以及已匹配的cutIndex截点;
 *  @version
 *      2022.05.30: 匹配度公式改成: 匹配度总和/proto长度 (参考26128-1-4);
 *      2022.05.30: R和H模式复用封装 (参考26161);
 *      2022.06.11: 修复反思子任务没有protoFo用于analyst的BUG (参考26224-方案图);
 *      2022.06.11: 改用pFo参与analyst算法比对 & 并改取pFo已发生个数计算方式 (参考26232-TODO3&5&6);
 *      2022.09.15: 导致任务的maskFo不从demand取,而是从pFo取 (因为它在推进时会变化) (参考27097-todo3);
 *      2022.11.03: compareHCansetFo比对中复用alg相似度 (参考27175-3);
 *      2022.11.20: 持久化复用: 支持indexDic复用和概念matchValue复用 (参考20202-3&4);
 */
+(AISolutionModel*) compareRCansetFo:(AIKVPointer*)cansetFo_p pFo:(AIMatchFoModel*)pFo demand:(ReasonDemandModel*)demand {
    //1. 数据准备;
    BOOL isRoot = !demand.baseOrGroup;
    TOFoModel *demandBaseFo = (TOFoModel*)demand.baseOrGroup;
    
    //3. 取pFo已发生个数 (参考26232-TODO3);
    NSInteger pAleardayCount = 0;
    if (isRoot) {
        //a. 根R任务时 (参考26232-TODO5);
        pAleardayCount = pFo.cutIndex + 1;
    }else{
        //b. 子R任务时 (参考26232-TODO6);
        pAleardayCount = [SMGUtils filterArr:pFo.indexDic2.allValues checkValid:^BOOL(NSNumber *item) {
            int maskIndex = item.intValue;
            return maskIndex <= demandBaseFo.actionIndex;
        }].count;
    }
    
    //4. 匹配判断;
    return [self compareCansetFo:cansetFo_p ptAleardayCount:pAleardayCount isH:false basePFoOrTargetFoModel:pFo];
}

+(AISolutionModel*) compareHCansetFo:(AIKVPointer*)cansetFo_p targetFo:(TOFoModel*)targetFoM {
    //1. 已发生个数 (targetFo已行为化部分即已发生) (参考26161-模型);
    NSInteger tAleardayCount = targetFoM.actionIndex;
    
    //2. 匹配判断;
    return [self compareCansetFo:cansetFo_p ptAleardayCount:tAleardayCount isH:true basePFoOrTargetFoModel:targetFoM];
}

/**
 *  MARK:--------------------比对时序--------------------
 *  @param ptAleardayCount      : ptFo已发生个数:
 *                                  1. 根R=cutIndex+1
 *                                  2. 子R=父actionIndex对应indexDic条数;
 *                                  3. H.actionIndex前已发生;
 *  @param isH                  : 是否需要后段匹配 (R不需要传false,H需要传true);
 *  @version
 *      2022.06.12: 每帧analyst都映射转换成maskFo的帧元素比对 (参考26232-TODO4);
 *      2022.11.03: 复用alg相似度 (参考27175-2&3);
 *      2022.11.20: 改为match与canset比对,复用indexDic和alg相似度 (参考27202-3&4&5);
 */
+(AISolutionModel*) compareCansetFo:(AIKVPointer*)cansetFo_p ptAleardayCount:(NSInteger)ptAleardayCount isH:(BOOL)isH basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel {
    //1. 数据准备;
    AISolutionModel *result = nil;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    CGFloat sumMatchValue = 0;              //累计匹配度;
    NSInteger cansetCutIndex = -1;          //canset的cutIndex,也已在proto中发生;
    AIKVPointer *matchFo_p = [AISolutionModel getBaseFoFromBasePFoOrTargetFoModel:basePFoOrTargetFoModel];
    
    //2. 前段: cansetFo从前到后,分别在proto中找匹配;
    for (NSInteger i = 0; i < cansetFo.count; i++) {
        //3. 继续从proto后面未找过的部分里,找匹配;
        CGFloat itemMatchValue = [self compareCansetAlg:i cansetFo:cansetFo_p matchFo:matchFo_p checkMatchIndexBlock:^BOOL(NSInteger matchIndex) {
            return matchIndex < ptAleardayCount; //判断matchIndex属于前段;
        }];
        
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
    CGFloat frontMatchValue = sumMatchValue / ptAleardayCount;
    
    //9. 找到了`前中段`截点 => 则初步为有效方案 (参考26128-1-3);
    if (cansetCutIndex != -1 && frontMatchValue > 0) {
        
        //10. 后段: 从canset后段,找maskFo目标 (R不需要后段匹配,H需要);
        if (isH) {
            //a. 数据准备mask目标帧
            CGFloat backMatchValue = 0;//后段匹配度
            NSInteger cansetTargetIndex = -1;//canset目标下标
            
            //b. 分别对canset后段,比对两个概念匹配度;
            for (NSInteger i = cansetCutIndex + 1; i < cansetFo.count; i++) {
                
                //b. 匹配到后段,则复用来相似度;
                CGFloat checkBackMatchValue = [self compareCansetAlg:i cansetFo:cansetFo_p matchFo:matchFo_p checkMatchIndexBlock:^BOOL(NSInteger matchIndex) {
                    return matchIndex == ptAleardayCount; //判断matchIndex属于后段;
                }];
                
                //c. 匹配成功时: 记下匹配度和目标下标;
                if (checkBackMatchValue > 0) {
                    backMatchValue = checkBackMatchValue;
                    cansetTargetIndex = i;
                    break;
                }
            }
            
            //d. 后段成功;
            if (cansetTargetIndex > -1) {
                result = [AISolutionModel newWithCansetFo:cansetFo_p frontMatchValue:frontMatchValue backMatchValue:backMatchValue cutIndex:cansetCutIndex targetIndex:cansetTargetIndex basePFoOrTargetFoModel:basePFoOrTargetFoModel];
            }
            if (!result) NSLog(@"itemCanset不适用当前场景:%ld",cansetFo_p.pointerId);
        }else{
            //11. 后段: R不判断后段;
            result = [AISolutionModel newWithCansetFo:cansetFo_p frontMatchValue:frontMatchValue backMatchValue:1 cutIndex:cansetCutIndex targetIndex:cansetFo.count basePFoOrTargetFoModel:basePFoOrTargetFoModel];
        }
    }
    return result;
}

/**
 *  MARK:--------------------对比canset和match (复用indexDic和相似度)--------------------
 *  @desc 对比canset的元素和match的元素;
 *          1. 复用indexDic: canset和match的映射关系本来就存在indexDic中;
 *          2. matchIndex: 根据indexDic取到matchIndex,当matchIndex<ptAleardayCount时,即为前段,=时为后段;
 *          3. 复用matchValue: 然后将cansetIndex和matchIndex对应二者的持久化概念相似度复用返回即可;
 *  @param checkMatchIndexBlock : 根据matchIndex检查是否要继续 (比如前段时:matchIndex在后段就不继续,或者在后段时matchIndex在前段也不继续);
 *  @version
 *      2022.11.20: 初版: match与canset比对,复用indexDic和alg相似度 (参考27202-3&4&5);
 */
+(CGFloat) compareCansetAlg:(NSInteger)cansetIndex cansetFo:(AIKVPointer*)cansetFo_p matchFo:(AIKVPointer*)matchFo_p checkMatchIndexBlock:(BOOL(^)(NSInteger matchIndex))checkMatchIndexBlock{
    //1. 数据准备;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
    
    //2. 复用indexDic;
    NSDictionary *indexDic = [cansetFo getAbsIndexDic:matchFo.pointer];
    
    //3. 根据indexDic取出matchIndex;
    NSInteger matchIndex = NUMTOOK([SMGUtils filterSingleFromArr:indexDic.allKeys checkValid:^BOOL(NSNumber *key) {
        return cansetIndex == NUMTOOK([indexDic objectForKey:key]).integerValue;
    }]).integerValue;
    
    //4. 检查matchIndex: 前后段不匹配时,直接返0;
    if (!checkMatchIndexBlock(matchIndex)) return 0;
    
    //5. 前后段匹配时: 返回复用matchValue相似度;
    AIKVPointer *cansetA_p = ARR_INDEX(cansetFo.content_ps, cansetIndex);
    AIKVPointer *matchA_p = ARR_INDEX(matchFo.content_ps, matchIndex);
    AIAlgNodeBase *cansetA = [SMGUtils searchNode:cansetA_p];
    CGFloat matchValue = [cansetA getAbsMatchValue:matchA_p];
    [AITest test16:matchValue];
    return matchValue;
}


/**
 *  MARK:--------------------比对两个概念匹配度--------------------
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
    
    //2. 先比对二者是否同区;
    if (![cansetAT isEqualToString:protoAT]) {
        return 0;
    }
    
    //3. 找出二者稀疏码同标识的;
    __block CGFloat sumNear = 0;
    __block int nearCount = 0;
    for (AIKVPointer *cansetV in cansetAlg.content_ps) {
        for (AIKVPointer *protoV in protoAlg.content_ps) {
            if ([cansetV.dataSource isEqualToString:protoV.dataSource]) {
                
                //4. 比对稀疏码相近度 & 并累计;
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
 *  MARK:--------------------比对稀疏码相近度--------------------
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
