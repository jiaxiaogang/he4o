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
-(NSDictionary*) getIndexDic:(AIKVPointer*)other_p isAbs:(BOOL)isAbs {
    NSMutableDictionary *indexDDic = isAbs ? self.absIndexDDic : self.conIndexDDic;
    return DICTOOK([indexDDic objectForKey:@(other_p.pointerId)]);
}

/**
 *  MARK:--------------------获取cutIndex--------------------
 *  @title 根据indexDic取得截点cutIndex (参考27177-todo2);
 *  @desc
 *      1. 已发生截点 (含cutIndex已发生,所以cutIndex应该就是proto末位在assFo中匹配到的assIndex下标);
 *      2. 取用方式1: 取最大的key即是cutIndex (目前选用,因为它省得取出conFo);
 *      3. 取用方式2: 取protoFo末位为value,对应的key即为:cutIndex;
 *  @result 返回截点cutIndex (注: 此处永远返回抽象Fo的截点,因为具象在时序识别中没截点);
 */
-(NSInteger) getCutIndexByIndexDic:(AIKVPointer*)other_p isAbs:(BOOL)isAbs{
    //1. 取indexDic;
    NSInteger result = -1;
    NSDictionary *indexDic = [self getIndexDic:other_p isAbs:isAbs];
    
    //2. 取最大的key,即为cutIndex;
    for (NSNumber *absIndex in indexDic.allKeys) {
        if (result < absIndex.integerValue) result = absIndex.integerValue;
    }
    return result;
}

/**
 *  MARK:--------------------获取near数据--------------------
 *  @desc 根据indexDic取得nearCount&sumNear (参考27177-todo3);
 *  _result 目前未返回结果,等到调用者使用时,再来写返回方式;
 */
-(void) getNearCountAndSumNearByIndexDic:(AIKVPointer*)other_p isAbs:(BOOL)isAbs {
    //1. 数据准备;
    int nearCount = 0;  //总相近数 (匹配值<1)
    CGFloat sumNear = 0;//总相近度
    AIFoNodeBase *otherFo = [SMGUtils searchNode:other_p];
    AIFoNodeBase *absFo = isAbs ? otherFo : self;
    AIFoNodeBase *conFo = isAbs ? self : otherFo;
    NSDictionary *indexDic = [self getIndexDic:other_p isAbs:isAbs];
    
    //2. 逐个统计;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        NSInteger conIndex = NUMTOOK([indexDic objectForKey:key]).integerValue;
        AIKVPointer *absA_p = ARR_INDEX(absFo.content_ps, absIndex);
        AIKVPointer *conA_p = ARR_INDEX(conFo.content_ps, conIndex);
        
        //3. 复用取near值;
        CGFloat near = 0;
        if (isAbs) {
            //4. 当前是具象时_从具象取复用;
            AIAlgNodeBase *conA = [SMGUtils searchNode:conA_p];
            near = [conA getAbsMatchValue:absA_p];
        }else{
            //5. 当前是抽象时_从抽象取复用;
            AIAlgNodeBase *absA = [SMGUtils searchNode:absA_p];
            near = [absA getConMatchValue:conA_p];
        }
        
        //6. 二者一样时,直接=1;
        if ([absA_p isEqual:conA_p]) near = 1;
        
        //7. 只记录near<1的 (取<1的原因未知,参考2619j-todo5);
        if (near < 1) {
            [AITest test14:near];
            sumNear += near;
            nearCount++;
        }
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
}

@end
