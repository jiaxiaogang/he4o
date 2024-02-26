//
//  TCCanset.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "TCCanset.h"

@implementation TCCanset

/**
 *  MARK:--------------------将sceneModel转成canset_ps (override算法) (参考29069-todo5)--------------------
 *  @desc 当前下面挂载的且有效的cansets: (当前cansets - 用优先级更高一级cansets);
 *  @version
 *      2023.04.23: BUG_修复差集取成了交集,导致总返回0条;
 *      2023.09.10: 支持H任务时的override算法 (指定targetIndex即可) (参考30127);
 */
+(NSArray*) getOverrideCansets:(AISceneModel*)sceneModel sceneTargetIndex:(NSInteger)sceneTargetIndex {
    //1. 数据准备;
    AIFoNodeBase *selfFo = [SMGUtils searchNode:sceneModel.scene];
    
    //2023.12.24: 性能测试记录 (结果: 此方法很卡) (参考31025-代码段-问题1);
    //  a. 记录此处为brother时,   共执行了: 300次 x 每次10ms     = 3s;
    //  b. 记录此处为father时,    共执行了: 16次  x 每次1ms      = 16ms;
    //  c. 记录此处为i时,         共执行了: 16次  x 每次125ms    = 2s;
    //2. 不同type的公式不同 (参考29069-todo5.3 & 5.4 & 5.5);
    if (sceneModel.type == SceneTypeBrother) {
        //3. 当前是brother时: (brother有效canset = brother.conCansets - 与father有迁移关联部分) (参考29069-todo5.3);
        NSArray *brotherConCansets = [AIFilter solutionCansetFilter:selfFo targetIndex:sceneTargetIndex];
        NSArray *brotherFilter_ps = [TCCanset getFilter_ps:sceneModel];
        NSArray *result = [SMGUtils removeSub_ps:brotherFilter_ps parent_ps:brotherConCansets];
        if (Log4TCCanset && result.count > 0) NSLog(@"测下override过滤生效 (B-F): 原有%ld - 过滤%ld => 结果%ld",brotherConCansets.count,brotherFilter_ps.count,result.count);
        return result;
    } else if (sceneModel.type == SceneTypeFather) {
        //4. 当前是father时: (father有效canset = father.conCansets - 与i有迁移关联部分) (参考29069-todo5.4);
        NSArray *fatherConCansets = [AIFilter solutionCansetFilter:selfFo targetIndex:sceneTargetIndex];
        NSArray *fatherFilter_ps = [TCCanset getFilter_ps:sceneModel];
        NSArray *result = [SMGUtils removeSub_ps:fatherFilter_ps parent_ps:fatherConCansets];
        if (Log4TCCanset && result.count > 0) NSLog(@"测下override过滤生效 (F-I): 原有%ld - 过滤%ld => 结果%ld",fatherConCansets.count,fatherFilter_ps.count,result.count);
        return result;
    } else if (sceneModel.type == SceneTypeI) {
        //4. 当前是i时: (i有效canset = i.conCansets) (参考29069-todo5.5);
        NSArray *iConCansets = [AIFilter solutionCansetFilter:selfFo targetIndex:sceneTargetIndex];
        if (Log4TCCanset && iConCansets.count > 0) NSLog(@"测下override过滤生效 (I): 结果%ld",iConCansets.count);
        return iConCansets;
    }
    return nil;
}

