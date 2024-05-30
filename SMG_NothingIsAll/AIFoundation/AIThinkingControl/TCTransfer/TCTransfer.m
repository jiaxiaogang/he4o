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
 */
+(void) transferXv:(TOFoModel*)cansetModel {
    //1. 数据检查;
    if (!cansetModel) return;
    
    //2. 三种type,两种任务,迁移from到迁移to的路径因网络结构而不同 (参考31066-TODO5 & 31115);
    if (cansetModel.baseSceneModel.type == SceneTypeI) {
        if (!cansetModel.isH) {
            cansetModel.transferXvModel = [TCTransfer transferXv_IR:cansetModel];
        } else {
            cansetModel.transferXvModel = [TCTransfer transferXv_IH:cansetModel];
        }
    }else if(cansetModel.baseSceneModel.type == SceneTypeFather) {
        if (!cansetModel.isH) {
            cansetModel.transferXvModel = [TCTransfer transferXv_FR:cansetModel];
        } else {
            cansetModel.transferXvModel = [TCTransfer transferXv_FH:cansetModel];
        }
    }else if(cansetModel.baseSceneModel.type == SceneTypeBrother) {
        if (!cansetModel.isH) {
            cansetModel.transferXvModel = [TCTransfer transferXv_BR:cansetModel];
        } else {
            cansetModel.transferXvModel = [TCTransfer transferXv_BH:cansetModel];
        }
    }
}

+(TCTransferXvModel*) transferXv_IR:(TOFoModel*)cansetModel {
    //说明: 其实IR是不需要迁移的,这里填充xvModel,只是为了后续访问方便;
    //注: IR的cansetFrom和To是同一个,sceneFrom和sceneTo也是同一个;
    AIFoNodeBase *cansetFromTo = [SMGUtils searchNode:cansetModel.cansetFo];
    AIFoNodeBase *sceneFromTo = [SMGUtils searchNode:cansetModel.sceneFo];
    
    TCTransferXvModel *result = [[TCTransferXvModel alloc] init];
    result.cansetToOrders = [cansetFromTo convert2Orders];//cansetFrom的orders就是cansetTo的orders;
    result.sceneToCansetToIndexDic = [sceneFromTo getConIndexDic:cansetFromTo.p];
    result.sceneToTargetIndex = cansetModel.sceneTargetIndex;
    return result;
}

+(TCTransferXvModel*) transferXv_IH:(TOFoModel*)cansetModel {
    //1. 数据准备;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    
    //2. 数据准备: 取知识网络结构;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];
    AIFoNodeBase *sceneFrom = [SMGUtils searchNode:cansetModel.sceneFo];
    AIFoNodeBase *iRScene = [SMGUtils searchNode:rSceneModel.getIScene];
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    
    //3. sceneFrom和sceneTo是同一个时,不需要迁移 (此时: sceneFrom=sceneTo,cansetFrom=cansetTo) (但也封装一下xvModel以便后面使用);
    if ([sceneFrom isEqual:sceneTo]) {
        //2024.04.29: BUG: 修IH无需迁移时xvModel返回nil,导致后期使用xvModel报空指针问题;
        TCTransferXvModel *result = [[TCTransferXvModel alloc] init];
        result.cansetToOrders = [cansetFrom convert2Orders];//cansetFrom的orders就是cansetTo的orders;
        result.sceneToCansetToIndexDic = [sceneFrom getConIndexDic:cansetFrom.p];
        result.sceneToTargetIndex = cansetModel.sceneTargetIndex;
        return result;
    }
    
    //3. IH映射: indexDic综合计算 (参考31115-TODO1-4);
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[cansetFrom getAbsIndexDic:sceneFrom.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[sceneFrom getAbsIndexDic:iRScene.p]];
    DirectIndexDic *dic3 = [DirectIndexDic newNoToAbs:[iRScene getConIndexDic:sceneTo.p]];
    NSDictionary *zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2,dic3]];
    return [self convertZonHeIndexDic2XvModel:cansetModel zonHeIndexDic:zonHeIndexDic];
}

+(TCTransferXvModel*) transferXv_FR:(TOFoModel*)cansetModel {
    //1. 数据准备;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    
    //2. 数据准备: 取知识网络结构;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];//cansetFrom (R时为rCanset,H时为hCanset);
    AIFoNodeBase *fatherRScene = [SMGUtils searchNode:rSceneModel.getFatherScene];//R时为当前fatherSceneModel的scene;
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    
    //3. FH映射: indexDic综合计算 (参考31115-TODO1-4);
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[cansetFrom getAbsIndexDic:fatherRScene.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:sceneTo.p]];
    NSDictionary *zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2]];
    return [self convertZonHeIndexDic2XvModel:cansetModel zonHeIndexDic:zonHeIndexDic];
}

