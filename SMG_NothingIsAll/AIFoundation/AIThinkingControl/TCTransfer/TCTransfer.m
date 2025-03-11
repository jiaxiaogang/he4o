//
//  TCTransfer.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "TCTransfer.h"

@implementation TCTransfer

//MARK:===============================================================
//MARK:                     < 经验迁移-虚V3 >
//MARK:===============================================================

/**
 *  MARK:--------------------迁移之用 (仅得出模型) (参考31073-TODO1)--------------------
 *  @desc 为了方便Cansets实现实时竞争 (每次反馈时,可以根据伪迁移来判断反馈成立);
 *      2024.01.19: 初版-为每个CansetModel生成且只生成jiCenModel和tuiJuModel (参考31073-TODO1);
 *  @desc 说明：在共同的rSceneFrom下，把rCansetFrom下的hCansetFrom迁移到rCansetTo下。
 */
//此方法为简化H嵌套后，继承H的迁移算法，用于hSolutionV5。
+(TCTransferXvModel*) transferJiCen_RH_V3:(AIKVPointer*)cansetFrom_p fScene:(AIFoNodeBase*)fScene iScene:(AIFoNodeBase*)iScene sceneToActIndex:(NSInteger)sceneToActIndex {
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetFrom_p];
    
    //3. IH映射: indexDic综合计算 (参考31115-TODO1-4);
    //2025.02.24: 迁移路径都是：hCansetFrom（I/F） -> rCansetFrom（I/F） -> rSceneFrom（I/F） -> rSceneTo（I） -> targetFo（I） -> hCansetTo（I）（参考33159-TODO3A）。
    NSMutableArray *path = [NSMutableArray new];
    [path addObject:[DirectIndexDic newOkToAbs:[fScene getConIndexDic:cansetFrom.p]]];
    if (![fScene isEqual:iScene]) {//当hSceneFrom和To不同时，才从上面走（参考33159-TODO3B&TODO3C）。
        //一般是继承，所以from肯定是F层，而to肯定是I层。
        [path addObject:[DirectIndexDic newNoToAbs:[fScene getConIndexDic:iScene.p]]];
    }
    NSDictionary *zonHeIndexDic = [SMGUtils reverseDic:[TOUtils zonHeIndexDic:path]];
    
    //6. 计算cansetToOrders
    //说明: 场景包含帧用indexDic映射来迁移替换,场景不包含帧用迁移前的为准 (参考31104);
    //2025.02.24: H继承时，取order方式与以往一致（参考3315b）。
    NSMutableArray *iCansetToOrders = [TCTransfer convertZonHeIndexDic2Orders:cansetFrom.convert2Orders sceneTo:iScene zonHeIndexDic:zonHeIndexDic];
    
    //9. 打包数据model返回 (映射需要返过来因为前面cansetFrom在前,现在是cansetTo在后);
    TCTransferXvModel *result = [[TCTransferXvModel alloc] init];
    result.cansetToOrders = iCansetToOrders;
    result.sceneToCansetToIndexDic = [SMGUtils reverseDic:zonHeIndexDic];
    result.sceneToTargetIndex = sceneToActIndex;
    
    //10. 继承时，进行迁移关联（可用于父非子评分时使用）（参考33171-TODO4）。
    if (![iScene isEqual:fScene]) {
        [AINetUtils relateTransfer_R:fScene fCanset:cansetFrom iScene:iScene iCanset:Simples2Pits(iCansetToOrders)];
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < 概念迁移算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------cansetAlg迁移算法 (29075-方案3)--------------------
 *  _param 参数说明 : canset的cansetIndex帧,延着sceneModel向base最终找着transferIAlg返回;
 *  @desc 用于将brother或father的canset转成iAlg返回;
 *  @desc 代码说明: 此算法逐步用indexDic映射来判断,全成功则最终返回iAlg,中途失败则返回中断时的resultAlg;
 */
+(AIKVPointer*) transferAlg:(AISceneModel*)sceneModel canset:(AIFoNodeBase*)canset cansetIndex:(NSInteger)cansetIndex {
    //1. 数据准备;
    if (!sceneModel) return ARR_INDEX(canset.content_ps, cansetIndex);
    AIKVPointer *curScene_p = sceneModel.scene;//当前scene
    AIKVPointer *stopResult = nil;//中途中断时,把结果out过来return下;
    
    //2. canset到当前scene映射检查 (不通过则直接返回cansetAlg);
    NSNumber *curSceneIndex = [self transferAlg4GetAbsIndex:canset.pointer absFo:curScene_p conIndex:cansetIndex stopResult:&stopResult];
    if (!curSceneIndex) return stopResult;
    
    //3. ===================== brother时 (参考29075-todo2) =====================
    if (sceneModel.type == SceneTypeBrother) {
        //a. 数据准备;
        AIKVPointer *father_p = sceneModel.base.scene;
        AIKVPointer *i_p = sceneModel.base.base.scene;
        
        //b. brother到father映射检查 (不通过则直接返回brotherAlg);
        NSNumber *fatherIndex = [self transferAlg4GetAbsIndex:curScene_p absFo:father_p conIndex:curSceneIndex.integerValue stopResult:&stopResult];
        if (!fatherIndex) return stopResult;
        
        //c. father到i映射检查 (不通过则直接返回stopResult);
        NSNumber *iIndex = [self transferAlg4GetConIndex:father_p conFo:i_p absIndex:fatherIndex.integerValue stopResult:&stopResult];
        if (!iIndex) return stopResult;
        
        //d. 全通过,返回iAlg
        AIFoNodeBase *i = [SMGUtils searchNode:i_p];
        return ARR_INDEX(i.content_ps, iIndex.integerValue);
    }
    //4. ===================== father时 (参考29075-todo3) =====================
    else if (sceneModel.type == SceneTypeFather) {
        //a. 数据准备;
        AIKVPointer *i_p = sceneModel.base.scene;
        
        //b. father到i映射检查 (不通过则直接返回fatherAlg);
        NSNumber *iIndex = [self transferAlg4GetConIndex:curScene_p conFo:i_p absIndex:curSceneIndex.integerValue stopResult:&stopResult];
        if (!iIndex) return stopResult;
        
        //c. 全通过,返回iAlg
        AIFoNodeBase *i = [SMGUtils searchNode:i_p];
        return ARR_INDEX(i.content_ps, iIndex.integerValue);
    }
    //5. ===================== i时 =====================
    else if (sceneModel.type == SceneTypeI) {
        AIFoNodeBase *i = [SMGUtils searchNode:curScene_p];
        return ARR_INDEX(i.content_ps, curSceneIndex.integerValue);
    }
    return ARR_INDEX(canset.content_ps, cansetIndex);
}

/**
 *  MARK:--------------------absIndex 2 conIndex (参考29075-todo1)--------------------
 *  @desc 从上到下找映射并返回 (将迁移前的algResult也out出去);
 */
+(NSNumber*) transferAlg4GetConIndex:(AIKVPointer*)absFo_p conFo:(AIKVPointer*)conFo_p absIndex:(NSInteger)absIndex stopResult:(AIKVPointer**)stopResult{
    AIFoNodeBase *absFo = [SMGUtils searchNode:absFo_p];
    NSDictionary *indexDic = [absFo getConIndexDic:conFo_p];
    *stopResult = ARR_INDEX(absFo.content_ps, absIndex);
    return [indexDic objectForKey:@(absIndex)];
}

/**
 *  MARK:--------------------conIndex 2 absIndex (参考29075-todo1)--------------------
 *  @desc 从下到上找映射并返回 (将迁移前的algResult也out出去);
 */
+(NSNumber*) transferAlg4GetAbsIndex:(AIKVPointer*)conFo_p absFo:(AIKVPointer*)absFo_p conIndex:(NSInteger)conIndex stopResult:(AIKVPointer**)stopResult{
    AIFoNodeBase *conFo = [SMGUtils searchNode:conFo_p];
    NSDictionary *indexDic = [conFo getAbsIndexDic:absFo_p];
    *stopResult = ARR_INDEX(conFo.content_ps, conIndex);
    return ARR_INDEX([indexDic allKeysForObject:@(conIndex)], 0);
}

/**
 *  MARK:--------------------计算cansetTo.orders--------------------
 *  @desc 根据综合indexDic把cansetFrom迁移到sceneTo的cansetTo的orders计算出来 (说白了: 有综合映射的帧从cansetFrom取,没有映射的帧从sceneTo取);
 *  @param zonHeIndexDic : <K=cansetFrom下标，V=sceneTo下标>
 */
+(NSMutableArray*) convertZonHeIndexDic2Orders:(NSArray*)cansetFromOrders sceneTo:(AIFoNodeBase*)sceneTo zonHeIndexDic:(NSDictionary*)zonHeIndexDic {
    //6. 计算cansetToOrders
    //说明: 场景包含帧用indexDic映射来迁移替换,场景不包含帧用迁移前的为准 (参考31104);
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < cansetFromOrders.count; i++) {
        //a. 判断映射链: (参考29069-todo10.1-步骤2 & 31113-TODO8);
        NSNumber *sceneToIndex = [zonHeIndexDic objectForKey:@(i)];
        AIShortMatchModel_Simple *cansetFromOrder = ARR_INDEX(cansetFromOrders, i);
        if (sceneToIndex) {
            //b. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(sceneTo.content_ps, sceneToIndex.intValue) inputTime:cansetFromOrder.inputTime isTimestamp:false];
            [orders addObject:order];
        } else {
            //c. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:cansetFromOrder.alg_p inputTime:cansetFromOrder.inputTime isTimestamp:false];
            [orders addObject:order];
        }
    }
    return orders;
}

