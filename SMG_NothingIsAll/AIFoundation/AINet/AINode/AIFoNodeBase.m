//
//  AIFoNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIFoNodeBase.h"

@implementation AIFoNodeBase

-(NSMutableArray *)deltaTimes{
    if (!_deltaTimes) _deltaTimes = [[NSMutableArray alloc] init];
    return _deltaTimes;
}

-(NSMutableDictionary *)spDic{
    if (!ISOK(_spDic, NSMutableDictionary.class)) _spDic = [[NSMutableDictionary alloc] initWithDictionary:_spDic];
    return _spDic;
}

-(NSMutableDictionary *)effectDic{
    if (!ISOK(_effectDic, NSMutableDictionary.class)) _effectDic = [[NSMutableDictionary alloc] initWithDictionary:_effectDic];
    return _effectDic;
}

-(NSMutableDictionary *)absIndexDDic{
    if (!ISOK(_absIndexDDic, NSMutableDictionary.class)) _absIndexDDic = [[NSMutableDictionary alloc] initWithDictionary:_absIndexDDic];
    return _absIndexDDic;
}

-(NSMutableDictionary *)conIndexDDic{
    if (!ISOK(_conIndexDDic, NSMutableDictionary.class)) _conIndexDDic = [[NSMutableDictionary alloc] initWithDictionary:_conIndexDDic];
    return _conIndexDDic;
}

-(NSMutableDictionary *)conCansetsDic {
    if (!ISOK(_conCansetsDic, NSMutableDictionary.class)) _conCansetsDic = [[NSMutableDictionary alloc] initWithDictionary:_conCansetsDic];
    return _conCansetsDic;
}

//MARK:===============================================================
//MARK:                     < spDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新SP强度值--------------------
 *  @param spIndex : 当前要更新sp强度值的下标 (参考25031-3);
 *                    1. 表示责任帧下标,比如为1时,则表示第2帧的责任;
 *                    2. 如果是mv则输入content.count;
 */
-(void) updateSPStrong:(NSInteger)spIndex type:(AnalogyType)type{
    //1. 取kv;
    NSNumber *key = @(spIndex);
    AISPStrong *value = [self.spDic objectForKey:key];
    if (!value) value = [[AISPStrong alloc] init];
    
    //2. 更新强度_线性+1 (参考25031-7);
    if (type == ATSub) {
        value.sStrong++;
    }else if(type == ATPlus){
        value.pStrong++;
    }
    [self.spDic setObject:value forKey:key];
    
    //3. 保存fo
    [SMGUtils insertNode:self];
}

//MARK:===============================================================
//MARK:                     < effectDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新有效率值--------------------
 */
-(void) updateEffectStrong:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo status:(EffectStatus)status{
    //1. 取kv (无则新建);
    NSNumber *key = @(effectIndex);
    NSMutableArray *value = [[NSMutableArray alloc] initWithArray:[self.effectDic objectForKey:key]];
    [self.effectDic setObject:value forKey:key];
    
    //2. 取旧有strong (无则新建);
    AIEffectStrong *strong = [SMGUtils filterSingleFromArr:value checkValid:^BOOL(AIEffectStrong *item) {
        return [item.solutionFo isEqual:solutionFo];
    }];
    if (!strong) {
        strong = [AIEffectStrong newWithSolutionFo:solutionFo];
        [value addObject:strong];
    }
    
    //3. 更新强度_线性+1 (参考25031-7);
    if (status == ES_NoEff) {
        strong.nStrong++;
    }else if(status == ES_HavEff){
        strong.hStrong++;
    }
    
    //3. 保存fo
    [SMGUtils insertNode:self];
}

/**
 *  MARK:--------------------取effIndex下有效的Effs--------------------
 *  @result 返回有效结果: 排除有效率为0的 (参考26192);
 */
-(NSArray*) getValidEffs:(NSInteger)effIndex{
    int minHStrong = 0;//最小h强度要求 (曾用5: 参考26199-TODO2);
    NSArray *effs = [self.effectDic objectForKey:@(effIndex)];
    return [SMGUtils filterArr:effs checkValid:^BOOL(AIEffectStrong *item) {
        return item.hStrong > minHStrong;
    }];
}