+(TCTransferXvModel*) transferXv_FH:(TOFoModel*)cansetModel {
    //1. 数据准备;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    
    //2. 数据准备: 取知识网络结构;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];//cansetFrom (R时为rCanset,H时为hCanset);
    AIFoNodeBase *fatherHScene = [SMGUtils searchNode:cansetModel.sceneFo];//HScene=RCanset (R时为rCanset, H时为当前迁移源from的hScene);
    AIFoNodeBase *fatherRScene = [SMGUtils searchNode:rSceneModel.getFatherScene];//R时为当前fatherSceneModel的scene;
    AIFoNodeBase *iRScene = [SMGUtils searchNode:rSceneModel.getIScene];
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    
    //3. FH映射: indexDic综合计算 (参考31115-TODO1-4);
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[cansetFrom getAbsIndexDic:fatherHScene.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[fatherHScene getAbsIndexDic:fatherRScene.p]];
    DirectIndexDic *dic3 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:iRScene.p]];
    DirectIndexDic *dic4 = [DirectIndexDic newNoToAbs:[iRScene getConIndexDic:sceneTo.p]];
    NSDictionary *zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2,dic3,dic4]];
    return [self convertZonHeIndexDic2XvModel:cansetModel zonHeIndexDic:zonHeIndexDic];
}

+(TCTransferXvModel*) transferXv_BR:(TOFoModel*)cansetModel {
    //1. 数据准备;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    
    //2. 数据准备: 取知识网络结构;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];//迁移源hCanset
    AIFoNodeBase *brotherRScene = [SMGUtils searchNode:rSceneModel.getBrotherScene];
    AIFoNodeBase *fatherRScene = [SMGUtils searchNode:rSceneModel.getFatherScene];//R时为当前fatherSceneModel的scene (无论是R还是H都迁移到fatherRScene下);
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    
    //3. BR映射 (参考29069-todo10.1推举算法示图);
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[cansetFrom getAbsIndexDic:brotherRScene.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[brotherRScene getAbsIndexDic:fatherRScene.p]];
    DirectIndexDic *dic3 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:sceneTo.p]];
    NSDictionary *zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2,dic3]];
    return [self convertZonHeIndexDic2XvModel:cansetModel zonHeIndexDic:zonHeIndexDic];
}

+(TCTransferXvModel*) transferXv_BH:(TOFoModel*)cansetModel {
    //1. 数据准备;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    
    //2. 数据准备: 取知识网络结构;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];//迁移源hCanset
    AIFoNodeBase *brotherHScene = [SMGUtils searchNode:cansetModel.sceneFo];//HScene=RCanset (R时为rCanset, H时为当前迁移源from的hScene);
    AIFoNodeBase *brotherRScene = [SMGUtils searchNode:rSceneModel.getBrotherScene];
    AIFoNodeBase *fatherRScene = [SMGUtils searchNode:rSceneModel.getFatherScene];//R时为当前fatherSceneModel的scene (无论是R还是H都迁移到fatherRScene下);
    AIFoNodeBase *iRScene = [SMGUtils searchNode:rSceneModel.getIScene];
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    
    //3. BH映射 (参考31114-示图&TODO);
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[cansetFrom getAbsIndexDic:brotherHScene.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[brotherHScene getAbsIndexDic:brotherRScene.p]];
    DirectIndexDic *dic3 = [DirectIndexDic newOkToAbs:[brotherRScene getAbsIndexDic:fatherRScene.p]];
    DirectIndexDic *dic4 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:iRScene.p]];
    DirectIndexDic *dic5 = [DirectIndexDic newNoToAbs:[iRScene getConIndexDic:sceneTo.p]];
    NSDictionary *zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2,dic3,dic4,dic5]];
    return [self convertZonHeIndexDic2XvModel:cansetModel zonHeIndexDic:zonHeIndexDic];
}

//MARK:===============================================================
//MARK:                     < 经验迁移-实V3 >
//MARK:===============================================================

