//
//  AICansetModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/11.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AICansetModel.h"

@implementation AICansetModel

+(AICansetModel*) newWithBase:(AICansetModel*)base type:(CansetType)type scene:(AIKVPointer*)scene {
    AICansetModel *result = [[AICansetModel alloc] init];
    result.type = type;
    if (base) [base.subs addObject:result];
    
    
    
    return result;
}

/**
 *  MARK:--------------------overrideCansets算法 (参考29069-todo5)--------------------
 *  @desc 当前下面挂载的且有效的cansets: (当前cansets - 用优先级更高一级cansets);
 */
-(NSArray*) overrideCansets {
    //1. 数据准备;
    AIFoNodeBase *selfFo = [SMGUtils searchNode:self.scene];
    AIFoNodeBase *baseFo = self.base ? [SMGUtils searchNode:self.base.scene] : nil;
    NSArray *selfConCansets = [selfFo getConCansets:selfFo.count];
    NSArray *baseConCansets = [baseFo getConCansets:baseFo.count];
    if (self.type == CansetTypeBrother) {
        //2. 当前是brother时: (brother有效canset = brother.conCansets - father.conCansets) (参考29069-todo5.3);
        NSArray *brotherConCansets = selfConCansets;
        NSArray *fatherConCansets = baseConCansets;
        
        //TODOTOMORROW20230412: 继续写完这里的mIsC过滤... (参考29069-todo5.2);
        
        
        
    } else if (self.type == CansetTypeFather) {
        //3. 当前是father时: (father有效canset = father.conCansets - i.conCansets) (参考29069-todo5.4);
        NSArray *fatherConCansets = selfConCansets;
        NSArray *iConCansets = baseConCansets;
        
    } else if (self.type == CansetTypeFather) {
        //4. 当前是i时: (i有效canset = i.conCansets) (参考29069-todo5.5);
        NSArray *iConCansets = selfConCansets;
        return iConCansets;
    }
    return nil;
}

@end
