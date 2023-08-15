//
//  ReasonDemandModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/21.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "ReasonDemandModel.h"

@implementation ReasonDemandModel

/**
 *  MARK:--------------------newWith--------------------
 *  @version
 *      2021.03.28: 将at & delta & urgentTo也封装到此处取赋值;
 *      2021.06.01: 将子任务时的base也兼容入baseOrGroup中 (参考23094);
 */
+(ReasonDemandModel*) newWithAlgsType:(NSString*)algsType pFos:(NSArray*)pFos shortModel:(AIShortMatchModel*)shortModel baseFo:(TOFoModel*)baseFo protoFo:(AIFoNodeBase*)protoFo{
    //1. 数据准备;
    ReasonDemandModel *result = [[ReasonDemandModel alloc] init];
    AIMatchFoModel *firstPFo = ARR_INDEX(pFos, 0);
    AIFoNodeBase *matchFo = [SMGUtils searchNode:firstPFo.matchFo];
    AICMVNodeBase *mvNode = [SMGUtils searchNode:matchFo.cmvNode_p];
    NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
    urgentTo = (int)(urgentTo * (firstPFo.cutIndex + 1));
    
    //2. 短时结构;
    if (baseFo) [baseFo.subDemands addObject:result];
    result.baseOrGroup = baseFo;
    
    //3. 属性赋值;
    result.algsType = algsType;
    result.delta = delta;
    result.urgentTo = urgentTo;
    result.pFos = pFos;
    result.fromIden = STRFORMAT(@"%p",shortModel);
    result.protoFo = protoFo.pointer;
    result.regroupFo = shortModel.regroupFo.pointer;
    
    //4. pFos赋值baseRDemand;
    for (AIMatchFoModel *pFo in pFos) {
        pFo.baseRDemand = result;
    }
    return result;
}

/**
 *  MARK:--------------------任务的pFos--------------------
 *  @desc 默认返回未失效的pFos任务 (也可以考虑改成失效时,直接移除失效的pFo) (参考27095-10);
 */
-(NSArray*) validPFos {
    return [SMGUtils filterArr:_pFos checkValid:^BOOL(AIMatchFoModel *item) {
        return !item.isExpired;
    }];
}

-(AIKVPointer*) protoOrRegroupFo {
    if (self.protoFo) return self.protoFo;
    return self.regroupFo;
}

/**
 *  MARK:--------------------任务是否失效--------------------
 *  @desc : 当R任务的pFos全失效时,则R任务也失效 (参考27123-问题2-todo1);
 */
-(BOOL) isExpired {
    return !ARRISOK(self.validPFos);
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.pFos = [aDecoder decodeObjectForKey:@"pFos"];
        self.fromIden = [aDecoder decodeObjectForKey:@"fromIden"];
        self.protoFo = [aDecoder decodeObjectForKey:@"protoFo"];
        self.regroupFo = [aDecoder decodeObjectForKey:@"regroupFo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.pFos forKey:@"pFos"];
    [aCoder encodeObject:self.fromIden forKey:@"fromIden"];
    [aCoder encodeObject:self.protoFo forKey:@"protoFo"];
    [aCoder encodeObject:self.regroupFo forKey:@"regroupFo"];
}

@end
