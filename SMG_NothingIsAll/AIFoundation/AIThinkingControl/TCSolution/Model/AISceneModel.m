//
//  AISceneModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/11.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AISceneModel.h"

@implementation AISceneModel

+(AISceneModel*) newWithBase:(AISceneModel*)base type:(CansetType)type scene:(AIKVPointer*)scene cutIndex:(NSInteger)cutIndex {
    AISceneModel *result = [[AISceneModel alloc] init];
    result.type = type;
    if (base) [base.subs addObject:result];
    result.scene = scene;
    result.cutIndex = cutIndex;
    return result;
}

/**
 *  MARK:--------------------overrideCansets算法 (参考29069-todo5)--------------------
 *  @desc 当前下面挂载的且有效的cansets: (当前cansets - 用优先级更高一级cansets);
 */
-(NSArray*) overrideCansets {
    //1. 数据准备;
    AIFoNodeBase *selfFo = [SMGUtils searchNode:self.scene];
    
    //2. 不同type的公式不同 (参考29069-todo5.3 & 5.4 & 5.5);
    if (self.type == CansetTypeBrother) {
        //3. 当前是brother时: (brother有效canset = brother.conCansets - father.conCansets) (参考29069-todo5.3);
        NSArray *brotherConCansets = [selfFo getConCansets:selfFo.count];
        NSArray *fatherFilter_ps = [self getFilter_ps];
        return [SMGUtils filterSame_ps:fatherFilter_ps parent_ps:brotherConCansets];
    } else if (self.type == CansetTypeFather) {
        //4. 当前是father时: (father有效canset = father.conCansets - i.conCansets) (参考29069-todo5.4);
        NSArray *fatherConCansets = [selfFo getConCansets:selfFo.count];
        NSArray *iFilter_ps = [self getFilter_ps];
        return [SMGUtils filterSame_ps:iFilter_ps parent_ps:fatherConCansets];
    } else if (self.type == CansetTypeI) {
        //4. 当前是i时: (i有效canset = i.conCansets) (参考29069-todo5.5);
        NSArray *iConCansets = [selfFo getConCansets:selfFo.count];
        return iConCansets;
    }
    return nil;
}

-(AISceneModel*) getRoot {
    if (self.type == CansetTypeI) {
        return self;
    }
    return [self.base getRoot];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------获取override用来过滤的部分 (参考29069-todo5.2)--------------------
 *  @desc 取father过滤部分 (用于mIsC过滤) (参考29069-todo5.1);
 */
-(NSArray*) getFilter_ps {
    //1. brother时: 取father及其具象 => 作为过滤部分 (参考29069-todo5.3-公式减数);
    if (self.type == CansetTypeBrother) {
        //2. 取到father的conCansets;
        AIFoNodeBase *fatherFo = [SMGUtils searchNode:self.base.scene];
        NSArray *fatherConCansets = [fatherFo getConCansets:fatherFo.count];
        
        //3. 将filter_ps收集并返回 (参考29069-todo5.3);
        NSMutableArray *allFilter_ps = [[NSMutableArray alloc] initWithArray:fatherConCansets];
        [allFilter_ps addObjectsFromArray:[SMGUtils convertArr:fatherConCansets convertItemArrBlock:^NSArray *(AIKVPointer *obj) {
            AIFoNodeBase *fatherConConset = [SMGUtils searchNode:obj];
            return Ports2Pits([AINetUtils conPorts_All:fatherConConset]);
        }]];
        return allFilter_ps;
    }
    //4. father时: 取i及其抽象 => 作为过滤部分 (参考29069-todo5.4-公式减数);
    else if (self.type == CansetTypeFather) {
        //5. 取到i的conCansets;
        AIFoNodeBase *iFo = [SMGUtils searchNode:self.base.scene];
        NSArray *iConCansets = [iFo getConCansets:iFo.count];
        
        //6. 将filter_ps收集并返回 (参考29069-todo5.4);
        NSMutableArray *allFilter_ps = [[NSMutableArray alloc] initWithArray:iConCansets];
        [allFilter_ps addObjectsFromArray:[SMGUtils convertArr:iConCansets convertItemArrBlock:^NSArray *(AIKVPointer *obj) {
            AIFoNodeBase *iConConset = [SMGUtils searchNode:obj];
            return Ports2Pits([AINetUtils absPorts_All:iConConset]);
        }]];
        return allFilter_ps;
    }
    return nil;
}

@end
