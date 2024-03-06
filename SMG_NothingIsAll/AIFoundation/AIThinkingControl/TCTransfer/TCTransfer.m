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
//MARK:                     < 用体整体迁移算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------canset迁移算法 (29069-todo10)--------------------
 *  @desc 用于将canset从brother迁移到father再迁移到i场景下;
 *  @version
 *      2023.04.19: TCTranfer执行后,调用Canset识别类比 (参考29069-todo12);
 */
//+(void) transfer:(TOFoModel*)bestCansetModel complate:(void(^)(AITransferModel *brother,AITransferModel *father,AITransferModel *i))complate {
//    //0. 数据准备;
//    [theTC updateOperCount:kFILENAME];
//    Debug();
//    OFTitleLog(@"TCTransfer迁移", @" from%@",SceneType2Str(bestCansetModel.baseSceneModel.type));
//    AITransferModel *brotherResult = nil, *fatherResult = nil, *iResult = nil;
//    NSInteger targetIndex = bestCansetModel.targetIndex; //因为推举和继承的canset全是等长,所以他们仨的targetIndex也一样;
//
//    //1. 无base场景 或 type==I时 => 直接将cansetFo设为iCanset;
//    if (!bestCansetModel || bestCansetModel.baseSceneModel.type == SceneTypeI) {
//        AIKVPointer *iScene = bestCansetModel.sceneFo;
//        AIKVPointer *iCanset = bestCansetModel.cansetFo;
//        iResult = [AITransferModel newWithScene:iScene canset:iCanset];
//    }
//
//    //2. canset迁移之: father继承给i (参考29069-todo10.1);
//    if (bestCansetModel.baseSceneModel.type == SceneTypeFather) {
//        //a. 生成father结果;
//        AIFoNodeBase *fatherScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.scene];
//        AIFoNodeBase *fatherCanset = [SMGUtils searchNode:bestCansetModel.cansetFo];
//        fatherResult = [AITransferModel newWithScene:fatherScene.p canset:fatherCanset.p];
//        //b. 生成i结果;
//        AIFoNodeBase *iScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.base.scene];
//        AIFoNodeBase *iCanset = [self transferJiCen:fatherCanset fatherCansetTargetIndex:targetIndex fatherScene:fatherScene iScene:iScene];
//        iResult = [AITransferModel newWithScene:iScene.p canset:iCanset.p];
//        //c. 调用Canset识别类比 (参考29069-todo12);
//        //[TIUtils recognitionCansetFo:iCanset sceneFo:iScene es:ES_Default];
//    }
//
//    //3. canset迁移之: brother推举到father,再继承给i (参考29069-todo10.1);
//    if (bestCansetModel.baseSceneModel.type == SceneTypeBrother) {
//        //a. 得出brother结果;
//        AIFoNodeBase *brotherScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.scene];
//        AIFoNodeBase *brotherCanset = [SMGUtils searchNode:bestCansetModel.cansetFo];
//        brotherResult = [AITransferModel newWithScene:brotherScene.p canset:brotherCanset.p];
//
//        //b. 得出father结果;
//        AIFoNodeBase *fatherScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.base.scene];
//        AIFoNodeBase *fatherCanset = [self transferTuiJu:brotherCanset brotherCansetTargetIndex:targetIndex brotherScene:brotherScene fatherScene:fatherScene];
//        fatherResult = [AITransferModel newWithScene:fatherScene.p canset:fatherCanset.p];
//
//        //c. 得出i结果
//        AIFoNodeBase *iScene = [SMGUtils searchNode:bestCansetModel.baseSceneModel.base.base.scene];
//        AIFoNodeBase *iCanset = [self transferJiCen:fatherCanset fatherCansetTargetIndex:targetIndex fatherScene:fatherScene iScene:iScene];
//        iResult = [AITransferModel newWithScene:iScene.p canset:iCanset.p];
//
//        //d. 调用Canset识别类比 (参考29069-todo12);
//        //[TIUtils recognitionCansetFo:fatherCanset sceneFo:fatherScene es:ES_Default];
//        //[TIUtils recognitionCansetFo:iCanset sceneFo:iScene es:ES_Default];
//    }
//    if (brotherResult) NSLog(@"迁移结果: brotherScene:F%ld Canset:%@",brotherResult.scene.pointerId,Pit2FStr(brotherResult.canset));
//    if (fatherResult) NSLog(@"迁移结果: fatherScene:F%ld Canset:%@",fatherResult.scene.pointerId,Pit2FStr(fatherResult.canset));
//    if (iResult) NSLog(@"迁移结果: iScene:F%ld Canset:%@",iResult.scene.pointerId,Pit2FStr(iResult.canset));
//    DebugE();
//    complate(brotherResult,fatherResult,iResult);
//}

