//
//  TCRealact.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/17.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "TCRealact.h"

@implementation TCRealact

/**
 *  MARK:--------------------懒加载真正跑行为化的actionFo--------------------
 *  @title 判断包含空概念时,取用具象一级的canset (过滤掉具象也含空概念的部分) (参考29069-todo8);
 *  @param foModel : 传入TCSolution最佳方案形成的TOFoModel模型;
 *  @desc 当前content_p含空概念时,此方法负责向它的具象取出不含空概念的一条,进行行为化;
 *      1. 要求: 取具象也要符合它在overrideCansets中 (取交集);
 *      2. 防空: 取具象不能再含空概念了;
 *      3. 竞争: 取具象先取强度最强的一条;
 */
+(AIKVPointer*) getRealactFo:(TOFoModel*)foModel {
    //TODOTOMORROW20230417:
    //矛盾: iCanset如果是迁移来的,它没有具象指向...而此处需要具象指向;
    //问题: 是先迁移后realact,还是先realact再迁移?
    
    
    
    
    if (foModel.baseSceneModel) {
        //1. 判断包含空概念;
        AIFoNodeBase *contentFo = [SMGUtils searchNode:foModel.content_p];
        if ([AINetUtils foHasEmptyAlg:foModel.content_p]) {
            
            //2. 取具象一级cansets (用空概念经验的具象,与当前场景的overrideCansets取交集得出);
            NSArray *conCansets = Ports2Pits([AINetUtils conPorts_All:contentFo]);
            NSArray *overrideCansets = [TCCanset getOverrideCansets:foModel.baseSceneModel];
            NSArray *filter = [SMGUtils filterArr:conCansets checkValid:^BOOL(AIKVPointer *item) {
                return [overrideCansets containsObject:item];
            }];
            
            //3. 取出不含空概念的 & 强度最强的 => 作为行为化actionFo;
            AIKVPointer *firstStrongFo_p = [SMGUtils filterSingleFromArr:filter checkValid:^BOOL(AIKVPointer *item) {
                return ![AINetUtils foHasEmptyAlg:item];
            }];
            return firstStrongFo_p;
        }
        //2. 不包含时,则直接使用content_p;
        return foModel.iCanset;
    } else {
        //3. 非场景时,默认对content_p进行行为化即可;
        return foModel.content_p;
    }
}

@end
