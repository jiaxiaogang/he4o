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
    return [self compareCansetFo:cansetFo_p ptAleardayCount:pAleardayCount isH:false getAlgMatchValueBlock:^CGFloat(NSInteger ptIndex, AIKVPointer *cansetAlg_p) {
        //5. 根据indexDic将ptIndex转成maskIndex,然后返回mask元素;
        int maskIndex = [NUMTOOK([pFo.indexDic2 objectForKey:@(ptIndex)]) intValue];
        AIKVPointer *maskAlg_p = ARR_INDEX(pFo.realMaskFo, maskIndex);
        
        
        
        //TODOTOMORROW20221102 复用相似度: R时返回的mask源于realMaskFo (参考27175-2):
        //此处最大的改动,就是cansetA要与matchAlg比对而不是protoAlg,所以:
        //TODOTOMORROW20221104: 先想一个例子,能够佐证某个S与proto不匹配时,却与当前认为的match 场景匹配,而我们采用了这个S来推进行为化...
        AIFoNodeBase *matchFo = [SMGUtils searchNode:pFo.matchFo];
        AIKVPointer *protoA = maskAlg_p;
        AIKVPointer *matchA = ARR_INDEX(matchFo.content_ps, ptIndex);
        if ([TOUtils mIsC_1:protoA c:matchA]) {
            NSLog(@"proto is match success");
        }else {
            NSLog(@"proto is match failure");
        }
        if ([TOUtils mIsC_1:cansetAlg_p c:matchA]) {
            NSLog(@"canset is match success");
        }else {
            NSLog(@"canset is match failure");
        }
        
        
        
        
        //5. 比对两个概念匹配度;
        return [self compareCansetAlg:cansetAlg_p protoAlg:maskAlg_p];
    } basePFoOrTargetFoModel:pFo];
}

+(AISolutionModel*) compareHCansetFo:(AIKVPointer*)cansetFo_p targetFo:(TOFoModel*)targetFoM {
    //1. 已发生个数 (targetFo已行为化部分即已发生) (参考26161-模型);
    NSInteger tAleardayCount = targetFoM.actionIndex;
    
    //2. 匹配判断;
    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoM.content_p];
    return [self compareCansetFo:cansetFo_p ptAleardayCount:tAleardayCount isH:true getAlgMatchValueBlock:^CGFloat(NSInteger ptIndex, AIKVPointer *cansetAlg_p) {
        //3. H时: ptFo=targetFo,所以直接复用canset抽象指向target的相似度 (参考27175-3);
        AIKVPointer *targetAlg_p = ARR_INDEX(targetFo.content_ps, ptIndex);
        AIAlgNodeBase *cansetAlg = [SMGUtils searchNode:cansetAlg_p];
        return [cansetAlg getAbsMatchValue:targetAlg_p];
    } basePFoOrTargetFoModel:targetFoM];
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
 */
