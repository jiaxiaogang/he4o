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
+(void) transfer:(AICansetModel*)bestCansetModel complate:(void(^)(AIKVPointer *brotherCanset,AIKVPointer *fatherCanset,AIKVPointer *iCanset))complate {
    //0. 数据准备;
    AIKVPointer *brotherCanset = nil, *fatherCanset = nil, *iCanset = nil;
    NSInteger targetIndex = bestCansetModel.targetIndex; //因为推举和继承的canset全是等长,所以他们仨的targetIndex也一样;
    
    //1. 无base场景 或 type==I时 => 直接将cansetFo设为iCanset;
    if (!bestCansetModel || bestCansetModel.baseSceneModel.type == SceneTypeI) {
        complate(nil,nil,bestCansetModel.cansetFo);
        return;
    }
    
    //2. canset迁移之: father继承给i (参考29069-todo10.1);
    if (bestCansetModel.baseSceneModel.type == SceneTypeFather) {
        //a. 数据准备;
        AIKVPointer *fatherScene = bestCansetModel.baseSceneModel.scene;
        AIKVPointer *iScene = bestCansetModel.baseSceneModel.base.scene;
        //b. 得出两个canset;
        fatherCanset = bestCansetModel.cansetFo;
        iCanset = [self transferJiCen:fatherCanset fatherCansetTargetIndex:targetIndex fatherScene:fatherScene iScene_p:iScene];
        
        //c. 调用Canset识别类比 (参考29069-todo12);
        [TIUtils recognitionCansetFo:iCanset sceneFo:iScene];
    }
    
    //3. canset迁移之: brother推举到father,再继承给i (参考29069-todo10.1);
    if (bestCansetModel.baseSceneModel.type == SceneTypeBrother) {
        //a. 数据准备;
        AIKVPointer *brotherScene = bestCansetModel.baseSceneModel.scene;
        AIKVPointer *fatherScene = bestCansetModel.baseSceneModel.base.scene;
        AIKVPointer *iScene = bestCansetModel.baseSceneModel.base.base.scene;
        //b. 得出三个canset;
        brotherCanset = bestCansetModel.cansetFo;
        fatherCanset = [self transfer4TuiJu:brotherCanset brotherCansetTargetIndex:targetIndex brotherScene:brotherScene fatherScene_p:fatherScene];
        iCanset = [self transferJiCen:fatherCanset fatherCansetTargetIndex:targetIndex fatherScene:fatherScene iScene_p:iScene];
        
        //c. 调用Canset识别类比 (参考29069-todo12);
        [TIUtils recognitionCansetFo:fatherCanset sceneFo:fatherScene];
        [TIUtils recognitionCansetFo:iCanset sceneFo:iScene];
    }
    complate(brotherCanset,fatherCanset,iCanset);
}

/**
 *  MARK:--------------------canset继承算法 (29069-todo10.1推举算法示图&步骤)--------------------
 *  @desc 用于将canset从father继承到i场景下;
 */
+(AIKVPointer*) transferJiCen:(AIKVPointer*)fatherCanset fatherCansetTargetIndex:(NSInteger)fatherCansetTargetIndex fatherScene:(AIKVPointer*)fatherScene_p iScene_p:(AIKVPointer*)iScene_p {
    //1. 数据准备;
    AIKVPointer *iCanset = nil;
    AIFoNodeBase *fatherScene = [SMGUtils searchNode:fatherScene_p];
    AIFoNodeBase *iScene = [SMGUtils searchNode:iScene_p];
    
    //2. 取两级映射 (参考29069-todo10.1推举算法示图);
    NSDictionary *indexDic1 = [fatherScene getConIndexDic:fatherCanset];
    NSDictionary *indexDic2 = [fatherScene getConIndexDic:iScene_p];
    
    //3. 新生成fatherCanset (参考29069-todo10.1推举算法示图&步骤);
    AIFoNodeBase *fatherCansetNode = [SMGUtils searchNode:fatherCanset];
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    
    //========================= 算法关键代码 START =========================
    for (NSInteger i = 0; i < fatherCansetNode.content_ps.count; i++) {
        //4. 判断映射链: (参考29069-todo10.1-步骤2);
        NSNumber *fatherSceneIndex = ARR_INDEX([indexDic1 allKeysForObject:@(i)], 0);
        NSNumber *iSceneIndex = [indexDic2 objectForKey:fatherSceneIndex];
        double deltaTime = [NUMTOOK(ARR_INDEX(fatherCansetNode.deltaTimes, i)) doubleValue];
        if (iSceneIndex) {
            //5. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(iScene.content_ps, iSceneIndex.intValue) inputTime:deltaTime];
            [orders addObject:order];
        } else {
            //6. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(fatherCansetNode.content_ps, i) inputTime:deltaTime];
            [orders addObject:order];
        }
    }
    //========================= 算法关键代码 END =========================
    
    //7. 构建result;
    iCanset = [theNet createConFo:orders].pointer;
    
    //8. 新生成fatherPort;
    AITransferPort *newIPort = [AITransferPort newWithScene:iScene_p canset:iCanset];
    
    //9. 防重 (其实不可能重复,因为如果重复在override算法中当前cansetModel就已经被过滤了);
    if (![fatherScene.transferConPorts containsObject:newIPort]) {
        //10. 将newIPort挂到iScene下;
        AIFoNodeBase *iScene = [SMGUtils searchNode:iScene_p];
        [iScene updateConCanset:iCanset targetIndex:fatherCansetTargetIndex];//前后canset同长度,所以传前者targetIndex即可;
        
        //11. 并进行迁移关联
        [AINetUtils relateTransfer:fatherScene_p absCanset:fatherCanset conScene:iScene_p conCanset:iCanset];
    }
    return iCanset;
}