//MARK:===============================================================
//MARK:                     < indexDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------返回self的抽/具象的indexDic--------------------
 *  @result indexDic<K:absIndex,V:conIndex>;
 */
-(NSDictionary*) getAbsIndexDic:(AIKVPointer*)abs_p {
    return DICTOOK([self.absIndexDDic objectForKey:@(abs_p.pointerId)]);
}

-(NSDictionary*) getConIndexDic:(AIKVPointer*)con_p {
    return DICTOOK([self.conIndexDDic objectForKey:@(con_p.pointerId)]);
}

/**
 *  MARK:--------------------更新抽具象indexDic存储--------------------
 *  @param absFo : 传抽象节点进来,而self为具象节点;
 *  @version
 *      2022.11.15: 将抽具象关系也存上匹配映射 (参考27177-todo5);
 */
-(void) updateIndexDic:(AIFoNodeBase*)absFo indexDic:(NSDictionary*)indexDic {
    //1. 更新抽具象两个indexDDic;
    [self.absIndexDDic setObject:indexDic forKey:@(absFo.pointer.pointerId)];
    [absFo.conIndexDDic setObject:indexDic forKey:@(self.pointer.pointerId)];
    
    //2. 保存节点;
    [SMGUtils insertNode:self];
    [SMGUtils insertNode:absFo];
}

//MARK:===============================================================
//MARK:                     < conCansets组 >
//MARK:===============================================================

/**
 *  MARK:--------------------获取所有候选集--------------------
 *  @desc 将>=targetIndex下标对应的解决方案候选集打包返回;
 *  @result notnull
 */
-(NSArray*) getConCansets:(NSInteger)targetIndex {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger i = targetIndex; i <= self.count; i++) {
        [result addObjectsFromArray:[self.conCansetsDic objectForKey:@(i)]];
    }
    result = [SMGUtils removeRepeat:result];
    return result;
}

/**
 *  MARK:--------------------更新一条候选--------------------
 */
-(void) updateConCanset:(AIKVPointer*)newConCansetFo targetIndex:(NSInteger)targetIndex {
    NSMutableArray *conCansets = [[NSMutableArray alloc] initWithArray:[self.conCansetsDic objectForKey:@(targetIndex)]];
    if (![conCansets containsObject:newConCansetFo]) {
        [conCansets addObject:newConCansetFo];
        [self.conCansetsDic setObject:conCansets forKey:@(targetIndex)];
        [SMGUtils insertNode:self];
    }
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.cmvNode_p = [aDecoder decodeObjectForKey:@"cmvNode_p"];
        self.deltaTimes = [aDecoder decodeObjectForKey:@"deltaTimes"];
        self.mvDeltaTime = [aDecoder decodeDoubleForKey:@"mvDeltaTime"];
        self.spDic = [aDecoder decodeObjectForKey:@"spDic"];
        self.effectDic = [aDecoder decodeObjectForKey:@"effectDic"];
        self.absIndexDDic = [aDecoder decodeObjectForKey:@"absIndexDDic"];
        self.conIndexDDic = [aDecoder decodeObjectForKey:@"conIndexDDic"];
        self.conCansetsDic = [aDecoder decodeObjectForKey:@"conCansetsDic"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cmvNode_p forKey:@"cmvNode_p"];
    [aCoder encodeObject:self.deltaTimes forKey:@"deltaTimes"];
    [aCoder encodeDouble:self.mvDeltaTime forKey:@"mvDeltaTime"];
    [aCoder encodeObject:[self.spDic copy] forKey:@"spDic"];
    [aCoder encodeObject:[self.effectDic copy] forKey:@"effectDic"];
    [aCoder encodeObject:[self.absIndexDDic copy] forKey:@"absIndexDDic"];
    [aCoder encodeObject:[self.conIndexDDic copy] forKey:@"conIndexDDic"];
    [aCoder encodeObject:[self.conCansetsDic copy] forKey:@"conCansetsDic"];
}

@end
