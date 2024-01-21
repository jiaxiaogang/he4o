//
//  AICansetModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/27.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AICansetModel.h"

@implementation AICansetModel

+(AICansetModel*) newWithCansetFo:(AIKVPointer*)cansetFo
                            sceneFo:(AIKVPointer*)sceneFo
                 protoFrontIndexDic:(NSDictionary *)protoFrontIndexDic
                 matchFrontIndexDic:(NSDictionary *)matchFrontIndexDic
                    frontMatchValue:(CGFloat)frontMatchValue
                   frontStrongValue:(CGFloat)frontStrongValue
                     midEffectScore:(CGFloat)midEffectScore
                     midStableScore:(CGFloat)midStableScore
                       backIndexDic:(NSDictionary*)backIndexDic
                     backMatchValue:(CGFloat)backMatchValue
                    backStrongValue:(CGFloat)backStrongValue
                           cutIndex:(NSInteger)cutIndex
                      sceneCutIndex:(NSInteger)sceneCutIndex
                        targetIndex:(NSInteger)targetIndex
                   sceneTargetIndex:(NSInteger)sceneTargetIndex
             basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel
                     baseSceneModel:(AISceneModel*)baseSceneModel {
    AICansetModel *model = [[AICansetModel alloc] init];
    model.cansetFo = cansetFo;
    model.sceneFo = sceneFo;
    model.basePFoOrTargetFoModel = basePFoOrTargetFoModel;
    model.baseSceneModel = baseSceneModel;
    model.protoFrontIndexDic = protoFrontIndexDic;
    model.matchFrontIndexDic = matchFrontIndexDic;
    model.frontMatchValue = frontMatchValue;
    model.frontStrongValue = frontStrongValue;
    model.midEffectScore = midEffectScore;
    model.midStableScore = midStableScore;
    model.backMatchValue = backMatchValue;
    model.backStrongValue = backStrongValue;
    model.cutIndex = cutIndex;
    model.targetIndex = targetIndex;
    model.sceneTargetIndex = sceneTargetIndex;
    return model;
}

//在TCTransfer中暂时不用这个,现在直接取base.base...在取用;
//-(AIKVPointer*) getIScene {
//    if (self.baseSceneModel.type == SceneTypeI) {
//        return self.sceneFo;
//    } else if (self.baseSceneModel.type == SceneTypeFather) {
//        return self.baseSceneModel.base.scene;
//    } else if (self.baseSceneModel.type == SceneTypeBrother) {
//        return self.baseSceneModel.base.base.scene;
//    }
//    return nil;
//}
//
//-(AIKVPointer*) getFatherScene {
//    if (self.baseSceneModel.type == SceneTypeFather) {
//        return self.baseSceneModel.scene;
//    } else if (self.baseSceneModel.type == SceneTypeBrother) {
//        return self.baseSceneModel.base.scene;
//    }
//    return nil;
//}
//
//-(AIKVPointer*) getBrotherScene {
//    if (self.baseSceneModel.type == SceneTypeBrother) {
//        return self.baseSceneModel.scene;
//    }
//    return nil;
//}

/**
 *  MARK:--------------------feedbackTOR有反馈,看是否对这个CansetModel有效 (参考31073-TODO2)--------------------
 */
-(void) check4FeedbackTOR:(NSArray*)feedbackMatchAlg_ps {
    //1. 未达到targetIndex才接受反馈;
    if (self.cutIndex >= self.targetIndex) return;
    feedbackMatchAlg_ps = ARRTOOK(feedbackMatchAlg_ps);
    
    //2. 判断反馈mIsC是否有效;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:self.cansetFo];
    AIKVPointer *cansetWaitAlg_p = ARR_INDEX(cansetFo.content_ps, self.cutIndex + 1);
    BOOL mIsC = [feedbackMatchAlg_ps containsObject:cansetWaitAlg_p];
    if (!mIsC) return;
    
    //TODOTOMORROW20240121:
    //3. 有效时,推进cutIndex+1等;
    //1. 为了方便记录feedbackAlg等,明天可以考虑把CansetModel转成TOFoModel;
    //2. 但为了不触发:由用转体,需要处理一下TOFoModel里的iCanset看怎么弄比较好;
    //3. 说白了,CansetModel,TOFoModel有它们的共同点,与不同阶段: 是否已转体 只是一个进化阶段;
    //4. 看把CansetModel和TOFoModel写成继承和具象类关系...什么的,
    //5. 即CansetModel在初始化时,就构建到actionFos中,有baseGroupOrDemand的指向什么的;
}

@end
