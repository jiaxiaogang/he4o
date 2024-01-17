//
//  TCTransfer.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "TCTransfer.h"

@implementation TCTransfer

/**
 *  MARK:--------------------canset迁移算法 (29069-todo10)--------------------
 *  @desc 用于将canset从brother迁移到father再迁移到i场景下;
 *  @version
 *      2023.04.19: TCTranfer执行后,调用Canset识别类比 (参考29069-todo12);
 */
+(void) transfer:(AICansetModel*)bestCansetModel complate:(void(^)(AITransferModel *brother,AITransferModel *father,AITransferModel *i))complate {
    //0. 数据准备;
    [theTC updateOperCount:kFILENAME];
    Debug();
    OFTitleLog(@"TCTransfer迁移", @" from%@",SceneType2Str(bestCansetModel.baseSceneModel.type));
    AITransferModel *brotherResult = nil, *fatherResult = nil, *iResult = nil;
    NSInteger targetIndex = bestCansetModel.targetIndex; //因为推举和继承的canset全是等长,所以他们仨的targetIndex也一样;
    
    //1. 无base场景 或 type==I时 => 直接将cansetFo设为iCanset;
    if (!bestCansetModel || bestCansetModel.baseSceneModel.type == SceneTypeI) {
        AIKVPointer *iScene = bestCansetModel.sceneFo;
        AIKVPointer *iCanset = bestCansetModel.cansetFo;
        iResult = [AITransferModel newWithScene:iScene canset:iCanset];
    }
    
    //2. canset迁移之: father继承给i (参考29069-todo10.1);
    if (bestCansetModel.baseSceneModel.type == SceneTypeFather) {
        //a. 生成father结果;
        AIFoNodeBase *fatherScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.scene];
        AIFoNodeBase *fatherCanset = [SMGUtils searchNode:bestCansetModel.cansetFo];
        fatherResult = [AITransferModel newWithScene:fatherScene.p canset:fatherCanset.p];
        //b. 生成i结果;
        AIFoNodeBase *iScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.base.scene];
        AIFoNodeBase *iCanset = [self transferJiCen:fatherCanset fatherCansetTargetIndex:targetIndex fatherScene:fatherScene iScene:iScene];
        iResult = [AITransferModel newWithScene:iScene.p canset:iCanset.p];
        //c. 调用Canset识别类比 (参考29069-todo12);
        //[TIUtils recognitionCansetFo:iCanset sceneFo:iScene es:ES_Default];
    }
    
    //3. canset迁移之: brother推举到father,再继承给i (参考29069-todo10.1);
    if (bestCansetModel.baseSceneModel.type == SceneTypeBrother) {
        //a. 得出brother结果;
        AIFoNodeBase *brotherScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.scene];
        AIFoNodeBase *brotherCanset = [SMGUtils searchNode:bestCansetModel.cansetFo];
        brotherResult = [AITransferModel newWithScene:brotherScene.p canset:brotherCanset.p];
        
        //b. 得出father结果;
        AIFoNodeBase *fatherScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.base.scene];
        AIFoNodeBase *fatherCanset = [self transferTuiJu:brotherCanset brotherCansetTargetIndex:targetIndex brotherScene:brotherScene fatherScene:fatherScene];
        fatherResult = [AITransferModel newWithScene:fatherScene.p canset:fatherCanset.p];
        
        //c. 得出i结果
        AIFoNodeBase *iScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.base.base.scene];
        AIFoNodeBase *iCanset = [self transferJiCen:fatherCanset fatherCansetTargetIndex:targetIndex fatherScene:fatherScene iScene:iScene];
        iResult = [AITransferModel newWithScene:iScene.p canset:iCanset.p];
        
        //d. 调用Canset识别类比 (参考29069-todo12);
        //[TIUtils recognitionCansetFo:fatherCanset sceneFo:fatherScene es:ES_Default];
        //[TIUtils recognitionCansetFo:iCanset sceneFo:iScene es:ES_Default];
    }
    if (brotherResult) NSLog(@"迁移结果: brotherScene:F%ld Canset:%@",brotherResult.scene.pointerId,Pit2FStr(brotherResult.canset));
    if (fatherResult) NSLog(@"迁移结果: fatherScene:F%ld Canset:%@",fatherResult.scene.pointerId,Pit2FStr(fatherResult.canset));
    if (iResult) NSLog(@"迁移结果: iScene:F%ld Canset:%@",iResult.scene.pointerId,Pit2FStr(iResult.canset));
    DebugE();
    complate(brotherResult,fatherResult,iResult);
}

