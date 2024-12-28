//
//  TCScene.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "TCScene.h"

@implementation TCScene

/**
 *  MARK:--------------------R场景树--------------------
 *  @desc 收集三处候选集 (参考29069-todo3);
 *  @status 目前仅支持R任务,等到做去皮训练时有需要再支持H任务 (29069-todo2);
 *  @version
 *      2023.04.13: 过滤出有同区mv指向的,才收集到各级候选集中 (参考29069-todo4);
 *      2023.04.14: 为sceneModel记录cutIndex (参考29069-todo5.6);
 *      2023.05.07: TCScene支持过滤器(参考2908a-todo3);
 *  @result 将三级全收集返回 (返回的数据为: I,Father,Brother三者场景生成的CansetModel);
 */
+(NSArray*) rGetSceneTree:(ReasonDemandModel*)demand {
    //1. 数据准备;
    NSArray *iModels = nil;
    NSMutableArray *fatherModels = [[NSMutableArray alloc] init];
    NSMutableArray *brotherModels = [[NSMutableArray alloc] init];
    
    //2. 取自己级;
    iModels = [SMGUtils convertArr:demand.validPFos convertBlock:^id(AIMatchFoModel *pFo) {
        NSInteger aleardayCount = [TCSolutionUtil getRAleardayCount:demand pFo:pFo];
        return [AISceneModel newWithBase:nil type:SceneTypeI scene:pFo.matchFo cutIndex:aleardayCount - 1];
    }];
    
    //3. 取父类级;
    for (AISceneModel *iModel in iModels) {
        AIFoNodeBase *iFo = [SMGUtils searchNode:iModel.scene];//84ms
        NSArray *fatherScene_ps = [AIFilter rSolutionSceneFilter:iFo type:iModel.type];
        
        //a. 过滤器 & 转为CansetModel;
        NSArray *itemFatherModels = [SMGUtils convertArr:fatherScene_ps convertBlock:^id(AIKVPointer *item) {
            //a1. 过滤father不含截点的 (参考29069-todo5.6);
            NSDictionary *indexDic = [iFo getAbsIndexDic:item];
            NSNumber *fatherCutIndex = ARR_INDEX([indexDic allKeysForObject:@(iModel.cutIndex)], 0);
            if (!fatherCutIndex) return nil;
            
            //a2. 过滤无同区mv指向的 (参考29069-todo4);
            AIFoNodeBase *fo = [SMGUtils searchNode:item];
            if (![iFo.cmvNode_p.identifier isEqualToString:fo.cmvNode_p.identifier]) return nil;
            
            //a3. 将father生成模型;
            return [AISceneModel newWithBase:iModel type:SceneTypeFather scene:item cutIndex:fatherCutIndex.integerValue];
        }];
        [fatherModels addObjectsFromArray:itemFatherModels];
    }
    
    //4. 取兄弟级;
    BOOL brotherSwitch = false;
    for (AISceneModel *fatherModel in fatherModels) {
        //2024.11.05: BF改为实时推举了,场景树不需要再取它了 (参考33113);
        if (!brotherSwitch) break;
        
        AIFoNodeBase *fatherFo = [SMGUtils searchNode:fatherModel.scene];
        NSArray *brotherScene_ps = [AIFilter rSolutionSceneFilter:fatherFo type:fatherModel.type];//1799ms
        
        //a. 过滤器 & 转为CansetModel;
        NSArray *itemBrotherModels = [SMGUtils convertArr:brotherScene_ps convertBlock:^id(AIKVPointer *item) {
            //a1. 过滤brother不含截点的 (参考29069-todo5.6);
            NSDictionary *indexDic = [fatherFo getConIndexDic:item];
            NSNumber *brotherCutIndex = [indexDic objectForKey:@(fatherModel.cutIndex)];
            if (!brotherCutIndex) return nil;
            
            //a2. 过滤无同区mv指向的 (参考29069-todo4);
            AIFoNodeBase *fo = [SMGUtils searchNode:item];//68ms
            if (![fatherFo.cmvNode_p.identifier isEqualToString:fo.cmvNode_p.identifier]) return nil;
            
            //a3. 将brother生成模型;
            return [AISceneModel newWithBase:fatherModel type:SceneTypeBrother scene:item cutIndex:brotherCutIndex.integerValue];
        }];
        [brotherModels addObjectsFromArray:itemBrotherModels];
    }
    
    //5. 去重1: 数据准备;
    NSArray *iSceneArr = [SMGUtils convertArr:iModels convertBlock:^id(AISceneModel *obj) {
        return obj.scene;
    }];
    NSArray *fatherSceneArr = [SMGUtils convertArr:fatherModels convertBlock:^id(AISceneModel *obj) {
        return obj.scene;
    }];
    
    //6. 去重2: 优先级I>F>B: 即I有的F和B不能再有,F有的B不能再有;
    fatherModels = [SMGUtils filterArr:fatherModels checkValid:^BOOL(AISceneModel *item) {
        return ![iSceneArr containsObject:item.scene];
    }];
    brotherModels = [SMGUtils filterArr:brotherModels checkValid:^BOOL(AISceneModel *item) {
        return ![iSceneArr containsObject:item.scene] && ![fatherSceneArr containsObject:item.scene];
    }];
    
    //7. 去重3: 本层防重: 即F内不能重复,B内不能重复;
    fatherModels = [SMGUtils removeRepeat:fatherModels convertBlock:^id(AISceneModel *obj) {
        return obj.scene;
    }];
    brotherModels = [SMGUtils removeRepeat:brotherModels convertBlock:^id(AISceneModel *obj) {
        return obj.scene;
    }];
    
    //8. 将三级全收集返回;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObjectsFromArray:iModels];
    [result addObjectsFromArray:fatherModels];
    [result addObjectsFromArray:brotherModels];
    NSLog(@"第1步 R场景树枝点数 I:%ld + Father:%ld + Brother:%ld = 总:%ld",iModels.count,fatherModels.count,brotherModels.count,result.count);
    for (AISceneModel *item in result) {
        AIFoNodeBase *sceneFo = [SMGUtils searchNode:item.scene];
        NSArray *itemCansets = [sceneFo getConCansets:sceneFo.count];
        if (Log4GetCansetResult4R) NSLog(@"取得item场景: %@ %@ 候选集数:%ld",SceneType2Str(item.type),Pit2FStr(item.scene),itemCansets.count);
    }
    return result;
}