//MARK:===============================================================
//MARK:                     < 一用一体迁移算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------迁移之用 (仅得出模型) (参考31073-TODO1)--------------------
 *  @desc 为了方便Cansets实现实时竞争 (每次反馈时,可以根据伪迁移来判断反馈成立);
 *      2024.01.19: 初版-为每个CansetModel生成且只生成jiCenModel和tuiJuModel (参考31073-TODO1);
 */
+(void) transferForModel:(TOFoModel*)cansetModel {
    //1. 数据检查;
    if (!cansetModel) return;
    
    //3. =====================参考:TCTransfer.transfer()方法,当不同type时,不同处理;=====================
    //4. 三种type,使用模拟迁移的方法,取到iScene和iCanset的indexDic映射 (参考31066-TODO5);
    if (cansetModel.baseSceneModel.type == SceneTypeI) {
        //a. R时不用处理 & H时也要从hCansetFrom迁移到hSceneTo;
        cansetModel.tiDhModel = [TCTransfer transferTiDhForModel:cansetModel];
    }else if(cansetModel.baseSceneModel.type == SceneTypeFather) {
        //b. 模拟继承生成模型代码;
        cansetModel.jiCenModel = [TCTransfer transferJiCenForModel:cansetModel];
    }else if(cansetModel.baseSceneModel.type == SceneTypeBrother) {
        
        //b. 模拟推举生成模型代码;
        cansetModel.tuiJuModel = [TCTransfer transferTuiJuForModel:cansetModel];
        
        //d. 模拟继承生成模型代码;
        cansetModel.jiCenModel = [TCTransfer transferJiCenForModel:cansetModel];
    }
}

/**
 *  MARK:--------------------迁移之体 (仅构建节点和初始spDic) (参考31073-TODO2c)--------------------
 *  @desc 由用转体 (在转为bestingStatus状态时,调用此方法);
 */
+(void) transferForCreate:(TOFoModel*)cansetModel {
    //1. 无base场景 或 type==I时 => 直接将cansetFo设为iCanset;
    if (cansetModel.baseSceneModel.type == SceneTypeI) {
        cansetModel.i = [AITransferModel newWithScene:cansetModel.sceneFo canset:cansetModel.cansetFo];
    }
    
    //2. canset迁移之: father继承给i (参考29069-todo10.1);
    if (cansetModel.baseSceneModel.type == SceneTypeFather) {
        //a. 生成father结果;
        AIFoNodeBase *fatherScene = [SMGUtils searchNode:cansetModel.baseSceneModel.scene];
        AIFoNodeBase *fatherCanset = [SMGUtils searchNode:cansetModel.cansetFo];
        cansetModel.father = [AITransferModel newWithScene:fatherScene.p canset:fatherCanset.p];
        
        //b. 生成i结果;
        AIFoNodeBase *iScene = [SMGUtils searchNode:cansetModel.baseSceneModel.base.scene];
        AIFoNodeBase *iCanset = [self transferJiCenForCreate:cansetModel.jiCenModel iScene:iScene fatherScene:fatherScene fatherCanset:fatherCanset];
        cansetModel.i = [AITransferModel newWithScene:iScene.p canset:iCanset.p];
    }
    
    //3. canset迁移之: brother推举到father,再继承给i (参考29069-todo10.1);
    if (cansetModel.baseSceneModel.type == SceneTypeBrother) {
        //a. 得出brother结果;
        AIFoNodeBase *brotherScene = [SMGUtils searchNode:cansetModel.baseSceneModel.scene];
        AIFoNodeBase *brotherCanset = [SMGUtils searchNode:cansetModel.cansetFo];
        cansetModel.brother = [AITransferModel newWithScene:brotherScene.p canset:brotherCanset.p];
        
        //b. 得出father结果;
        AIFoNodeBase *fatherScene = [SMGUtils searchNode:cansetModel.baseSceneModel.base.scene];
        AIFoNodeBase *fatherCanset = [self transferTuiJuForCreate:cansetModel.tuiJuModel fatherScene:fatherScene brotherScene:brotherScene brotherCanset:brotherCanset];
        cansetModel.father = [AITransferModel newWithScene:fatherScene.p canset:fatherCanset.p];
        
        //c. 得出i结果
        AIFoNodeBase *iScene = [SMGUtils searchNode:cansetModel.baseSceneModel.base.base.scene];
        AIFoNodeBase *iCanset = [self transferJiCenForCreate:cansetModel.jiCenModel iScene:iScene fatherScene:fatherScene fatherCanset:fatherCanset];
        cansetModel.i = [AITransferModel newWithScene:iScene.p canset:iCanset.p];
    }
}

