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
 *  MARK:--------------------将canset_p转成cansetModel--------------------
 *  @desc 初步比对候选集是否适用于protoFo (参考26128-第1步);
 *  @param ptAleardayCount      : ptFo已发生个数: 即取得"canset的basePFoOrTargetFo推进到哪了"的截点 (aleardayCount = cutIndex+1 或 actionIndex);
 *                                  1. 根R=cutIndex+1
 *                                  2. 子R=父actionIndex对应indexDic条数;
 *                                  3. H.actionIndex前已发生;
 *                                  改: 在支持sceneTree后,统一传sceneModel.cutIndex + 1;
 *  @param sceneFrom_p            : 当前cansetFo_p挂在哪个场景fo下就传哪个;
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
 *      2024.05.07: 前中后段,直接改为由indexDic来判断,而不是重计算现判断,性能天差地别 (参考31175-TODO1);
 *  @result 返回cansetFo前段匹配度 & 以及已匹配的cutIndex截点;
 */
+(TOFoModel*) convert2RCansetModel:(AIKVPointer*)cansetFrom_p sceneFrom:(AIKVPointer*)sceneFrom_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel sceneModel:(AISceneModel*)sceneModel demand:(DemandModel*)demand {
    //1. 数据准备 & 复用indexDic & 取出pFoOrTargetFo;
    [AITest test102:cansetFrom_p];
    AIFoNodeBase *sceneFrom = [SMGUtils searchNode:sceneFrom_p];
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetFrom_p];
    NSInteger sceneFromTargetIndex = sceneFrom.count;
    NSInteger sceneCutIndex = sceneModel.cutIndex;
    
    //2. 根据sceneFo取得与canset的indexDic映射;
    NSDictionary *cansetFromSceneFromIndexDic = [sceneFrom getConIndexDic:cansetFrom_p];
    
    //3. 计算出canset的cutIndex做为中段截点 (canset的cutIndex,也已在proto中发生) (参考26128-1-1);
    NSInteger cansetCutIndex = [TOUtils goBackToFindConIndexByAbsIndex:cansetFromSceneFromIndexDic absIndex:sceneCutIndex];
    
    //5. 过滤器:
    //过滤1: 过滤掉长度不够的 (因为前段全含至少要1位,中段修正也至少要0位,后段H目标要1位R要0位);
    //if (cansetFo.count < 1) return nil;
    
    //过滤2: 惰性期过滤器 (阈值为2: EFF默认值为1,达到阈值时触发) (参考28182-todo9 & 28185-todo6);
    //AIEffectStrong *effStrong = [TOUtils getEffectStrong:sceneFrom effectIndex:sceneFrom.count solutionFo:cansetFrom_p];
    //if (effStrong.hStrong <= 2) return nil;
    
    //过滤3: 判断canset前段是否有遗漏 (参考27224);
    //if (cansetCutIndex < sceneModel.cutIndex) return nil;
    
    //过滤4: 过滤掉canset没后段的 (没可行为化的东西) (参考28052-4);
    //if (cansetFo.count <= cansetCutIndex + 1) return nil;
    
    //6. 生成result (其中cansetTargetIndex: R时全推进完);
    TOFoModel *result = [TOFoModel newForRCansetFo:cansetFrom_p sceneFrom:sceneFrom_p base:demand basePFoOrTargetFoModel:basePFoOrTargetFoModel baseSceneModel:sceneModel
                                    sceneCutIndex:sceneCutIndex cansetCutIndex:cansetCutIndex
                                 cansetTargetIndex:cansetFrom.count sceneFromTargetIndex:sceneFromTargetIndex];
    
    //7. 初始化outSPDic (参考32012-TODO3);
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:result.sceneTo];
    [sceneTo initItemOutSPDicIfNotInited:cansetFrom.spDic sceneFrom:sceneFrom_p cansetFrom:cansetFrom_p];
    
    //12. 伪迁移;
    [TCTransfer transferXv:result];
    
    //13. 初始化result的cansetTo与real的映射;
    [result initRealCansetToDic];
    
    //13. 下帧初始化 (可接受反馈);
    [result pushNextFrame];
    return result;
}

/**
 *  MARK:--------------------HSolution转CansetModel--------------------
 *  @desc 把rCanset下的hCanset_p转成CansetModel;
 *  @version
 *      2024.02.21: V2-在迭代hSolutionV3时,将H任务转cansetModel单独写个方法,并将此方法中多余代码统统去掉不写;
 */
+(TOFoModel*) convert2HCansetModel:(AIKVPointer*)hCansetFrom_p hDemand:(HDemandModel*)hDemand rCanset:(TOFoModel*)rCanset {
    //1. 根据hScene和hCanset的映射,取出hCanset的目标帧等数据;
    TOFoModel *targetFoModel = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;//targetFo就是当前h任务的base(targetAlg).base(targetFo);
    NSInteger hSceneCutIndex = rCanset.cansetCutIndex;//hScene的推进进度;
    AISceneModel *rSceneModel = rCanset.baseSceneModel;//复用R的SceneModel,因为H任务没有独立的R场景树,它本来就是复用的R任务的场景树等;
    AIFoNodeBase *sceneFrom = [SMGUtils searchNode:rCanset.cansetFo];
    NSDictionary *indexDic = [sceneFrom getConIndexDic:hCansetFrom_p];
    NSInteger hSceneTargetIndex = hSceneCutIndex + 1;//H任务的目标其实就是下一帧;
    NSInteger hCansetTargetIndex = NUMTOOK([indexDic objectForKey:@(hSceneTargetIndex)]).integerValue;
    NSInteger hCansetCutIndex = [TOUtils goBackToFindConIndexByAbsIndex:indexDic absIndex:hSceneCutIndex];
    
    AIFoNodeBase *hCansetFrom = [SMGUtils searchNode:hCansetFrom_p];
    if (hCansetTargetIndex >= hCansetFrom.count) {
        NSLog(@"2024.06.02: 此处测得BUG,因cansetTargetIndex=4而cansetToOrder一共才4条,导致越界");
        //TODOTOMORROW20240602: 此处打上断点,如果下回再发现,或者有了复现方法,到时候查下原因;
    }
    
    //2. 转为TOFoModel;
    TOFoModel *result = [TOFoModel newForHCansetFo:hCansetFrom_p sceneFo:sceneFrom.p base:hDemand
                       cansetCutIndex:hCansetCutIndex sceneCutIndex:hSceneCutIndex
                    cansetTargetIndex:hCansetTargetIndex sceneTargetIndex:hSceneCutIndex + 1
               basePFoOrTargetFoModel:targetFoModel baseSceneModel:rSceneModel];
    
    //3. 伪迁移;
    [TCTransfer transferXv:result];
    
    //4. 初始化outSPDic (参考32012-TODO3);
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:result.sceneTo];
    [sceneTo initItemOutSPDicIfNotInited:hCansetFrom.spDic sceneFrom:sceneFrom.pointer cansetFrom:hCansetFrom_p];
    
    //4. 初始化result的cansetTo与real的映射;
    [result initRealCansetToDic];
    
    //4. 下帧初始化 (可接受反馈);
    [result pushNextFrame];
    return result;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

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
