//
//  TCSolutionUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/5.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TCSolutionUtil.h"

@implementation TCSolutionUtil


//MARK:===============================================================
//MARK:                     < 快思考 >
//MARK:===============================================================

/**
 *  MARK:--------------------R快思考--------------------
 *  @desc 习惯 (参考26142);
 */
+(AISolutionModel*) rSolution_Fast:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps{
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    
    //2. 收集所有解决方案候选集;
    NSArray *cansets = [SMGUtils convertArr:demand.pFos convertItemArrBlock:^NSArray *(AIMatchFoModel *obj) {
        AIFoNodeBase *pFo = [SMGUtils searchNode:obj.matchFo];
        NSArray *itemCansets = [pFo.effectDic objectForKey:@(pFo.count)];
        if (Log4Solution_Fast && ARRISOK(itemCansets)) NSLog(@"\tF%ld的第%ld帧取: %@",pFo.pointer.pointerId,pFo.count,CLEANSTR(itemCansets));
        return itemCansets;
    }];
    
    //3. 快思考算法;
    return [TCSolutionUtil generalSolution_Fast:demand cansets:cansets except_ps:except_ps solutionModelBlock:^AISolutionModel *(AIEffectStrong *canset) {
        return [TOUtils compareRCansetFo:canset.solutionFo protoFo:demand.protoFo];
    }];
}

/**
 *  MARK:--------------------H快思考--------------------
 *  @desc 习惯 (参考26142);
 */
+(AISolutionModel*) hSolution_Fast:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps{
    //1. 数据准备;
    TOFoModel *targetFoM = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoM.content_p];
    
    //2. 从targetFo取解决方案候选集;
    NSArray *cansets = [targetFo.effectDic objectForKey:@(targetFoM.actionIndex)];
    
    //3. 快思考算法;
    return [TCSolutionUtil generalSolution_Fast:hDemand cansets:cansets except_ps:except_ps solutionModelBlock:^AISolutionModel *(AIEffectStrong *canset) {
        return [TOUtils compareHCansetFo:canset.solutionFo targetFo:targetFoM];
    }];
}

/**
 *  MARK:--------------------快思考--------------------
 *  @desc 习惯 (参考26142);
 *  @version
 *      2022.06.03: 将cansets中hnStrong合并,一直这么设计的,今发现写没实现,补上;
 *      2022.06.03: 排除掉候选方案不适用当前场景的 (参考26192);
 *      2022.06.05: 支持三个阈值 (参考26199);
 *      2022.06.05: 将R快思考和H快思考整理成通用快思考算法;
 */
+(AISolutionModel*) generalSolution_Fast:(DemandModel *)demand cansets:(NSArray*)cansets except_ps:(NSArray*)except_ps solutionModelBlock:(AISolutionModel*(^)(AIEffectStrong *canset))solutionModelBlock{
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    NSLog(@"1. 快思考protoCansets数:%ld",cansets.count);

    //2. 将同cansetFo的effStrong累计;
    cansets = [TOUtils mergeCansets:cansets];
    NSLog(@"2. 按HNStrong合并后:%ld %@",cansets.count,CLEANSTR(cansets));

    //3. cansets过滤器;
    cansets = [SMGUtils filterArr:cansets checkValid:^BOOL(AIEffectStrong *item) {
        //1. hStrong阈值 (参考26199-TODO2);
        if (item.hStrong < 5) return false;

        //2. 排除不应期;
        if ([except_ps containsObject:item.solutionFo]) return false;

        //3. 闯关成功;
        return true;
    }];
    NSLog(@"3. HStrong>5和不应期过滤后:%ld",cansets.count);

    //4. 转solutionModel & 排除掉候选方案不适用当前场景(为nil)的 (参考26192);;
    NSArray *solutionModels = [SMGUtils convertArr:cansets convertBlock:^id(AIEffectStrong *obj) {
        AISolutionModel *sModel = solutionModelBlock(obj);
        if (sModel) sModel.effectScore = [TOUtils getEffectScore:obj];
        return sModel;
    }];
    NSLog(@"4. 时序对比有效后:%ld",solutionModels.count);

    //5. solutionModels过滤器;
    solutionModels = [SMGUtils filterArr:solutionModels checkValid:^BOOL(AISolutionModel *item) {
        //1. 时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
        if (![AIScore FRS_Time:demand solutionModel:item]) return false;

        //2. 后段-目标匹配 (阈值>80%) (参考26199-TODO1);
        if (item.backMatchValue < 0.8f) return false;

        //3. 中段-按有效率 (effectScore>0) (参考26199-TODO2);
        if (item.effectScore <= 0) return false;

        //4. 前段-场景匹配 (阈值>80%) (参考26199-TODO3);
        if (item.frontMatchValue < 0.8) return false;

        //5. 闯关成功;
        return true;
    }];
    NSLog(@"5. (FRSTime & 后段阈值 & 中段阈值 & 前段阈值)过滤后:%ld",solutionModels.count);

    //6. 对候选集按有效率排序;
    NSArray *sortSolutionModels = [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return obj.effectScore;
    }];
    NSLog(@"6. 有效率排序后:%ld",sortSolutionModels.count);
    if (Log4Solution_Fast) for (AISolutionModel *m in sortSolutionModels) {
        AIEffectStrong *c = [SMGUtils filterSingleFromArr:cansets checkValid:^BOOL(AIEffectStrong *item) {
            return [item.solutionFo isEqual:m.cansetFo];
        }];
        NSLog(@"\tH%ldN%ld %@",c.hStrong,c.nStrong,Pit2FStr(m.cansetFo));
    }

    //7. 将首条最佳方案返回;
    AISolutionModel *result = ARR_INDEX(sortSolutionModels, 0);
    if (Log4Solution && result) NSLog(@"7. 快思考最佳结果:F%ld 有效率:%.2f",result.cansetFo.pointerId,result.effectScore);
    return result;
}

@end
