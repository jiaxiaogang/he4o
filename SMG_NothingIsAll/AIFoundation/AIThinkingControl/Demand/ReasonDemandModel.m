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
+(ReasonDemandModel*) newWithAlgsType:(NSString*)algsType pFos:(NSArray*)pFos inModel:(AIShortMatchModel*)inModel baseFo:(TOFoModel*)baseFo{
    //1. 数据准备;
    ReasonDemandModel *result = [[ReasonDemandModel alloc] init];
    AIMatchFoModel *firstPFo = ARR_INDEX(pFos, 0);
    AIFoNodeBase *matchFo = [SMGUtils searchNode:firstPFo.matchFo];
    AICMVNodeBase *mvNode = [SMGUtils searchNode:matchFo.cmvNode_p];
    NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
    urgentTo = (int)(urgentTo * firstPFo.matchFoValue);
    
    //2. 短时结构;
    if (baseFo) [baseFo.subDemands addObject:result];
    result.baseOrGroup = baseFo;
    
    //3. 属性赋值;
    result.algsType = algsType;
    result.delta = delta;
    result.urgentTo = urgentTo;
    result.pFos = pFos;
    result.fromIden = STRFORMAT(@"%p",inModel);
    return result;
}

/**
 *  MARK:--------------------获取任务迫切度 (用于排序)--------------------
 */
-(CGFloat) demandUrgentTo{
    return self.urgentTo * self.mModel.matchFoValue;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.mModel = [aDecoder decodeObjectForKey:@"mModel"];
        self.fromIden = [aDecoder decodeObjectForKey:@"fromIden"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.mModel forKey:@"mModel"];
    [aCoder encodeObject:self.fromIden forKey:@"fromIden"];
}

@end
