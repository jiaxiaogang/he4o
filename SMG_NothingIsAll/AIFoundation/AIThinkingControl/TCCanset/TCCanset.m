//
//  TCCanset.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "TCCanset.h"

@implementation TCCanset

/**
 *  MARK:--------------------overrideCansets算法 (参考29069-todo5)--------------------
 *  @desc 当前下面挂载的且有效的cansets: (当前cansets - 用优先级更高一级cansets);
 *  @version
 *      2023.04.23: BUG_修复差集取成了交集,导致总返回0条;
 */
+(NSArray*) getOverrideCansets:(AISceneModel*)sceneModel {
    //1. 数据准备;
    AIFoNodeBase *selfFo = [SMGUtils searchNode:sceneModel.scene];
    
    //2. 不同type的公式不同 (参考29069-todo5.3 & 5.4 & 5.5);
    if (sceneModel.type == SceneTypeBrother) {
        //3. 当前是brother时: (brother有效canset = brother.conCansets - father.conCansets) (参考29069-todo5.3);
        NSArray *brotherConCansets = [selfFo getConCansets:selfFo.count];
        NSArray *fatherFilter_ps = [TCCanset getFilter_ps:sceneModel];
        if (fatherFilter_ps.count > 0 && brotherConCansets.count > 0) {
            NSLog(@"测下override过滤生效");
        }
        return [SMGUtils removeSub_ps:fatherFilter_ps parent_ps:brotherConCansets];
    } else if (sceneModel.type == SceneTypeFather) {
        //4. 当前是father时: (father有效canset = father.conCansets - i.conCansets) (参考29069-todo5.4);
        NSArray *fatherConCansets = [selfFo getConCansets:selfFo.count];
        NSArray *iFilter_ps = [TCCanset getFilter_ps:sceneModel];
        if (iFilter_ps.count > 0 && fatherConCansets.count > 0) {
            NSLog(@"测下override过滤生效");
        }
        return [SMGUtils removeSub_ps:iFilter_ps parent_ps:fatherConCansets];
    } else if (sceneModel.type == SceneTypeI) {
        //4. 当前是i时: (i有效canset = i.conCansets) (参考29069-todo5.5);
        NSArray *iConCansets = [selfFo getConCansets:selfFo.count];
        return iConCansets;
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------获取override用来过滤的部分 (参考29069-todo5.2)--------------------
 *  @desc 取father过滤部分 (用于mIsC过滤) (参考29069-todo5.1);
 *  @version
 *      2023.04.23: BUG_修复抽具象关联取不到过滤结果,改为用迁移关联取 (参考29074);
 */
+(NSArray*) getFilter_ps:(AISceneModel*)sceneModel {
    //1. brother时: 取father及其具象 => 作为过滤部分 (参考29069-todo5.3-公式减数);
    if (sceneModel.type == SceneTypeBrother) {
        //2. 从fatherScene中找出与当前scene有迁移关联的cansets并返回 (参考29069-todo5.3 & 29074);
        AIFoNodeBase *fatherFo = [SMGUtils searchNode:sceneModel.base.scene];
        return [fatherFo getTransferConCansets:sceneModel.scene];
    }
    //3. father时: 取i及其抽象 => 作为过滤部分 (参考29069-todo5.4-公式减数);
    else if (sceneModel.type == SceneTypeFather) {
        //4. 从iScene中找出与当前scene有迁移关联的cansets并返回 (参考29069-todo5.4 & 29074);
        AIFoNodeBase *iFo = [SMGUtils searchNode:sceneModel.base.scene];
        return [iFo getTransferAbsCansets:sceneModel.scene];
    }
    return nil;
}

@end