/**
 *  MARK:--------------------将canset_p转成cansetModel--------------------
 *  @desc 初步比对候选集是否适用于protoFo (参考26128-第1步);
 *  @param ptAleardayCount      : ptFo已发生个数: 即取得"canset的basePFoOrTargetFo推进到哪了"的截点 (aleardayCount = cutIndex+1 或 actionIndex);
 *                                  1. 根R=cutIndex+1
 *                                  2. 子R=父actionIndex对应indexDic条数;
 *                                  3. H.actionIndex前已发生;
 *                                  改: 在支持sceneTree后,统一传sceneModel.cutIndex + 1;
 *  @param sceneFo_p            : 当前cansetFo_p挂在哪个场景fo下就传哪个;
 *  @param basePFoOrTargetFoModel : 一用来取protoFo用,二用来传参给结果cansetModel用;
 *  @param sceneModel           : 此cansetModel是基于哪个sceneModel的就传哪个;
 *  @version
 *      2022.05.30: 匹配度公式改成: 匹配度总和/proto长度 (参考26128-1-4);
 *      2022.05.30: R和H模式复用封装 (参考26161);
 *      2022.06.11: 修复反思子任务没有protoFo用于analyst的BUG (参考26224-方案图);
 *      2022.06.11: 改用pFo参与analyst算法比对 & 并改取pFo已发生个数计算方式 (参考26232-TODO3&5&6);
 *      2022.06.12: 每帧analyst都映射转换成maskFo的帧元素比对 (参考26232-TODO4);
 *      2022.07.14: filter过滤器S的价值pk迭代: 将过滤负价值的,改成过滤无价值指向的 (参考27048-TODO4&TODO9);
 *      2022.07.20: filter过滤器不要求mv指向 (参考27055-步骤1);
 *      2022.09.15: 导致任务的maskFo不从demand取,而是从pFo取 (因为它在推进时会变化) (参考27097-todo3);
 *      2022.11.03: compareHCansetFo比对中复用alg相似度 (参考27175-3);
 *      2022.11.03: 复用alg相似度 (参考27175-2&3);
 *      2022.11.20: 改为match与canset比对,复用indexDic和alg相似度 (参考27202-3&4&5);
 *      2022.11.20: 持久化复用: 支持indexDic复用和概念matchValue复用 (参考20202-3&4);
 *      2022.12.03: 修复复用matchValue有时为0的问题 (参考27223);
 *      2022.12.03: 当canset前段有遗漏时,该方案无效 (参考27224);
 *      2023.01.08: filter过滤器加上条件满足过滤器-R任务部分 (参考28022);
 *      2023.01.08: filter过滤器V1末版说明: 根据28025,递归找match,proto,canset三者的映射,来判断条件满足,已废弃 (参考28023&28051);
 *      2023.01.08: 将R和H的时序比对,整理删除仅留下这个通用时序比对方法;
 *      2023.02.04: filter过滤器V2版本,解决原方式条件满足不完全问题 (参考28052);
 *      2023.02.04: 修复条件满足不完全问题 (参考28052);
 *      2023.02.17: 从Analyze整理到TCSolutionUtil中,因为它现在其实就是获取SolutionModel用的 (参考28084-1);
 *      2023.02.17: 废弃filter过滤器,并合并到此处来 (参考28084-2);
 *      2023.02.18: 计算前段竞争值 (参考28084-4);
 *      2023.03.16: 先用任意帧sp值>5脱离惰性期 (参考28182-todo9);
 *      2023.03.18: 惰性期阈值改为eff>2时脱离惰性期 (参考28185-todo6);
 *      2023.04.22: 关闭惰性期 (参考29073-方案);
 *      2023.04.30: 用迁移后cansetA与protoA来计算前段匹配度值 (参考29075-todo5);
 *      2024.01.19: 为每个CansetModel生成jiCenModel和tuiJuModel (参考31073-TODO1);
 *  @result 返回cansetFo前段匹配度 & 以及已匹配的cutIndex截点;
 */