//MARK:===============================================================
//MARK:                     < 继承算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------canset继承算法 (29069-todo10.1推举算法示图&步骤)--------------------
 *  @desc 在brother调用时,需推举后再执行;
 *  @desc 用于将canset从father继承到i场景下;
 *  @version
 *      2023.05.11: BUG_canset的targetIndex是执行目标,而scene的targetIndex是任务目标,用错修复 (参考29093-线索 & 方案);
 *      2023.12.09: 迁移出的新canset改为仅在场景内防重 (参考3101b-todo5);
 *      2024.01.17: 拆分成两步: 先用(用来取model),后体(用来构建iCanset节点和构建关联继承spDic);
 *      2024.01.18: 把jiCenForModel加个重载 (因为如果fatherCanset本来就是推举来的,它压根没构建成时序,但这些该有的内容数据它一个不缺);
 *      2024.02.27: 重构简化下代码,参数只传cansetModel,在方法内自行取参数;
 *      2024.03.02: 支持H时,继承算法的迭代 (参考31115);
 */
+(TCJiCenModel*) transferJiCenForModel:(TOFoModel*)cansetModel {
    //1. 数据准备;
    TOFoModel *targetFoM = (TOFoModel*)cansetModel.basePFoOrTargetFoModel;//当前如果是H,这表示正在推进中targetFoM;
    AIKVPointer *hSceceTo = ISOK(targetFoM, TOFoModel.class) ? targetFoM.i.canset : nil;//当前如果是H,从targetFoM取hSceneTo迁移目标;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    AIFoNodeBase *fatherRScene = [SMGUtils searchNode:rSceneModel.getFatherScene];//R时为当前fatherSceneModel的scene;
    AIFoNodeBase *fatherHScene = [SMGUtils searchNode:cansetModel.sceneFo];//HScene=RCanset (R时为rCanset, H时为当前迁移源from的hScene);
    AIFoNodeBase *iRScene = [SMGUtils searchNode:rSceneModel.getIScene];
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];//cansetFrom (R时为rCanset,H时为hCanset) (type=father时可用);
    TCTuiJuModel *tuiJuModel = cansetModel.tuiJuModel; //已经推举的值 (type=brother时可用);
    AIFoNodeBase *sceneTo = cansetModel.isH ? [SMGUtils searchNode:hSceceTo] : iRScene;
    
    //2. 数据准备之cansetTargetIndex: 无论是ifb哪个类型,目前推进到了哪一帧,我们最终都是要求达到目标的,所以本方法虽然都是伪迁移,但也要以最终目标为目的;
    NSInteger cansetFromTargetIndex = cansetModel.targetIndex;//ifb三种类型的cansetTargetIndex是一致的,因为它们迁移长度一致;
    
    //3. 数据准备之迁移源数据: 取fatherContent_ps(迁移源content_ps) & fatherDeltaTimes(迁移源deltaTimes);
    NSArray *cansetFromContent_ps = nil, *cansetFromDeltaTimes = nil;
    if (cansetModel.baseSceneModel.type == SceneTypeFather) {
        //a. father时: 从迁移源cansetFrom取继承所需的father内容数据 (含content & deltaTimes & indexDic三种内容);
        cansetFromContent_ps = cansetFrom.content_ps;
        cansetFromDeltaTimes = cansetFrom.deltaTimes;
    } else if (cansetModel.baseSceneModel.type == SceneTypeBrother) {
        //b. brother时: 从tuiJuModel取继承所需的father内容数据 (含content & deltaTimes & indexDic三种内容);
        cansetFromContent_ps = [SMGUtils convertArr:tuiJuModel.fatherCansetOrders convertBlock:^id(AIShortMatchModel_Simple *obj) {
            return obj.alg_p;
        }];
        cansetFromDeltaTimes = [SMGUtils convertArr:tuiJuModel.fatherCansetOrders convertBlock:^id(AIShortMatchModel_Simple *obj) {
            return @(obj.inputTime);
        }];
    } else {
        return nil;
    }
    
    //4. 数据准备之迁移源数据: indexDic综合计算 (参考31115-TODO1-4);
    NSDictionary *zonHeIndexDic = nil;
    if (cansetModel.baseSceneModel.type == SceneTypeFather && cansetModel.isH) {
        //第1种: type=father & H时(二上二下),从fatherHCanset向上->fatherRCanset->fatherRScene,再向下->iRScene->iRCanset: 求出综合indexDic;
        DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[fatherHScene getConIndexDic:cansetFrom.p]];
        DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[fatherRScene getConIndexDic:fatherHScene.p]];
        DirectIndexDic *dic3 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:iRScene.p]];
        DirectIndexDic *dic4 = [DirectIndexDic newNoToAbs:[iRScene getConIndexDic:hSceceTo]];
        zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2,dic3,dic4]];
    } else if (cansetModel.baseSceneModel.type == SceneTypeFather && !cansetModel.isH) {
        //第2种: type=father & R时(一上一下),从fatherRCanset向上->fatherRScene,再向下->iRScene: 求出综合indexDic;
        DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[fatherRScene getConIndexDic:cansetFrom.p]];
        DirectIndexDic *dic2 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:iRScene.p]];
        zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2]];
    } else if (cansetModel.baseSceneModel.type == SceneTypeBrother && cansetModel.isH) {
        //第3种: type=brother & H时(一上二下),从fatherHCanset向上->fatherRScene,再向下->iRScene->iRCanset: 求出综合indexDic;
        DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:tuiJuModel.fatherSceneCansetIndexDic];//从推举模型,得到f的indexDic;
        DirectIndexDic *dic2 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:iRScene.p]];
        DirectIndexDic *dic3 = [DirectIndexDic newNoToAbs:[iRScene getConIndexDic:hSceceTo]];
        zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2,dic3]];
    } else if (cansetModel.baseSceneModel.type == SceneTypeBrother && !cansetModel.isH) {
        //第4种: type=brother & R时(一上一下),从fatherRCanset向上->fatherRScene,再向下->iRScene: 求出综合indexDic;
        DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:tuiJuModel.fatherSceneCansetIndexDic];//从推举模型,得到f的indexDic;
        DirectIndexDic *dic2 = [DirectIndexDic newNoToAbs:[fatherRScene getConIndexDic:iRScene.p]];
        zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2]];
    }
    zonHeIndexDic = DICTOOK(zonHeIndexDic);
    
    //1. 数据准备;
    TCJiCenModel *result = [[TCJiCenModel alloc] init];
    
    //3. 新生成fatherCanset (参考29069-todo10.1推举算法示图&步骤);
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    
    //========================= 算法关键代码 START =========================
    for (NSInteger i = 0; i < cansetFromContent_ps.count; i++) {
        //4. 判断映射链: (参考29069-todo10.1-步骤2);
        NSNumber *sceneToIndex = [zonHeIndexDic objectForKey:@(i)];
        double deltaTime = [NUMTOOK(ARR_INDEX(cansetFromDeltaTimes, i)) doubleValue];
        if (sceneToIndex) {
            //5. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(sceneTo.content_ps, sceneToIndex.intValue) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        } else {
            //6. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(cansetFromContent_ps, i) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        }
    }
    //========================= 算法关键代码 END =========================
    
    //7. 将canset执行目标转成scene任务目标targetIndex (参考29093-方案);
    NSInteger sceneToTargetIndex = sceneTo.count;
    if (cansetFromTargetIndex < cansetFrom.count) {
        
        //8. iCanset和fatherCanset长度一致;
        NSNumber *sceneToTargetNum = [zonHeIndexDic objectForKey:@(cansetFromTargetIndex)];
        if (sceneToTargetNum) {
            sceneToTargetIndex = sceneToTargetNum.integerValue;
        }
    }
    
    //9. 打包数据model返回 (映射需要返过来因为前面cansetFrom在前,现在是cansetTo在后);
    result.iCansetOrders = orders;
    result.iSceneCansetIndexDic = [SMGUtils reverseDic:zonHeIndexDic];
    result.iSceneTargetIndex = sceneToTargetIndex;
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

//MARK:===============================================================
//MARK:                     < 推举算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------canset推举算法 (29069-todo10.1推举算法示图&步骤)--------------------
 *  @desc 用于将canset从brother推举到father场景下;
 *  @version
 *      2023.05.04: 通过fo全局防重实现推举防重 (参考29081-todo32);
 *      2023.12.09: 迁移出的新canset改为仅在场景内防重 (参考3101b-todo5);
 *      2024.01.17: 拆分成两步: 先用(用来取model),后体(用来构建fatherCanset节点和构建关联继承spDic);
 *      2024.01.17: 补上推举算法中fatherSceneTargetIndex一直是错误的问题 (原来的值一直是fatherScene.count);
 *      2024.02.27: 重构简化下代码,参数只传cansetModel,在方法内自行取参数;
 *      2024.02.29: 支持indexDic综合计算 (参考31113-TODO7&TODO8);
 */
+(TCTuiJuModel*) transferTuiJuForModel:(TOFoModel*)cansetModel {
    //1. 数据准备;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:rSceneModel.getFatherScene];//R时为当前fatherSceneModel的scene (无论是R还是H都迁移到fatherRScene下);
    AIFoNodeBase *brotherRScene = [SMGUtils searchNode:rSceneModel.getBrotherScene];
    AIFoNodeBase *brotherHScene = [SMGUtils searchNode:cansetModel.sceneFo];//HScene=RCanset (R时为rCanset, H时为当前迁移源from的hScene);
    
    //2. 数据准备之cansetTargetIndex: 无论是ifb哪个类型,目前推进到了哪一帧,我们最终都是要求达到目标的,所以本方法虽然都是伪迁移,但也要以最终目标为目的;
    NSInteger cansetFromTargetIndex = cansetModel.targetIndex;//ifb三种类型的cansetTargetIndex是一致的,因为它们迁移长度一致;
    
    //a. 取brother数据;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];//迁移源hCanset
    
    //1. 数据准备;
    TCTuiJuModel *result = [[TCTuiJuModel alloc] init];
    
    //4. 将x个indexDic综合成一个 (H时是三级映射,R时是两级映射);
    NSDictionary *zonHeIndexDic = nil;
    if (cansetModel.isH) {
        //5. H时取三级映射 (参考31114-示图&TODO);
        DirectIndexDic *indexDic0 = [DirectIndexDic newNoToAbs:[brotherHScene getConIndexDic:cansetFrom.p]];
        DirectIndexDic *indexDic1 = [DirectIndexDic newNoToAbs:[brotherRScene getConIndexDic:brotherHScene.p]];
        DirectIndexDic *indexDic2 = [DirectIndexDic newNoToAbs:[brotherRScene getAbsIndexDic:sceneTo.p]];
        zonHeIndexDic = [TOUtils zonHeIndexDic:@[indexDic2,indexDic1,indexDic0]];
    } else {
        //6. R时取两级映射 (参考29069-todo10.1推举算法示图);
        DirectIndexDic *indexDic1 = [DirectIndexDic newNoToAbs:[brotherRScene getConIndexDic:cansetFrom.p]];
        DirectIndexDic *indexDic2 = [DirectIndexDic newNoToAbs:[brotherRScene getAbsIndexDic:sceneTo.p]];
        zonHeIndexDic = [TOUtils zonHeIndexDic:@[indexDic2,indexDic1]];
    }
    zonHeIndexDic = DICTOOK(zonHeIndexDic);
    
    //3. 新生成fatherCanset (参考29069-todo10.1推举算法示图&步骤);
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    
    //========================= 算法关键代码 START =========================
    for (NSInteger i = 0; i < cansetFrom.content_ps.count; i++) {
        //4. 判断映射链: (参考29069-todo10.1-步骤2 & 31113-TODO8);
        NSNumber *sceneToIndex = ARR_INDEX([zonHeIndexDic allKeysForObject:@(i)], 0);
        double deltaTime = [NUMTOOK(ARR_INDEX(cansetFrom.deltaTimes, i)) doubleValue];
        if (sceneToIndex) {
            //5. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(sceneTo.content_ps, sceneToIndex.intValue) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        } else {
            //6. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(cansetFrom.content_ps, i) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        }
    }
    //========================= 算法关键代码 END =========================
    
    //7. 将canset执行目标转成scene任务目标targetIndex (参考29093-方案);
    NSInteger sceneToTargetIndex = sceneTo.count;
    if (cansetFromTargetIndex < cansetFrom.count) {
        
        //8. fatherCanset和brotherCanset长度一致;
        NSArray *keys = [zonHeIndexDic allKeysForObject:@(cansetFromTargetIndex)];
        if (ARRISOK(keys)) {
            sceneToTargetIndex = NUMTOOK(ARR_INDEX(keys, 0)).integerValue;
        }
    }
    
    //9. 打包数据model返回;
    result.fatherCansetOrders = orders;
    result.fatherSceneCansetIndexDic = zonHeIndexDic;
    result.fatherSceneTargetIndex = sceneToTargetIndex;
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
//MARK:                     < TiDH迁移 (type=I 任务=H时调用 >
//MARK:===============================================================
+(TCTransferXvModel*) transferTiDhForModel:(TOFoModel*)cansetModel {
    //1. 数据准备;
    TOFoModel *targetFoM = (TOFoModel*)cansetModel.basePFoOrTargetFoModel;//当前如果是H,这表示正在推进中targetFoM;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    
    //2. 数据准备: 取知识网络结构;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];
    AIFoNodeBase *hSceneFrom = [SMGUtils searchNode:cansetModel.sceneFo];
    AIFoNodeBase *iRScene = [SMGUtils searchNode:rSceneModel.getIScene];
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:targetFoM.i.canset];
    if (cansetModel.baseSceneModel.type != SceneTypeI || !cansetModel.isH || [hSceneFrom isEqual:sceneTo]) {
        return nil;
    }
    
    //3. 数据准备之cansetTargetIndex: 无论是ifb哪个类型,目前推进到了哪一帧,我们最终都是要求达到目标的,所以本方法虽然都是伪迁移,但也要以最终目标为目的;
    NSInteger cansetFromTargetIndex = cansetModel.targetIndex;//ifb三种类型的cansetTargetIndex是一致的,因为它们迁移长度一致;
    
    //4. 数据准备之迁移源数据: 取fatherContent_ps(迁移源content_ps) & fatherDeltaTimes(迁移源deltaTimes);
    NSArray *cansetFromContent_ps = cansetFrom.content_ps;
    NSArray *cansetFromDeltaTimes = cansetFrom.deltaTimes;
    
    //5. 数据准备之迁移源数据: indexDic综合计算 (参考31115-TODO1-4);
    //第5种: type=i & H时(二上一下),从hCansetFrom向上->hSceneFrom->iRScene,再向下->hSceneTo: 求出综合indexDic;
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[hSceneFrom getConIndexDic:cansetFrom.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[iRScene getConIndexDic:hSceneFrom.p]];
    DirectIndexDic *dic3 = [DirectIndexDic newNoToAbs:[iRScene getConIndexDic:sceneTo.p]];
    NSDictionary *zonHeIndexDic = [TOUtils zonHeIndexDic:@[dic1,dic2,dic3]];
    
    //6. 计算cansetToOrders
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < cansetFromContent_ps.count; i++) {
        //a. 判断映射链: (参考29069-todo10.1-步骤2);
        NSNumber *hSceneToIndex = [zonHeIndexDic objectForKey:@(i)];
        double deltaTime = [NUMTOOK(ARR_INDEX(cansetFromDeltaTimes, i)) doubleValue];
        if (hSceneToIndex) {
            //b. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(sceneTo.content_ps, hSceneToIndex.intValue) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        } else {
            //c. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(cansetFromContent_ps, i) inputTime:deltaTime isTimestamp:false];
            [orders addObject:order];
        }
    }
    
    //7. 将canset执行目标转成scene任务目标targetIndex (参考29093-方案);
    NSInteger sceneToTargetIndex = sceneTo.count;
    if (cansetFromTargetIndex < cansetFrom.count) {
        
        //8. iCanset和fatherCanset长度一致;
        NSNumber *sceneToTargetNum = [zonHeIndexDic objectForKey:@(cansetFromTargetIndex)];
        if (sceneToTargetNum) {
            sceneToTargetIndex = sceneToTargetNum.integerValue;
        }
    }
    
    //9. 打包数据model返回 (映射需要返过来因为前面cansetFrom在前,现在是cansetTo在后);
    TCTransferXvModel *result = [[TCTransferXvModel alloc] init];
    result.cansetToOrders = orders;
    result.sceneToCansetToIndexDic = [SMGUtils reverseDic:zonHeIndexDic];
    result.sceneToTargetIndex = sceneToTargetIndex;
    return result;
}

//MARK:===============================================================
//MARK:                     < 虚V2 >
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

+(TCTransferXvModel*) transferXv_IR:(TOFoModel*)cansetModel { return nil; }

+(TCTransferXvModel*) transferXv_IH:(TOFoModel*)cansetModel {
    //1. 数据准备;
    AISceneModel *rSceneModel = cansetModel.baseSceneModel;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    
    //2. 数据准备: 取知识网络结构;
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:cansetModel.cansetFo];
    AIFoNodeBase *hSceneFrom = [SMGUtils searchNode:cansetModel.sceneFo];
    AIFoNodeBase *iRScene = [SMGUtils searchNode:rSceneModel.getIScene];
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    if ([hSceneFrom isEqual:sceneTo]) return nil;
    
    //3. 数据准备之cansetTargetIndex: 无论是ifb哪个类型,目前推进到了哪一帧,我们最终都是要求达到目标的,所以本方法虽然都是伪迁移,但也要以最终目标为目的;
    NSInteger cansetFromTargetIndex = cansetModel.targetIndex;//ifb三种类型的cansetTargetIndex是一致的,因为它们迁移长度一致;
    
    //4. 数据准备之迁移源数据: 取fatherContent_ps(迁移源content_ps) & fatherDeltaTimes(迁移源deltaTimes);
    NSArray *cansetFromContent_ps = cansetFrom.content_ps;
    NSArray *cansetFromDeltaTimes = cansetFrom.deltaTimes;
    
    //5. 数据准备之迁移源数据: indexDic综合计算 (参考31115-TODO1-4);
    //第5种: type=i & H时(二上一下),从hCansetFrom向上->hSceneFrom->iRScene,再向下->hSceneTo: 求出综合indexDic;
    DirectIndexDic *dic1 = [DirectIndexDic newOkToAbs:[cansetFrom getAbsIndexDic:hSceneFrom.p]];
    DirectIndexDic *dic2 = [DirectIndexDic newOkToAbs:[hSceneFrom getAbsIndexDic:iRScene.p]];
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
//MARK:                     < 实V2 >
//MARK:===============================================================
+(AIFoNodeBase*) transferSi:(TCTransferXvModel*)xvModel cansetModel:(TOFoModel*)cansetModel iScene:(AIFoNodeBase*)iScene fatherScene:(AIFoNodeBase*)fatherScene fatherCanset:(AIFoNodeBase*)fatherCanset {
    //7. 构建result & 场景内防重;
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:cansetModel.sceneTo];
    AIFoNodeBase *cansetTo = [theNet createConFoForCanset:xvModel.cansetToOrders sceneFo:sceneTo sceneTargetIndex:xvModel.sceneToTargetIndex];
    cansetModel.transferSiModel = [AITransferModel newWithScene:sceneTo.p canset:cansetTo.p];
    
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
    BOOL isHAndTargetMapValid = cansetModel.isH && [zonHeIndexDic objectForKey:@(cansetModel.targetIndex)];
    NSInteger sceneToTargetIndex = isHAndTargetMapValid ? NUMTOOK([zonHeIndexDic objectForKey:@(cansetModel.targetIndex)]).integerValue : sceneTo.count;
    
    //9. 打包数据model返回 (映射需要返过来因为前面cansetFrom在前,现在是cansetTo在后);
    TCTransferXvModel *result = [[TCTransferXvModel alloc] init];
    result.cansetToOrders = orders;
    result.sceneToCansetToIndexDic = [SMGUtils reverseDic:zonHeIndexDic];
    result.sceneToTargetIndex = sceneToTargetIndex;
    return result;
}

@end