/**
 *  MARK:--------------------canset继承算法 (29069-todo10.1推举算法示图&步骤)--------------------
 *  @desc 用于将canset从father继承到i场景下;
 *  @param fatherCansetTargetIndex : 前后canset同长度,所以传前者targetIndex即可;
 *  @version
 *      2023.05.11: BUG_canset的targetIndex是执行目标,而scene的targetIndex是任务目标,用错修复 (参考29093-线索 & 方案);
 *      2023.12.09: 迁移出的新canset改为仅在场景内防重 (参考3101b-todo5);
 *      2024.01.17: 拆分成两步: 先用(用来取model),后体(用来构建iCanset节点和构建关联继承spDic);
 */
+(AIFoNodeBase*) transferJiCen:(AIFoNodeBase*)fatherCanset fatherCansetTargetIndex:(NSInteger)fatherCansetTargetIndex fatherScene:(AIFoNodeBase*)fatherScene iScene:(AIFoNodeBase*)iScene {
    TCJiCenModel *jiCenModel = [self transferJiCenForModel:fatherCanset fatherCansetTargetIndex:fatherCansetTargetIndex fatherScene:fatherScene iScene:iScene];
    AIFoNodeBase *iCanset = [self transferJiCenForCreate:jiCenModel iScene:iScene fatherScene:fatherScene fatherCanset:fatherCanset];
    return iCanset;
}