+(TOFoModel*) convert2CansetModel:(AIKVPointer*)cansetFo_p sceneFo:(AIKVPointer*)sceneFo_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel ptAleardayCount:(NSInteger)ptAleardayCount isH:(BOOL)isH sceneModel:(AISceneModel*)sceneModel demand:(DemandModel*)demand{
    //1. 数据准备 & 复用indexDic & 取出pFoOrTargetFo;
    AIFoNodeBase *matchFo = [SMGUtils searchNode:sceneFo_p];
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    NSInteger matchTargetIndex = isH ? ptAleardayCount : matchFo.count;
    
    //2. 判断是否H任务 (H有后段,别的没有);
    int minCount = isH ? 2 : 1;
    if (Log4SolutionFilter) NSLog(@"S过滤器 checkItem: %@",Pit2FStr(cansetFo_p));
    if (cansetFo.count < minCount) return nil; //过滤1: 过滤掉长度不够的 (因为前段全含至少要1位,中段修正也至少要0位,后段H目标要1位R要0位);
    
    //3. 惰性期 (阈值为2: EFF默认值为1,达到阈值时触发) (参考28182-todo9 & 28185-todo6);
    if (Switch4DuoXinQi) {
        AIEffectStrong *effStrong = [TOUtils getEffectStrong:matchFo effectIndex:matchFo.count solutionFo:cansetFo_p];
        if (effStrong.hStrong <= 2) return nil;
        //NSLog(@"惰性期通过:%@",CLEANSTR(cansetFo.spDic));
    }
    
    //5. 根据sceneFo取得与canset的indexDic映射;
    NSDictionary *indexDic = [cansetFo getAbsIndexDic:sceneFo_p];
    [AITest test102:cansetFo];
    
    //2. 计算出canset的cutIndex (canset的cutIndex,也已在proto中发生) (参考26128-1-1);
    //7. 根据ptAleardayCount取出对应的cansetIndex,做为中段截点 (aleardayCount - 1 = cutIndex);
    NSInteger matchCutIndex = ptAleardayCount - 1;
    NSInteger cansetCutIndex = NUMTOOK([indexDic objectForKey:@(matchCutIndex)]).integerValue;
    
    //8. canset目标下标 (R时canset没有mv,所以要用count-1);
    NSInteger cansetTargetIndex = isH ? NUMTOOK([indexDic objectForKey:@(ptAleardayCount)]).integerValue : cansetFo.count - 1;
    if (cansetCutIndex < matchCutIndex) return nil; //过滤2: 判断canset前段是否有遗漏 (参考27224);
    
    if (cansetFo.count <= cansetCutIndex + 1) return nil; //过滤3: 过滤掉canset没后段的 (没可行为化的东西) (参考28052-4);
    
    //9. 递归找到protoFo;
    AIMatchFoModel *pFo = [self getPFo:cansetFo_p basePFoOrTargetFoModel:basePFoOrTargetFoModel];
    AIKVPointer *protoFo_p = pFo.baseRDemand.protoOrRegroupFo;
    AIFoNodeBase *protoFo = [SMGUtils searchNode:protoFo_p];
    
    //10. 判断protoFo对cansetFo条件满足 (返回条件满足的每帧间映射);
    NSArray *frontIndexDicModels = [self getFrontIndexDic:protoFo cansetFo:cansetFo cansetCutIndex:cansetCutIndex sceneModel:sceneModel];
    NSDictionary *protoFrontIndexDic = [SMGUtils convertArr2Dic:frontIndexDicModels kvBlock:^NSArray *(FrontIndexDicModel *obj) {
        return @[@(obj.cansetIndex),@(obj.protoIndex)];
    }];
    if (!DICISOK(protoFrontIndexDic)) return nil; //过滤4: 条件不满足时,直接返回nil (参考28052-2 & 28084-3);
    
    //4. 计算前段竞争值之匹配值 (参考28084-4);
    NSArray *frontNearData = [AINetUtils getNearDataByIndexDic:protoFrontIndexDic getAbsAlgBlock:^AIKVPointer *(NSInteger absIndex) {
        FrontIndexDicModel *model = [SMGUtils filterSingleFromArr:frontIndexDicModels checkValid:^BOOL(FrontIndexDicModel *o) {
            return o.cansetIndex == absIndex;
        }];
        if (model) return model.transferAlg_p;
        return nil;
    } getConAlgBlock:^AIKVPointer *(NSInteger conIndex) {
        return ARR_INDEX(protoFo.content_ps, conIndex);
    } callerIsAbs:true];
    CGFloat frontMatchValue = NUMTOOK(ARR_INDEX(frontNearData, 1)).floatValue;
    if (frontMatchValue == 0) return nil; //过滤5: 前段不匹配时,直接返回nil (参考26128-1-3);
    
    //5. 计算前段竞争值之强度竞争值 (参考28086-todo1);
    NSDictionary *matchFrontIndexDic = [SMGUtils filterDic:indexDic checkValid:^BOOL(NSNumber *key, id value) {
        return key.integerValue <= matchCutIndex;
    }];
    NSInteger sumStrong = [AINetUtils getSumConStrongByIndexDic:matchFrontIndexDic matchFo:sceneFo_p cansetFo:cansetFo_p];
    CGFloat frontStrongValue = (float)sumStrong / matchFrontIndexDic.count;
    
    //6. 计算中断竞争值;
    CGFloat midEffectScore = [TOUtils getEffectScore:matchFo effectIndex:matchTargetIndex solutionFo:cansetFo_p];
    CGFloat midStableScore = [TOUtils getStableScore:cansetFo startSPIndex:cansetCutIndex + 1 endSPIndex:cansetTargetIndex];
    
    //6. 后段: 找canset后段目标 和 后段匹配度 (H需要后段匹配, R不需要);
    TOFoModel *result = nil;
    if (isH) {
        //7. 后段匹配度 (后段不匹配时,直接返nil);
        NSDictionary *backIndexDic = [SMGUtils filterDic:indexDic checkValid:^BOOL(NSNumber *key, id value) {
            return key.integerValue == ptAleardayCount;
        }];
        CGFloat backMatchValue = [AINetUtils getMatchByIndexDic:backIndexDic absFo:sceneFo_p conFo:cansetFo_p callerIsAbs:true];
        if (backMatchValue == 0) return nil; //过滤6: 后段不匹配时,直接返回nil;
        
        //7. 后段强度竞争值;
        NSInteger backStrongValue = [AINetUtils getSumConStrongByIndexDic:backIndexDic matchFo:sceneFo_p cansetFo:cansetFo_p];
        
        //9. 后段成功;
        result = [TOFoModel newWithCansetFo:cansetFo_p sceneFo:sceneFo_p base:demand
                           protoFrontIndexDic:protoFrontIndexDic matchFrontIndexDic:matchFrontIndexDic
                              frontMatchValue:frontMatchValue frontStrongValue:frontStrongValue
                               midEffectScore:midEffectScore midStableScore:midStableScore
                                 backIndexDic:backIndexDic backMatchValue:backMatchValue backStrongValue:backStrongValue
                                     cutIndex:cansetCutIndex sceneCutIndex:matchCutIndex
                                  targetIndex:cansetTargetIndex sceneTargetIndex:matchTargetIndex
                       basePFoOrTargetFoModel:basePFoOrTargetFoModel baseSceneModel:sceneModel];
    }else{
        //11. 后段: R不判断后段;
        result = [TOFoModel newWithCansetFo:cansetFo_p sceneFo:sceneFo_p base:demand
                           protoFrontIndexDic:protoFrontIndexDic matchFrontIndexDic:matchFrontIndexDic
                              frontMatchValue:frontMatchValue frontStrongValue:frontStrongValue
                               midEffectScore:midEffectScore midStableScore:midStableScore
                                 backIndexDic:nil backMatchValue:1 backStrongValue:0
                                     cutIndex:cansetCutIndex sceneCutIndex:matchCutIndex
                                  targetIndex:cansetFo.count sceneTargetIndex:matchTargetIndex
                       basePFoOrTargetFoModel:basePFoOrTargetFoModel baseSceneModel:sceneModel];
    }
    
    //12. 伪迁移;
    [TCTransfer transferForModel:result];
    
    //13. 下帧初始化 (可接受反馈);
    [result pushNextFrame];
    return result;
}

