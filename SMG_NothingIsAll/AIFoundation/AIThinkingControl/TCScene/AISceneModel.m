//
//  AISceneModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/11.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AISceneModel.h"

@implementation AISceneModel

+(AISceneModel*) newWithBase:(AISceneModel*)base type:(SceneType)type scene:(AIKVPointer*)scene cutIndex:(NSInteger)cutIndex {
    AISceneModel *result = [[AISceneModel alloc] init];
    result.type = type;
    if (base) [base.subs addObject:result];
    result.base = base;
    result.scene = scene;
    result.cutIndex = cutIndex;
    return result;
}

-(NSMutableArray *)subs {
    if (!_subs) _subs = [[NSMutableArray alloc] init];
    return _subs;
}

-(AISceneModel*) getRoot {
    if (self.type == SceneTypeI) {
        return self;
    }
    return [self.base getRoot];
}

-(BOOL) isEqual:(AISceneModel*)object{
    if (ISOK(object, AISceneModel.class)) return [self.scene isEqual:object.scene];
    return false;
}

//向base方向自动取fatherScene
-(AIKVPointer*) getFatherScene {
    AISceneModel *fatherSceneModel = [self getFatherSceneModel];
    if (fatherSceneModel) return fatherSceneModel.scene;
    return nil;
}
-(AISceneModel*) getFatherSceneModel {
    if (self.type == SceneTypeFather) {
        return self;
    } else if (self.type == SceneTypeBrother) {
        return self.base;
    }
    return nil;
}

//向base方向自动取brotherScene
-(AIKVPointer*) getBrotherScene {
    return (self.type == SceneTypeBrother) ? self.scene : nil;
}
-(AISceneModel*) getBrotherSceneModel {
    return (self.type == SceneTypeBrother) ? self : nil;
}

//向base方向自动取iScene
-(AIKVPointer*) getIScene {
    AISceneModel *iSceneModel = [self getISceneModel];
    if (iSceneModel) return iSceneModel.scene;
    return nil;
}
-(AISceneModel*) getISceneModel {
    if (self.type == SceneTypeI) {
        return self;
    } else if (self.type == SceneTypeFather) {
        return self.base;
    } else if (self.type == SceneTypeBrother) {
        return self.base.base;
    }
    return nil;
}

@end
