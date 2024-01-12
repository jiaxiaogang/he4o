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

@end