/**
 *  MARK:--------------------HSolution转CansetModel--------------------
 *  @param rSceneModel 复用R的SceneModel,因为H任务没有独立的R场景树,它本来就是复用的R任务的场景树等;
 *  @version
 *      2024.02.21: V2-在迭代hSolutionV3时,将H任务转cansetModel单独写个方法,并将此方法中多余代码统统去掉不写;
 */
+(TOFoModel*) convert2HCansetModel:(AIKVPointer*)hCanset_p hSceneFo:(AIFoNodeBase*)hSceneFo targetFoModel:(TOFoModel*)targetFoModel hSceneCutIndex:(NSInteger)hSceneCutIndex rSceneModel:(AISceneModel*)rSceneModel hDemand:(HDemandModel*)hDemand {
    //1. 根据hScene和hCanset的映射,取出hCanset的目标帧等数据;
    AIFoNodeBase *hCansetFo = [SMGUtils searchNode:hCanset_p];
    NSDictionary *indexDic = [hSceneFo getConIndexDic:hCanset_p];
    NSInteger hSceneTargetIndex = hSceneCutIndex + 1;//H任务的目标其实就是下一帧;
    NSInteger hCansetTargetIndex = NUMTOOK([indexDic objectForKey:@(hSceneTargetIndex)]).integerValue;
    NSInteger hCansetCutIndex = [TOUtils goBackToFindConIndexByAbsIndex:indexDic absIndex:hSceneCutIndex];
    
    //2. 转为TOFoModel;
    TOFoModel *result = [TOFoModel newForHCansetFo:hCanset_p sceneFo:hSceneFo.p base:hDemand
                       cansetCutIndex:hCansetCutIndex sceneCutIndex:hSceneCutIndex
                    cansetTargetIndex:hCansetTargetIndex sceneTargetIndex:hSceneCutIndex + 1
               basePFoOrTargetFoModel:targetFoModel baseSceneModel:rSceneModel];
    
    //3. 伪迁移;
    //TODOTOMORROW20240221: 明日继续看下hTransfer方法要重写下;
    //5. 从当前取到hCanset的rScene向当前正在推进中的rCanset下面迁移 (参考31112&31113);
    //a. 迁移源RScene一支有: 从RScene -> RCanset -> HCanset三重indexDic;
    AIKVPointer *rSceneFrom = rSceneModel.scene;
    AIFoNodeBase *hSceneFrom = hSceneFo;
    AIFoNodeBase *hCansetFrom = [SMGUtils searchNode:hCanset_p];
    
    //b. 迁移目标RScene一支也有: 从RScene -> RCanset -> HCanset三重indexDic;
    AIKVPointer *rSceneTo = targetFoModel.i.scene;
    AIKVPointer *hSceceTo = targetFoModel.i.canset;
    
    //c. 迁移源和迁移目标之间,有场景树关系;
    AISceneModel *sceneTreeFrom = rSceneModel;
    AISceneModel *sceneTreeTo = targetFoModel.baseSceneModel;
    
    if (sceneTreeTo.type == SceneTypeI) {
        
    }else if(sceneTreeTo.type == SceneTypeFather) {
        
        
    }else if(sceneTreeTo.type == SceneTypeBrother) {
        
    }
    
    
    //4. 下帧初始化 (可接受反馈);
    [result pushNextFrame];
    return result;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------获取override用来过滤的部分 (参考29069-todo5.2)--------------------
 *  @desc 取father过滤部分 (用于mIsC过滤) (参考29069-todo5.1);
 *  @version
 *      2023.04.23: BUG_修复抽具象关联取不到过滤结果,改为用迁移关联取 (参考29074);
 */
+(NSArray*) getFilter_ps:(AISceneModel*)sceneModel {
    //1. brother时: 取father及其具象 => 作为过滤部分 (参考29069-todo5.3-公式减数);
    if (sceneModel.type == SceneTypeBrother) {
        //2. 从fatherScene中找出与当前scene有迁移关联的cansets并返回 (参考29069-todo5.3 & 29074);
        AIFoNodeBase *fatherFo = [SMGUtils searchNode:sceneModel.base.scene];
        return [fatherFo getTransferConCansets:sceneModel.scene];
    }
    //3. father时: 取i及其抽象 => 作为过滤部分 (参考29069-todo5.4-公式减数);
    else if (sceneModel.type == SceneTypeFather) {
        //4. 从iScene中找出与当前scene有迁移关联的cansets并返回 (参考29069-todo5.4 & 29074);
        AIFoNodeBase *iFo = [SMGUtils searchNode:sceneModel.base.scene];
        return [iFo getTransferAbsCansets:sceneModel.scene];
    }
    return nil;
}

/**
 *  MARK:--------------------递归找出pFo (参考28025-todo8)--------------------
 *  @desc 适用范围: 即可用于R任务,也可用于H任务;
 *  @desc 执行说明: H任务会自动递归,直到找到R为止   /   R任务不会递归,直接返回R的pFo;
 */
+(AIMatchFoModel*) getPFo:(AIKVPointer*)cansetFo_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel {
    //1. 本次非R时: 继续递归;
    if (ISOK(basePFoOrTargetFoModel, TOFoModel.class)) {
        TOFoModel *baseTargetFo = (TOFoModel*)basePFoOrTargetFoModel;
        return [self getPFo:baseTargetFo.content_p basePFoOrTargetFoModel:baseTargetFo.basePFoOrTargetFoModel];
    }
    //2. 本次是R时: 返回最终找到的pFo;
    else {
        return basePFoOrTargetFoModel;
    }
}

/**
 *  MARK:--------------------条件满足时: 获取前段indexDic--------------------
 *  @desc 即从proto中找abs: 判断当前proto场景对abs是条件满足的 (参考28052-2);
 *  @param cansetCutIndex : 其中cansetFo执行到的最大值 (含cansetCutIndex) (是ptAleardayCount-1对应的canset下标);
 *  @version
 *      2023.02.04: 初版,为解决条件满足不完全的问题,此方法将尝试从proto找出canset前段的每帧 (参考28052);
 *      2023.04.28: 条件满足兼容迁移alg的情况 (参考29075-方案3);
 *  @result 在proto中全找到canset的前段则返回frontIndexDic映射模型,未全找到时(条件不满足)返回空数组;
 */
+(NSArray*) getFrontIndexDic:(AIFoNodeBase*)protoFo cansetFo:(AIFoNodeBase*)cansetFo cansetCutIndex:(NSInteger)cansetCutIndex sceneModel:(AISceneModel*)sceneModel {
    //1. 数据准备;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!protoFo || !cansetFo) return nil;
    
    //2. 每帧match都到proto里去找,找到则记录proto的进度,找不到则全部失败;
    NSInteger protoMin = 0;
    
    //2. 说明: 所有已发生帧,都要判断一下条件满足 (cansetCutIndex之前全是前段) (参考28022-todo4);
    for (NSInteger cansetI = 0; cansetI < cansetCutIndex + 1; cansetI ++) {
        AIKVPointer *cansetAlg = ARR_INDEX(cansetFo.content_ps, cansetI);
        BOOL findItem = false;
        for (NSInteger protoI = protoMin; protoI < protoFo.count; protoI++) {
            AIKVPointer *protoAlg = ARR_INDEX(protoFo.content_ps, protoI);
            //3. B源于cansetFo,此处只判断B是1层抽象 (参考27161-调试1&调试2);
            //3. 单条判断方式: 此处proto抽象仅指向刚识别的matchAlgs,所以与contains等效 (参考28052-3);
            AIKVPointer *transferAlg = [TCTransfer transferAlg:sceneModel canset:cansetFo cansetIndex:cansetI];
            BOOL mIsC = [TOUtils mIsC_1:protoAlg c:transferAlg];
            if (mIsC) {
                //4. 找到了 & 记录protoI的进度;
                findItem = true;
                protoMin = protoI + 1;
                [result addObject:[FrontIndexDicModel newWithProtoIndex:protoI cansetIndex:cansetI transferAlg:transferAlg]];
                if (Log4SceneIsOk) NSLog(@"\t第%ld帧,条件满足通过 canset:%@ (fromProto:F%ldA%ld)",cansetI,Pit2FStr(cansetAlg),protoFo.pointer.pointerId,protoAlg.pointerId);
                break;
            }
        }
        
        //5. 有一条失败,则全失败;
        if (!findItem) {
            if (Log4SceneIsOk) NSLog(@"\t第%ld帧,条件满足未通过 canset:%@ (fromProtoFo:F%ld)",cansetI,Pit2FStr(cansetAlg),protoFo.pointer.pointerId);
            return nil;
        }
    }
    
    //6. 全找到,则成功;
    if (Log4SceneIsOk) NSLog(@"\t前段条件满足通过:%@ (cansetCutIndex:%ld fromProtoFo:%ld)",Fo2FStr(cansetFo),cansetCutIndex,protoFo.pointer.pointerId);
    return result;
}

@end