/**
 *  MARK:--------------------H场景树--------------------
 *  @version
 *      2023.09.12: BUG_修复把targetFoModel错当成scene,导致场景树返回几乎为空的问题 (参考30128);
 *      2023.09.15: RCanset做为HScene (参考30131-todo2);
 */
+(NSArray*) hGetSceneTree:(HDemandModel*)demand {
    //1. 数据准备;
    NSMutableArray *iModels = [[NSMutableArray alloc] init];
    NSMutableArray *fatherModels = [[NSMutableArray alloc] init];
    NSMutableArray *brotherModels = [[NSMutableArray alloc] init];
    TOFoModel *targetFoM = (TOFoModel*)demand.baseOrGroup.baseOrGroup;
    
    //2. 取自己级;
    AISceneModel *iModel = [AISceneModel newWithBase:nil type:SceneTypeI scene:targetFoM.content_p cutIndex:targetFoM.cansetCutIndex];
    [iModels addObject:iModel];
    
    //3. 取父类级;
    for (AISceneModel *iModel in iModels) {
        AIFoNodeBase *iFo = [SMGUtils searchNode:iModel.scene];//84ms
        NSArray *fatherScene_ps = [AIFilter hSolutionSceneFilter:iModel];
        
        //a. 过滤器 & 转为CansetModel;
        NSArray *itemFatherModels = [SMGUtils convertArr:fatherScene_ps convertBlock:^id(AIKVPointer *item) {
            //a1. 过滤father不含截点的 (参考29069-todo5.6);
            NSDictionary *indexDic = [iFo getAbsIndexDic:item];
            NSNumber *fatherCutIndex = ARR_INDEX([indexDic allKeysForObject:@(iModel.cutIndex)], 0);
            if (!fatherCutIndex) return nil;
            
            //a3. 将father生成模型;
            return [AISceneModel newWithBase:iModel type:SceneTypeFather scene:item cutIndex:fatherCutIndex.integerValue];
        }];
        [fatherModels addObjectsFromArray:itemFatherModels];
    }
    
    //4. 取兄弟级;
    BOOL brotherSwitch = false;
    for (AISceneModel *fatherModel in fatherModels) {
        //2024.11.05: BF改为实时推举了,场景树不需要再取它了 (参考33113);
        if (!brotherSwitch) break;
        
        AIFoNodeBase *fatherFo = [SMGUtils searchNode:fatherModel.scene];
        NSArray *brotherScene_ps = [AIFilter hSolutionSceneFilter:fatherModel];//1799ms
        
        //a. 过滤器 & 转为CansetModel;
        NSArray *itemBrotherModels = [SMGUtils convertArr:brotherScene_ps convertBlock:^id(AIKVPointer *item) {
            //a1. 过滤brother不含截点的 (参考29069-todo5.6);
            NSDictionary *indexDic = [fatherFo getConIndexDic:item];
            NSNumber *brotherCutIndex = [indexDic objectForKey:@(fatherModel.cutIndex)];
            if (!brotherCutIndex) return nil;
            
            //a3. 将brother生成模型;
            return [AISceneModel newWithBase:fatherModel type:SceneTypeBrother scene:item cutIndex:brotherCutIndex.integerValue];
        }];
        [brotherModels addObjectsFromArray:itemBrotherModels];
    }
    
    //5. 将三级全收集返回;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObjectsFromArray:iModels];
    [result addObjectsFromArray:fatherModels];
    [result addObjectsFromArray:brotherModels];
    NSLog(@"第1步 H场景树枝点数 I:%ld + Father:%ld + Brother:%ld = 总:%ld",iModels.count,fatherModels.count,brotherModels.count,result.count);
    return result;
}

@end
