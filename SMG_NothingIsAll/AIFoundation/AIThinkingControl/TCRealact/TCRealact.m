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
 *  MARK:--------------------TCSolution最佳输出的可行性检查--------------------
 *  @title 判断包含空概念时,取用具象一级的canset (过滤掉具象也含空概念的部分) (参考29069-todo8);
 *  @desc 将最佳输出含空概念时,转成具象一层的另一个TCCansetModel;
 *  @desc 当前bestResult含空概念时,此方法负责拦截,并向它的具象取出不含空概念的一条,做为TCSolutionUtil的最佳输出;
 *      1. 要求: 取具象也要符合它在protoCansets中 (因为本来就是拿protoCansets中的另一个来替换);
 *      2. 防空: 取具象不能再含空概念了;
 *      3. 竞争: 取protoModels中符合条件的首条;
 *  @desc 模块调用位置说明:
 *      1. 因为替换后的actionIndex和targetIndex等都需要用,所以这个代码写在TCSolutionUtil输出最佳S之前调用;
 *  @param bestResult : 传入TCSolutionUtil最佳方案bestResult模型;
 *  @param fromCansets : 传入TCSolutionUtil输出最佳result时,result所在的全集sortModels数组;
 *  @result 如有必要,将替换可行后的新bestResult返回;
 */
+(TOFoModel*) checkRealactAndReplaceIfNeed:(TOFoModel*)bestResult fromCansets:(NSArray*)fromCansets {
    if (bestResult.baseSceneModel) {
        //1. 判断包含空概念;
        if ([AINetUtils foHasEmptyAlg:bestResult.cansetFo]) {
            
            //2. 取具象一级cansets (用空概念经验的具象,与当前场景的overrideCansets取交集得出);
            AIFoNodeBase *bestCansetFo = [SMGUtils searchNode:bestResult.cansetFo];
            NSArray *conCansets = Ports2Pits([AINetUtils conPorts_All:bestCansetFo]);
            return [SMGUtils filterSingleFromArr:fromCansets checkValid:^BOOL(TOFoModel *item) {
                //a. 过滤掉非best具象的;
                if (![conCansets containsObject:item.cansetFo]) return false;
                
                //b. 过滤掉具象亦含空概念的;
                if ([AINetUtils foHasEmptyAlg:item.cansetFo]) return false;
                
                //c. 闯关成功,返回这条;
                return true;
            }];
        }
        //2. 不含空概念时,不替换;
        return bestResult;
    } else {
        //3. 非场景时,不替换;
        return bestResult;
    }
}

@end
