//
//  ShortMatchManager.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "ShortMatchManager.h"
#import "AIShortMatchModel.h"
#import "AIAlgNodeBase.h"
#import "AIShortMatchModel_Simple.h"

@interface ShortMatchManager ()

@property (strong, nonatomic) NSMutableArray *models;

@end

@implementation ShortMatchManager

-(NSMutableArray*)models{
    if (_models == nil) _models = [[NSMutableArray alloc] init];
    return _models;
}
-(void) add:(AIShortMatchModel*)model{
    if (model) [self.models addObject:model];
    if (self.models.count > cShortMemoryLimit)
        self.models = [[NSMutableArray alloc] initWithArray:ARR_SUB(self.models, self.models.count - cShortMemoryLimit, cShortMemoryLimit)];
}

/**
 *  MARK:--------------------获取瞬时记忆序列--------------------
 *  @param isMatch
 *      true : matchAlgs返回以后逐步替代shortCache;
 *      false: protoAlgs(由algsDic生成的algNode_p)返回;
 *  @desc 存最多4条algNode_p;
 *  @version
 *      2019.01.23: 将protoAlg收集到瞬时记忆中;
 *      xxxx.xx.xx: 输入概念识别成功时,加入matchAlg;
 *      2020.06.26: 识别失败时,将protoAlg加入 (以避免,飞行行为因不被识别而无法加入的BUG);
 *      2020.08.17: 将瞬时记忆整合到短时记忆中;
 *  @result 返回AIShortMatchModel_Simple数组 notnull;
 */
-(NSMutableArray*) shortCache:(BOOL)isMatch{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (AIShortMatchModel *mModel in self.models) {
        //2. 逐个取 (取M且有效时返回M,否则返回P);
        AIKVPointer *itemAlg_p = (isMatch && mModel.matchAlg) ? mModel.matchAlg.pointer : mModel.protoAlg.pointer;
        
        //3. 有效则收集;
        if (itemAlg_p) {
            AIShortMatchModel_Simple *simple = [[AIShortMatchModel_Simple alloc] init];
            simple.alg_p = itemAlg_p;
            simple.inputTime = mModel.inputTime;
        }
    }
    return result;
}

@end