/**
 *  MARK:--------------------canset推举算法 (29069-todo10.1推举算法示图&步骤)--------------------
 *  @desc 用于将canset从brother推举到father场景下;
 */
+(AIKVPointer*) transfer4TuiJu:(AIKVPointer*)brotherCanset brotherCansetTargetIndex:(NSInteger)brotherCansetTargetIndex brotherScene:(AIKVPointer*)brotherScene_p fatherScene_p:(AIKVPointer*)fatherScene_p {
    //1. 数据准备;
    AIKVPointer *fatherCanset = nil;
    AIFoNodeBase *brotherScene = [SMGUtils searchNode:brotherScene_p];
    AIFoNodeBase *fatherScene = [SMGUtils searchNode:fatherScene_p];
    
    //2. 取两级映射 (参考29069-todo10.1推举算法示图);
    NSDictionary *indexDic1 = [brotherScene getConIndexDic:brotherCanset];
    NSDictionary *indexDic2 = [brotherScene getAbsIndexDic:fatherScene_p];
    
    //3. 新生成fatherCanset (参考29069-todo10.1推举算法示图&步骤);
    AIFoNodeBase *brotherCansetNode = [SMGUtils searchNode:brotherCanset];
    NSMutableArray *orders = [[NSMutableArray alloc] init];
    
    //========================= 算法关键代码 START =========================
    for (NSInteger i = 0; i < brotherCansetNode.content_ps.count; i++) {
        //4. 判断映射链: (参考29069-todo10.1-步骤2);
        NSNumber *brotherSceneIndex = ARR_INDEX([indexDic1 allKeysForObject:@(i)], 0);
        NSNumber *fatherSceneIndex = ARR_INDEX([indexDic2 allKeysForObject:brotherSceneIndex], 0);
        double deltaTime = [NUMTOOK(ARR_INDEX(brotherCansetNode.deltaTimes, i)) doubleValue];
        if (fatherSceneIndex) {
            //5. 通过则收集迁移后scene元素 (参考29069-todo10.1-步骤3);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(fatherScene.content_ps, fatherSceneIndex.intValue) inputTime:deltaTime];
            [orders addObject:order];
        } else {
            //6. 不通过则收集迁移前canset元素 (参考29069-todo10.1-步骤4);
            id order = [AIShortMatchModel_Simple newWithAlg_p:ARR_INDEX(brotherCansetNode.content_ps, i) inputTime:deltaTime];
            [orders addObject:order];
        }
    }
    //========================= 算法关键代码 END =========================
    
    //7. 构建result;
    fatherCanset = [theNet createConFo:orders].pointer;
    
    //8. 新生成fatherPort;
    AITransferPort *newFatherPort = [AITransferPort newWithScene:fatherScene_p canset:fatherCanset];
    
    //9. 防重 (其实不可能重复,因为如果重复在override算法中当前cansetModel就已经被过滤了);
    if (![brotherScene.transferAbsPorts containsObject:newFatherPort]) {
        //10. 将newFatherCanset挂到fatherScene下;
        AIFoNodeBase *fatherScene = [SMGUtils searchNode:fatherScene_p];
        [fatherScene updateConCanset:fatherCanset targetIndex:brotherCansetTargetIndex];//前后canset同长度,所以传前者targetIndex即可;
        
        //11. 并进行迁移关联
        [AINetUtils relateTransfer:fatherScene_p absCanset:fatherCanset conScene:brotherScene_p conCanset:brotherCanset];
    }
    return fatherCanset;
}

@end