+(TCJiCenModel*) transferJiCenForModel:(AIFoNodeBase*)fatherCanset fatherCansetTargetIndex:(NSInteger)fatherCansetTargetIndex fatherScene:(AIFoNodeBase*)fatherScene iScene:(AIFoNodeBase*)iScene {
    //1. 数据准备;
    TCJiCenModel *result = [[TCJiCenModel alloc] init];
    
    //2. 取两级映射 (参考29069-todo10.1推举算法示图);
    NSDictionary *indexDic1 = [fatherScene getConIndexDic:fatherCanset.p];
    NSDictionary *indexDic2 = [fatherScene getConIndexDic:iScene.p];
    
    //3. 新生成fatherCanset (参考29069-todo10.1推举算法示图&步骤);
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    NSMutableDictionary *iSceneCansetIndexDic = [[NSMutableDictionary alloc] init];
    
    //========================= 算法关键代码 START =========================
    for (NSInteger i = 0; i < fatherCanset.content_ps.count; i++) {
        //4. 判断映射链: (参考29069-todo10.1-步骤2);
        NSNumber *fatherSceneIndex = ARR_INDEX([indexDic1 allKeysForObject:@(i)], 0);
        NSNumber *iSceneIndex = [indexDic2 objectForKey:fatherSceneIndex];
        double deltaTime = [NUMTOOK(ARR_INDEX(fatherCanset.deltaTimes, i)) doubleValue];
        if (iSceneIndex) {
            //5. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(iScene.content_ps, iSceneIndex.intValue) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
            
            //5. 只有最终迁移成功的帧,记录新的indexDic;
            [iSceneCansetIndexDic setObject:@(i) forKey:iSceneIndex];
        } else {
            //6. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(fatherCanset.content_ps, i) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        }
    }
    //========================= 算法关键代码 END =========================
    
    //7. 将canset执行目标转成scene任务目标targetIndex (参考29093-方案);
    NSInteger iSceneTargetIndex = iScene.count;
    if (fatherCansetTargetIndex < fatherCanset.count) {
        
        //8. iCanset和fatherCanset长度一致;
        NSInteger iCansetTargetIndex = fatherCansetTargetIndex;
        NSArray *keys = [iSceneCansetIndexDic allKeysForObject:@(iCansetTargetIndex)];
        if (ARRISOK(keys)) {
            iSceneTargetIndex = NUMTOOK(ARR_INDEX(keys, 0)).integerValue;
        }
    }
    
    //9. 打包数据model返回;
    result.iCansetOrders = orders;
    result.iSceneCansetIndexDic = iSceneCansetIndexDic;
    result.iSceneTargetIndex = iSceneTargetIndex;
    return result;
}

+(AIFoNodeBase*) transferJiCenForCreate:(TCJiCenModel*)jiCenModel iScene:(AIFoNodeBase*)iScene fatherScene:(AIFoNodeBase*)fatherScene fatherCanset:(AIFoNodeBase*)fatherCanset {
    //7. 构建result & 场景内防重;
    AIFoNodeBase *iCanset = [theNet createConFoForCanset:jiCenModel.iCansetOrders sceneFo:iScene sceneTargetIndex:jiCenModel.iSceneTargetIndex];
    
    //8. 新生成fatherPort;
    AITransferPort *newIPort = [AITransferPort newWithScene:iScene.p canset:iCanset.p];
    
    //9. 防重 (其实不可能重复,因为如果重复在override算法中当前cansetModel就已经被过滤了);
    if (![fatherScene.transferConPorts containsObject:newIPort]) {
        
        //10. 将newIPort挂到iScene下;
        BOOL updateCansetSuccess = [iScene updateConCanset:iCanset.p targetIndex:jiCenModel.iSceneTargetIndex];
        
        if (updateCansetSuccess) {
            //11. 为迁移后iCanset加上与iScene的indexDic (参考29075-todo4);
            [iCanset updateIndexDic:iScene indexDic:jiCenModel.iSceneCansetIndexDic];
            
            //11. SP值也继承 (参考3101b-todo1);
            if (fatherCanset.count == iCanset.count) {
                [iCanset updateSPDic:fatherCanset.spDic];
            }
            [AITest test32:fatherCanset newCanset:iCanset];
            
            //12. 并进行迁移关联
            [AINetUtils relateTransfer:fatherScene.p absCanset:fatherCanset.p conScene:iScene.p conCanset:iCanset.p];
        }
    }
    return iCanset;
}

/**
 *  MARK:--------------------canset推举算法 (29069-todo10.1推举算法示图&步骤)--------------------
 *  @desc 用于将canset从brother推举到father场景下;
 *  @version
 *      2023.05.04: 通过fo全局防重实现推举防重 (参考29081-todo32);
 *      2023.12.09: 迁移出的新canset改为仅在场景内防重 (参考3101b-todo5);
 *      2024.01.17: 拆分成两步: 先用(用来取model),后体(用来构建fatherCanset节点和构建关联继承spDic);
 *      2024.01.17: 补上推举算法中fatherSceneTargetIndex一直是错误的问题 (原来的值一直是fatherScene.count);
 */
+(AIFoNodeBase*) transferTuiJu:(AIFoNodeBase*)brotherCanset brotherCansetTargetIndex:(NSInteger)brotherCansetTargetIndex brotherScene:(AIFoNodeBase*)brotherScene fatherScene:(AIFoNodeBase*)fatherScene {
    TCTuiJuModel *tuiJuModel = [self transferTuiJuForModel:brotherCanset brotherCansetTargetIndex:brotherCansetTargetIndex brotherScene:brotherScene fatherScene:fatherScene];
    AIFoNodeBase *fatherCanset = [self transferTuiJuForCreate:tuiJuModel fatherScene:fatherScene brotherScene:brotherScene brotherCanset:brotherCanset];
    return fatherCanset;
}

+(TCTuiJuModel*) transferTuiJuForModel:(AIFoNodeBase*)brotherCanset brotherCansetTargetIndex:(NSInteger)brotherCansetTargetIndex brotherScene:(AIFoNodeBase*)brotherScene fatherScene:(AIFoNodeBase*)fatherScene {
    //1. 数据准备;
    AIFoNodeBase *fatherCanset = nil;
    TCTuiJuModel *result = [[TCTuiJuModel alloc] init];
    
    //2. 取两级映射 (参考29069-todo10.1推举算法示图);
    NSDictionary *indexDic1 = [brotherScene getConIndexDic:brotherCanset.p];
    NSDictionary *indexDic2 = [brotherScene getAbsIndexDic:fatherScene.p];
    
    //3. 新生成fatherCanset (参考29069-todo10.1推举算法示图&步骤);
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    NSMutableDictionary *fatherSceneCansetIndexDic = [[NSMutableDictionary alloc] init];
    
    //========================= 算法关键代码 START =========================
    for (NSInteger i = 0; i < brotherCanset.content_ps.count; i++) {
        //4. 判断映射链: (参考29069-todo10.1-步骤2);
        NSNumber *brotherSceneIndex = ARR_INDEX([indexDic1 allKeysForObject:@(i)], 0);
        NSNumber *fatherSceneIndex = ARR_INDEX([indexDic2 allKeysForObject:brotherSceneIndex], 0);
        double deltaTime = [NUMTOOK(ARR_INDEX(brotherCanset.deltaTimes, i)) doubleValue];
        if (fatherSceneIndex) {
            //5. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(fatherScene.content_ps, fatherSceneIndex.intValue) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
            
            //5. 只有最终迁移成功的帧,记录新的indexDic;
            [fatherSceneCansetIndexDic setObject:@(i) forKey:fatherSceneIndex];
        } else {
            //6. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(brotherCanset.content_ps, i) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        }
    }
    //========================= 算法关键代码 END =========================
    
    //7. 将canset执行目标转成scene任务目标targetIndex (参考29093-方案);
    NSInteger fatherSceneTargetIndex = fatherScene.count;
    if (brotherCansetTargetIndex < brotherCanset.count) {
        
        //8. fatherCanset和brotherCanset长度一致;
        NSInteger fatherCansetTargetIndex = brotherCansetTargetIndex;
        NSArray *keys = [fatherSceneCansetIndexDic allKeysForObject:@(fatherCansetTargetIndex)];
        if (ARRISOK(keys)) {
            fatherSceneTargetIndex = NUMTOOK(ARR_INDEX(keys, 0)).integerValue;
        }
    }
    
    //9. 打包数据model返回;
    result.fatherCansetOrders = orders;
    result.fatherSceneCansetIndexDic = fatherSceneCansetIndexDic;
    result.fatherSceneTargetIndex = fatherSceneTargetIndex;
    return result;
}

+(AIFoNodeBase*) transferTuiJuForCreate:(TCTuiJuModel*)tuiJuModel fatherScene:(AIFoNodeBase*)fatherScene brotherScene:(AIFoNodeBase*)brotherScene brotherCanset:(AIFoNodeBase*)brotherCanset {
    //7. 构建result;
    AIFoNodeBase *fatherCanset = [theNet createConFoForCanset:tuiJuModel.fatherCansetOrders sceneFo:fatherScene sceneTargetIndex:fatherScene.count];
    
    //8. 新生成fatherPort;
    AITransferPort *newFatherPort = [AITransferPort newWithScene:fatherScene.p canset:fatherCanset.p];
    
    //9. 防重 (其实不可能重复,因为如果重复在override算法中当前cansetModel就已经被过滤了);
    if (![brotherScene.transferAbsPorts containsObject:newFatherPort]) {
        //10. 将newFatherCanset挂到fatherScene下;
        BOOL updateCansetSuccess = [fatherScene updateConCanset:fatherCanset.p targetIndex:tuiJuModel.fatherSceneTargetIndex];
        
        if (updateCansetSuccess) {
            //11. 为迁移后fatherCanset加上与fatherScene的indexDic (参考29075-todo4);
            [fatherCanset updateIndexDic:fatherScene indexDic:tuiJuModel.fatherSceneCansetIndexDic];
            
            //11. SP值也推举 (参考3101b-todo2);
            if (brotherCanset.count == fatherCanset.count) {
                [fatherCanset updateSPDic:brotherCanset.spDic];
            }
            [AITest test32:brotherCanset newCanset:fatherCanset];
            
            //12. 并进行迁移关联
            [AINetUtils relateTransfer:fatherScene.p absCanset:fatherCanset.p conScene:brotherScene.p conCanset:brotherCanset.p];
        }
    }
    return fatherCanset;
}

//MARK:===============================================================
//MARK:                     < transferAlg >
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

@end