+(void) transferSi:(TOFoModel*)cansetModel {
    //0. IR不需要迁移,这里生成siModel,便于后续使用;
    if (cansetModel.baseSceneModel.type == SceneTypeI && !cansetModel.isH) {
        cansetModel.transferSiModel = [AITransferModel newWithCansetTo:cansetModel.cansetFo];
        return;
    }
    
    //1. 数据准备;
    if (!cansetModel.transferXvModel) return;
    TCTransferXvModel *xvModel = cansetModel.transferXvModel;
    AIFoNodeBase *sceneFrom = [SMGUtils searchNode:cansetModel.sceneFo];
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];
    
    //2. 由虚转实: 构建cansetTo和siModel (支持:场景内防重);
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    AIFoNodeBase *cansetTo = [theNet createConFoForCanset:xvModel.cansetToOrders sceneFo:sceneTo sceneTargetIndex:xvModel.sceneToTargetIndex];
    cansetModel.transferSiModel = [AITransferModel newWithCansetTo:cansetTo.p];
    
    //3. 迁移时,顺带把spDic也累计了,但要通过transferPorts进行防重,避免重复累推 (其实不可能重复,因为如果重复在override算法中当前cansetModel就已经被过滤了);
    AITransferPort *portTo = [AITransferPort newWithScene:sceneTo.p canset:cansetTo.p];
    if (![sceneFrom.transferToPorts containsObject:portTo]) {
        
        //4. 将cansetTo挂到sceneTo下;
        BOOL updateCansetSuccess = [sceneTo updateConCanset:cansetTo.p targetIndex:xvModel.sceneToTargetIndex];
        
        if (updateCansetSuccess) {
            //5. 为迁移后cansetTo加上与sceneTo的indexDic (参考29075-todo4);
            [cansetTo updateIndexDic:sceneTo indexDic:xvModel.sceneToCansetToIndexDic];
            
            //6. SP值也迁移 (参考3101b-todo1 & todo2);
            [cansetTo updateSPDic:cansetFrom.spDic];
            [AITest test32:cansetFrom newCanset:cansetTo];
            
            //7. 并进行迁移关联 (以实现防重,避免重新累推spDic);
            [AINetUtils relateTransfer:sceneFrom cansetFrom:cansetFrom sceneTo:sceneTo cansetTo:cansetTo];
        }
    }
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
 *  MARK:--------------------得出综合映射后: 转为xvModel--------------------
 */
+(TCTransferXvModel*) convertZonHeIndexDic2XvModel:(TOFoModel*)cansetModel zonHeIndexDic:(NSDictionary*)zonHeIndexDic {
    //1. 数据准备;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    
    //6. 计算cansetToOrders
    //说明: 场景包含帧用indexDic映射来迁移替换,场景不包含帧用迁移前的为准 (参考31104);
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < cansetFrom.count; i++) {
        //a. 判断映射链: (参考29069-todo10.1-步骤2 & 31113-TODO8);
        NSNumber *sceneToIndex = [zonHeIndexDic objectForKey:@(i)];
        double deltaTime = [NUMTOOK(ARR_INDEX(cansetFrom.deltaTimes, i)) doubleValue];
        if (sceneToIndex) {
            //b. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(sceneTo.content_ps, sceneToIndex.intValue) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        } else {
            //c. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(cansetFrom.content_ps, i) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        }
    }
    
    //7. 将canset执行目标转成scene任务目标targetIndex (参考29093-方案);
    //> ifb三种类型的cansetTargetIndex是一致的,因为它们迁移长度一致;
    //> 无论是ifb哪个类型,目前推进到了哪一帧,我们最终都是要求达到目标的,所以本方法虽是伪迁移,但也要以最终目标为目的;
    BOOL isHAndTargetMapValid = cansetModel.isH && [zonHeIndexDic objectForKey:@(cansetModel.cansetTargetIndex)];
    NSInteger sceneToTargetIndex = isHAndTargetMapValid ? NUMTOOK([zonHeIndexDic objectForKey:@(cansetModel.cansetTargetIndex)]).integerValue : sceneTo.count;
    
    //9. 打包数据model返回 (映射需要返过来因为前面cansetFrom在前,现在是cansetTo在后);
    TCTransferXvModel *result = [[TCTransferXvModel alloc] init];
    result.cansetToOrders = orders;
    result.sceneToCansetToIndexDic = [SMGUtils reverseDic:zonHeIndexDic];
    result.sceneToTargetIndex = sceneToTargetIndex;
    return result;
}

@end