//MARK:===============================================================
//MARK:                     < 推举算法V3 >
//MARK:===============================================================

/**
 *  MARK:--------------------在构建HCanset / RCanset时,推举到抽象场景中 (参考33112)--------------------
 *  @param sceneFromCutIndex 即broCanset正在行为化的帧 (它是新构建的hCanset的场景);
 *  @param initOutSPDic 表示调用此方法的canset的初始OutSPDic，比如NewRHCanset时一般是每index都是P=1，再比如AbsRHCanset时为当前激活推进中的fCanset对baseSceneToOrders的现有SP记录。
 *  @param baseSceneContent_ps 生成新canset所在的baseSceneOrders（用于推举后，为其初始化OutSP值）。
 *  @version
 *      2025.01.16: 迭代V2，H推举延着R的迁移关联进行（参考33152）。
 *      2025.03.02: 简化H嵌套后，R和H都是挂在rScene下，所以复用此推举算法（参考33171-TODO2）。
 */
+(void) transferTuiJv_RH_V3:(AIFoNodeBase*)sceneFrom cansetFrom:(AIFoNodeBase*)cansetFrom isH:(BOOL)isH sceneFromCutIndex:(NSInteger)sceneFromCutIndex initOutSPDic:(NSDictionary*)initOutSPDic baseSceneContent_ps:(NSArray*)baseSceneContent_ps {
    //1. 将rCanset推举到每一个absFo;
    NSArray *absPorts = [AINetUtils absPorts_All:sceneFrom];
    
    //2. 已推举过的记录（用于防重）。
    NSArray *alreadayTuiJuFScenes = [SMGUtils convertArr:[AINetUtils transferPorts_4Father:sceneFrom iCansetContent_ps:cansetFrom.content_ps] convertBlock:^id(AITransferPort *obj) {
        return obj.fScene;
    }];
    for (AIPort *absPort in absPorts) {
        //11. 判断是否推举过此absPort，如果推过，则不重复推举。
        if ([alreadayTuiJuFScenes containsObject:absPort.target_p]) continue;
        
        //12. mv要求必须同区 (不然rCanset对sceneTo无效);
        AIFoNodeBase *sceneTo = [SMGUtils searchNode:absPort.target_p];
        if (!isH && ![sceneFrom.cmvNode_p.identifier isEqualToString:sceneTo.cmvNode_p.identifier]) continue;
        
        //3. BR映射 (参考29069-todo10.1推举算法示图);
        NSDictionary *zonHeIndexDic = [self getBFZonHeIndexDic:cansetFrom broScene:sceneFrom fatScene:sceneTo];
        NSDictionary *sceneToCansetToIndexDic = [SMGUtils reverseDic:zonHeIndexDic];
        
        //4. 取sceneToTargetIndex;
        NSDictionary *sceneFromSceneToIndexDic = [sceneFrom getAbsIndexDic:sceneTo.p];
        NSInteger sceneToTargetIndex = sceneTo.count;
        if (isH) sceneToTargetIndex = [TOUtils goBackToFindConIndexByConIndex:sceneFromSceneToIndexDic conIndex:sceneFromCutIndex] + 1;
        
        //4. 根据综合映射,计算出orders;
        NSArray *orders = [self convertZonHeIndexDic2Orders:cansetFrom.convert2Orders sceneTo:sceneTo zonHeIndexDic:zonHeIndexDic];
        NSArray *cansetToContent_ps = Simples2Pits(orders);
        
        //11. 构建cansetTo
        AIFoNodeBase *cansetTo = [theNet createConFoForCanset:orders sceneFo:sceneTo sceneTargetIndex:sceneToTargetIndex];
        
        //5. 加SP计数: 新推举的cansetFrom的spDic都计入cansetTo中 (参考33031b-BUG5-TODO1);
        //2024.11.01: 防重说明: 此方法调用了,说明cansetFrom是新挂载到sceneFrom下的,此时可调用一次推举到absPorts中,并把所有spDic都推举到absPorts上去;
        //21. outSP值子即父: 当前NewRCanset所在的matchFo场景就是iScene (参考33112-TODO4.3);
        //2024.11.26: 从0到cutIndex全计P+1 (参考33134-FIX2a);
        NSMutableDictionary *deltaSPDic = [cansetTo.outSPDic objectForKey:[AINetUtils getOutSPKey:sceneFrom.content_ps]];
        for (NSNumber *cansetFromIndex in deltaSPDic.allKeys) {
            AISPStrong *deltaSPStrong = [deltaSPDic objectForKey:cansetFromIndex];
            NSInteger cansetToIndex = cansetFromIndex.integerValue;//cansetFrom和cansetTo一样长,并且下标都是一一对应的;
            [cansetTo updateOutSPStrong:cansetToIndex difStrong:deltaSPStrong.pStrong type:ATPlus baseSceneToContent_ps:sceneTo.content_ps debugMode:false caller:STRFORMAT(@"TuiJv%@时F层P初始化",isH?@"H":@"R")];
            [cansetTo updateOutSPStrong:cansetToIndex difStrong:deltaSPStrong.sStrong type:ATSub baseSceneToContent_ps:sceneTo.content_ps debugMode:false caller:STRFORMAT(@"TuiJv%@时F层S初始化",isH?@"H":@"R")];
            [cansetTo updateOutSPStrong:cansetToIndex difStrong:deltaSPStrong.pStrong type:ATPlus baseSceneToContent_ps:baseSceneContent_ps debugMode:false caller:STRFORMAT(@"TuiJv%@时I层P初始化",isH?@"H":@"R")];
            [cansetTo updateOutSPStrong:cansetToIndex difStrong:deltaSPStrong.sStrong type:ATSub baseSceneToContent_ps:baseSceneContent_ps debugMode:false caller:STRFORMAT(@"TuiJv%@时I层S初始化",isH?@"H":@"R")];
        }
        
        //12. 挂载cansetTo
        HEResult *updateConCansetResult = [sceneTo updateConCanset:cansetTo.pointer targetIndex:sceneToTargetIndex];
        if (!updateConCansetResult.success) continue;//挂载成功,才加映射;
        
        //13. 加映射 (映射需要返过来因为前面cansetFrom在前,现在是cansetTo在后) (参考27201-3);
        [cansetTo updateIndexDic:sceneTo indexDic:sceneToCansetToIndexDic];
        
        //14. 挂载成功: 进行迁移关联 (可供复用,避免每一次推举更新sp时,都重新推举) (参考33112-TODO3);
        //2024.11.13: 新版迁移关联: 推举时=>from是I层,to是F层 (条件: 未发生迁移时,不执行) (参考33112-TODO4.4);
        [AINetUtils relateTransfer_R:sceneTo fCanset:cansetTo iScene:sceneFrom iCanset:cansetFrom.content_ps];
    }
}

/**
 *  MARK:--------------------取brotherCanset推举到fatherScene后的综合映射--------------------
 *  @desc BR映射 (参考29069-todo10.1推举算法示图);
 */
+(NSDictionary*) getBFZonHeIndexDic:(AIFoNodeBase*)broCanset broScene:(AIFoNodeBase*)broScene fatScene:(AIFoNodeBase*)fatScene {
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[broCanset getAbsIndexDic:broScene.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[broScene getAbsIndexDic:fatScene.p]];
    return [TOUtils zonHeIndexDic:@[dic1,dic2]];
}

@end
