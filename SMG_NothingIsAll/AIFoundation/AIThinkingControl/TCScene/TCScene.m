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
 *  MARK:--------------------cansets--------------------
 *  @desc 收集三处候选集 (参考29069-todo3);
 *  @status 目前仅支持R任务,等到做去皮训练时有需要再支持H任务 (29069-todo2);
 *  @problem 因为有多条共同抽象的可能性,所以father和brother中的元素是有可能重复的;
 *          > 先不解决,因为后面还要防重等,这个问题先不解决看有没什么影响,有影响时再来加防重功能;
 *          > 如果要加防重的话,构建[AISceneModel newWithBase]时就给防重了;
 *  @version
 *      2023.04.13: 过滤出有同区mv指向的,才收集到各级候选集中 (参考29069-todo4);
 *      2023.04.14: 为sceneModel记录cutIndex (参考29069-todo5.6);
 *  @result 将三级全收集返回 (返回的数据为: I,Father,Brother三者场景生成的CansetModel);
 */
+(NSArray*) getSceneTree:(ReasonDemandModel*)demand {
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
        AIFoNodeBase *iFo = [SMGUtils searchNode:iModel.scene];
        NSArray *fatherScenePorts = [AINetUtils absPorts_All:iFo];
        
        //a. 过滤器 & 转为CansetModel;
        NSArray *itemFatherModels = [SMGUtils convertArr:fatherScenePorts convertBlock:^id(AIPort *item) {
            //a1. 过滤father不含截点的 (参考29069-todo5.6);
            NSDictionary *indexDic = [iFo getAbsIndexDic:item.target_p];
            NSNumber *fatherCutIndex = ARR_INDEX([indexDic allKeysForObject:@(iModel.cutIndex)], 0);
            if (!fatherCutIndex) return nil;
            
            //a2. 过滤无同区mv指向的 (参考29069-todo4);
            AIFoNodeBase *fo = [SMGUtils searchNode:item.target_p];
            if (![iFo.cmvNode_p.identifier isEqualToString:fo.cmvNode_p.identifier]) return nil;
            
            //a3. 将father生成模型;
            return [AISceneModel newWithBase:iModel type:SceneTypeFather scene:item.target_p cutIndex:fatherCutIndex.integerValue];
        }];
        [fatherModels addObjectsFromArray:itemFatherModels];
    }
    
    //4. 取兄弟级;
    for (AISceneModel *fatherModel in fatherModels) {
        AIFoNodeBase *fatherFo = [SMGUtils searchNode:fatherModel.scene];
        NSArray *brotherScenePorts = [AINetUtils conPorts_All:fatherFo];
        
        //a. 过滤器 & 转为CansetModel;
        NSArray *itemBrotherModels = [SMGUtils convertArr:brotherScenePorts convertBlock:^id(AIPort *item) {
            //a1. 过滤brother不含截点的 (参考29069-todo5.6);
            NSDictionary *indexDic = [fatherFo getConIndexDic:item.target_p];
            NSNumber *brotherCutIndex = [indexDic objectForKey:@(fatherModel.cutIndex)];
            if (!brotherCutIndex) return nil;
            
            //a2. 过滤无同区mv指向的 (参考29069-todo4);
            AIFoNodeBase *fo = [SMGUtils searchNode:item.target_p];
            if (![fatherFo.cmvNode_p.identifier isEqualToString:fo.cmvNode_p.identifier]) return nil;
            
            //a3. 将brother生成模型;
            return [AISceneModel newWithBase:fatherModel type:SceneTypeBrother scene:item.target_p cutIndex:brotherCutIndex.integerValue];
        }];
        [brotherModels addObjectsFromArray:itemBrotherModels];
    }
    
    //5. 将三级全收集返回;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObjectsFromArray:iModels];
    [result addObjectsFromArray:fatherModels];
    [result addObjectsFromArray:brotherModels];
    return result;
}

@end
