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

//MARK:===============================================================
//MARK:                 < 比对分析两条Solution候选方案 >
//MARK:===============================================================

static int cansetIsMatchSuccess_S = 0;
static int cansetIsMatchFailure_S = 0;
static int protoIsMatchSuccess_S = 0;
static int protoIsMatchFailure_S = 0;

static int cansetIsMatchSuccess = 0;
static int cansetIsMatchFailure = 0;
static int protoIsMatchSuccess = 0;
static int protoIsMatchFailure = 0;

static BOOL tempSwitch = true;

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
        
        
        //TODOTOMORROW20221120: 反思也复用indexDic和matchValue (参考26292-6);
        //1. 反思本来就是从protoCansets中,找出当前欲尝试canset之间最相似的五条;
        //2. 然后根据这五条的评分,来反思当前欲尝试的大概会怎么样;
        //3. 各个canset间是同层,所以无法复用indexDic和matchValue;
        //4. 方案1: 此处不复用了先;
        //5. 方案2: 反思是不是应该向抽象走走,毕竟protoCansets全只是解决方案,它们估计5条也反思不出个所以然;
        //          > 所以,,,以前执行checkCanset都发生了啥?它们存在effectDic中?
        //          > 所以,,,如果向着抽象反思,那么是canset的再抽象? (行为化结束时类比?发生负mv时???);
        //          > 所以,,,如果 是新的canset呢?没抽象呢?
        //          > 所以,,,如果是一个成熟的任务,突然来了一个新的canset,经验里明明知道它坑,但却反思不到?因为是新的canset没关联?
        
        //分析: 从同层进行反思,这应该是原则性错误 (因为同层再相似,也根本场景不匹配,不是一回事);
        
        
        
        
        
        
        
        
        
        //TODOTOMORROW20221103: 把用来获取cansets的pFo传进来,复用相似度 (参考27173-todo1);
        //TODOTOMORROW20221101: 这里的checkCanset和otherCanset在同层中,而同层间,是没有matchDic缓存的 (因为cansets是从conPorts中取的) (参考27172-2);
        //TODOTOMORROW20221104: 实际跑起来调试下此处的checkCanset.basePFoOrTargetFoModel的抽具象关系........;
        AIFoNodeBase *matchFo = [SMGUtils searchNode:checkCanset.getBaseFoFromBasePFoOrTargetFoModel];
        BOOL cansetIsMatchSuccess = false;
        for (int i = 0; i < matchFo.count; i++) {
            AIKVPointer *matchA = ARR_INDEX(matchFo.content_ps, i);
            //调试V2: 具象必须全含抽象,所以抽象的每一帧,都应该被canset中找到success,打出failure即错误;
            if ([TOUtils mIsC_1:checkAlg_p c:matchA]) {
                cansetIsMatchSuccess++;//83%
                cansetIsMatchSuccess = true;
            }
        }
        if (!cansetIsMatchSuccess) {
            //TODOTOMORROW20221108: 查此处未指向的情况原因,目前怀疑,需要重新训练下第1步,因为其间代码改过,可能结构会混乱些;
            cansetIsMatchFailure++;//17%
        }
        
        if (ISOK(checkCanset.basePFoOrTargetFoModel, AIMatchFoModel.class)) {
            BOOL protoIsMatchSuccess = false;
            for (int i = 0; i < matchFo.count; i++) {
                AIKVPointer *matchA = ARR_INDEX(matchFo.content_ps, i);
                //调试V2: 此处全是canset中<cutIndex部分: proto肯定是已发生部分,可以判断为protoIsMatch,打出failure即错误;
                AIMatchFoModel *pFo = (AIMatchFoModel*)checkCanset.basePFoOrTargetFoModel;
                AIKVPointer *protoA = ARR_INDEX(pFo.realMaskFo, i);
                if ([TOUtils mIsC_1:protoA c:matchA]) {
                    protoIsMatchSuccess++;//67%
                    protoIsMatchSuccess = true;
                }
            }
            if (!protoIsMatchSuccess) {
                protoIsMatchFailure++;//33%
            }
        }
        
        
        
        
        
        
        
        
        
        
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
    if (cansetIsMatchFailure + cansetIsMatchSuccess > 0) {
        CGFloat sucRate = (float)cansetIsMatchSuccess / (cansetIsMatchFailure + cansetIsMatchSuccess) * 100;
        NSLog(@"CHECKISMATCH_反思: cansetSuccess: %d %.0f%% cansetFailure: %d %.0f%%",cansetIsMatchSuccess,sucRate,cansetIsMatchFailure,100-sucRate);
    }
    if (protoIsMatchFailure + protoIsMatchSuccess > 0) {
        CGFloat sucRate = (float)protoIsMatchSuccess / (protoIsMatchFailure + protoIsMatchSuccess) * 100;
        NSLog(@"CHECKISMATCH_反思: protoSuccess: %d %.0f%% protoFailure: %d %.0f%%",protoIsMatchSuccess,sucRate,protoIsMatchFailure,100-sucRate);
    }
    
    //13. 直至二者循环完,即算出了最终综合匹配度排序;
    return frontSumNear;
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