+(AISolutionModel*) compareCansetFo:(AIKVPointer*)cansetFo_p ptAleardayCount:(NSInteger)ptAleardayCount isH:(BOOL)isH getAlgMatchValueBlock:(CGFloat(^)(NSInteger ptIndex,AIKVPointer *cansetAlg_p))getAlgMatchValueBlock basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel {
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
        for (NSInteger j = lastMatchAtProtoIndex + 1; j < ptAleardayCount; j++) {
            itemMatchValue = getAlgMatchValueBlock(j, cansetA_p);
            
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
                AIKVPointer *cansetA_p = ARR_INDEX(cansetFo.content_ps, i);
                CGFloat checkBackMatchValue = getAlgMatchValueBlock(ptAleardayCount,cansetA_p);
                
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

//MARK:===============================================================
//MARK:                 < 比对分析两条Solution候选方案 >
//MARK:===============================================================

/**
 *  MARK:--------------------比对checkCanset和它的otherCanset们--------------------
 *  @desc
 *      1. 为什么要单独为Solution比对分析写一个方法?
 *          a. 因为以往的比对方法不兼容,比如Solution候选集不源于TI流程,所以没有indexDic,说明如下:
 *          b. 在原fo比对算法中,假设了cansetFo和maskFo源于TI识别流程;
 *          c. 然后根据它的indexDic来分别比对下标下的alg匹配度的,但此处明显并没走TI流程,所以无法生成indexDic;
 *          d. 但此处是有抽具象关系的,所以直接对itemAlg判断mIsC抽具象关系即可 (即,有共同抽象,则可以进行比对);
 *          e. 所以单独写这个SolutionCansetFo比对方法,用共同抽象来判断元素的匹配关系;
 */
+(CGFloat) compareFromSolutionCanset:(AISolutionModel*)checkCanset otherCanset:(AISolutionModel*)otherCanset{
    
    //1. 数据准备_取出checkFo和otherFo;
    AIFoNodeBase *checkFo = [SMGUtils searchNode:checkCanset.cansetFo];
    AIFoNodeBase *otherFo = [SMGUtils searchNode:otherCanset.cansetFo];
    
    //2. 数据准备_记录otherFo的循环Start进度 (两层循环,其中other已推进的部分不算,所以要记录start);
    NSInteger otherStart = 0;
    
    //3. 数据准备_前段综合匹配度;
    CGFloat frontSumNear = 1.0f;
    
    //4. 两个fo循环判断匹配元素,并综合计算前段匹配度;
    for (NSInteger checkIndex = 0; checkIndex < checkCanset.cutIndex; checkIndex++) {
        
        //5. 取出checkAlg的抽象 (用于判断共同抽象);
        AIKVPointer *checkAlg_p = ARR_INDEX(checkFo.content_ps, checkIndex);
        AIAlgNodeBase *checkAlg = [SMGUtils searchNode:checkAlg_p];
        NSArray *checkAbs = [AINetUtils absPorts_All:checkAlg];
        
        
        
        
        //TODOTOMORROW20221103: 把用来获取cansets的pFo传进来,复用相似度 (参考27173-todo1);
        //TODOTOMORROW20221101: 这里的checkCanset和otherCanset在同层中,而同层间,是没有matchDic缓存的 (因为cansets是从conPorts中取的) (参考27172-2);
        //TODOTOMORROW20221104: 实际跑起来调试下此处的checkCanset.basePFoOrTargetFoModel的抽具象关系........;
        AIFoNodeBase *matchFo = [SMGUtils searchNode:checkCanset.getBaseFoFromBasePFoOrTargetFoModel];
        for (int i = 0; i < matchFo.count; i++) {
            AIKVPointer *matchA = ARR_INDEX(matchFo.content_ps, i);
            if ([TOUtils mIsC_1:checkAlg_p c:matchA]) {
                NSLog(@"第%d个: canset is match success",i);
            }
            
            if (ISOK(checkCanset.basePFoOrTargetFoModel, AIMatchFoModel.class)) {
                AIMatchFoModel *pFo = (AIMatchFoModel*)checkCanset.basePFoOrTargetFoModel;
                AIKVPointer *protoA = ARR_INDEX(pFo.realMaskFo, i);
                if ([TOUtils mIsC_1:protoA c:matchA]) {
                    NSLog(@"第%d个: proto is match success",i);
                }
            }
        }
        NSLog(@"'is match' CHECK FINISH");
        
        
        
        
        
        
        
        
        
        
        
        
        for (NSInteger otherIndex = otherStart; otherIndex < otherCanset.cutIndex; otherIndex++) {
            
            //6. 取出otherAlg的抽象 (用于判断共同抽象);
            AIKVPointer *otherAlg_p = ARR_INDEX(otherFo.content_ps, otherIndex);
            AIAlgNodeBase *otherAlg = [SMGUtils searchNode:otherAlg_p];
            NSArray *otherAbs = [AINetUtils absPorts_All:otherAlg];
            
            //7. 判断checkAlg与otherFo是否有共同的抽象;
            BOOL sameAbs = ARRISOK([SMGUtils filterArr:checkAbs checkValid:^BOOL(id item) {
                return [otherAbs containsObject:item];
            }]);
            
            //8. 如果checkAlg找到otherIndex;
            if (sameAbs) {
                
                //9. 则记录other的进度;
                otherStart = otherIndex + 1;
                
                //10. 后根据匹配上的alg,算出的匹配值;
                CGFloat near = [AIAnalyst compareCansetAlg:checkAlg_p protoAlg:otherAlg_p];
                
                //11. 并乘起来,作为最终的fo前段匹配度;
                frontSumNear *= near;
                break;
            }
        }
        //12. 如果循环最后也匹配不上_则没找到共同抽象的otherIndex,那跳过这条,继续下条;
    }
    
    //13. 直至二者循环完,即算出了最终综合匹配度排序;
    return frontSumNear;
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
