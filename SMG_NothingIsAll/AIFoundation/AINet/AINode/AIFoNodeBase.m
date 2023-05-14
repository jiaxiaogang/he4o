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

-(NSMutableArray *)transferAbsPorts{
    if (!ISOK(_transferAbsPorts, NSMutableArray.class)) _transferAbsPorts = [[NSMutableArray alloc] initWithArray:_transferAbsPorts];
    return _transferAbsPorts;
}

-(NSMutableArray *)transferConPorts{
    if (!ISOK(_transferConPorts, NSMutableArray.class)) _transferConPorts = [[NSMutableArray alloc] initWithArray:_transferConPorts];
    return _transferConPorts;
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
-(void) updateSPStrong:(NSInteger)spIndex type:(AnalogyType)type {
    [self updateSPStrong:spIndex difStrong:1 type:type];
}
-(void) updateSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type {
    //1. 取kv;
    NSNumber *key = @(spIndex);
    AISPStrong *value = [self.spDic objectForKey:key];
    if (!value) value = [[AISPStrong alloc] init];
    
    //2. 更新强度_线性+1 (参考25031-7);
    if (type == ATSub) {
        value.sStrong += difStrong;
    }else if(type == ATPlus){
        value.pStrong += difStrong;
    }
    [self.spDic setObject:value forKey:key];
    
    //3. 保存fo
    [SMGUtils insertNode:self];
}

/**
 *  MARK:--------------------从start到end都计一次P--------------------
 *  @desc 含start 也含end;
 */
-(void) updateSPStrong:(NSInteger)start end:(NSInteger)end type:(AnalogyType)type{
    for (NSInteger i = start; i <= end; i++) {
        [self updateSPStrong:i type:type];
    }
}

/**
 *  MARK:--------------------更新整个spDic--------------------
 */
-(void) updateSPDic:(NSDictionary*)spDic {
    [self.spDic setDictionary:spDic];
    [SMGUtils insertNode:self];
}

//MARK:===============================================================
//MARK:                     < effectDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新有效率值--------------------
 *  @version
 *      2022.05.27; 废弃,eff改成反省的一种了,所以不再需要effDic了 (参考26127-TODO1);
 *  @result 将更新后的strong模型返回;
 */
-(AIEffectStrong*) updateEffectStrong:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo status:(EffectStatus)status{
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
    return strong;
}

/**
 *  MARK:--------------------获取canset的effStrong--------------------
 *  @param effectIndex : 当R任务时传self.count,当H任务时将相应targetIndex传过来;
 */
-(AIEffectStrong*) getEffectStrong:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo {
    //1. 取有效率解决方案数组;
    NSArray *strongs = ARRTOOK([self.effectDic objectForKey:@(effectIndex)]);
    
    //2. 取得匹配的strong;
    AIEffectStrong *strong = [SMGUtils filterSingleFromArr:strongs checkValid:^BOOL(AIEffectStrong *item) {
        return [item.solutionFo isEqual:solutionFo];
    }];
    
    //3. 返回有效率;
    return strong;
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
 *  @desc 将>=targetIndex下标对应的解决方案候选集打包返回 (参考27204b);
 *  @result notnull
 */
-(NSArray*) getConCansets:(NSInteger)targetIndex {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger i = targetIndex; i <= self.count; i++) {
        [result addObjectsFromArray:[self.conCansetsDic objectForKey:@(i)]];
    }
    return [SMGUtils removeRepeat:result];
}

/**
 *  MARK:--------------------更新一条候选--------------------
 *  @result 将是否保存成功返回 (长度为1及以下的没后段,所以直接不存了) (参考28052-4 && 29094-BUG1);
 */
-(BOOL) updateConCanset:(AIKVPointer*)newConCansetFo targetIndex:(NSInteger)targetIndex {
    //0. canset没后段的直接不存了 (没可行为化的东西) (参考28052-4);
    AIFoNodeBase *newCanset = [SMGUtils searchNode:newConCansetFo];
    if (newCanset.count <= 1) return false;
    
    //1. 更新一条候选;
    NSMutableArray *conCansets = [[NSMutableArray alloc] initWithArray:[self.conCansetsDic objectForKey:@(targetIndex)]];
    if (![conCansets containsObject:newConCansetFo]) {
        [conCansets addObject:newConCansetFo];
        [self.conCansetsDic setObject:conCansets forKey:@(targetIndex)];
        [SMGUtils insertNode:self];
    }
    
    //2. 更新后 (新的默认eff=1,旧的eff则增强+1);
    [self updateEffectStrong:1 solutionFo:newConCansetFo status:ES_HavEff];
    return true;
}

//MARK:===============================================================
//MARK:                     < transfer组 >
//MARK:===============================================================

/**
 *  MARK:--------------------找出交层场景中,有哪些canset是与当前fo迁移关联的--------------------
 */
-(NSArray*) getTransferAbsCansets:(AIKVPointer*)absScene_p {
    return [self filterCansetsWithScene:absScene_p fromTransferPorts:self.transferAbsPorts];
}
/**
 *  MARK:--------------------找出似层场景中,有哪些canset是与当前fo迁移关联的--------------------
 */
-(NSArray*) getTransferConCansets:(AIKVPointer*)conScene_p {
    return [self filterCansetsWithScene:conScene_p fromTransferPorts:self.transferConPorts];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------从fromTransferPorts中筛选出: 场景是scene的并转成cansets格式--------------------
 */
-(NSArray*) filterCansetsWithScene:(AIKVPointer*)scene fromTransferPorts:(NSArray*)fromTransferPorts {
    return [SMGUtils convertArr:[SMGUtils filterArr:fromTransferPorts checkValid:^BOOL(AITransferPort *port) {
        return [port.scene isEqual:scene];
    }] convertBlock:^id(AITransferPort *port) {
        return port.canset;
    }];
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
        self.transferAbsPorts = [aDecoder decodeObjectForKey:@"transferAbsPorts"];
        self.transferConPorts = [aDecoder decodeObjectForKey:@"transferConPorts"];
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
    [aCoder encodeObject:[self.transferAbsPorts copy] forKey:@"transferAbsPorts"];
    [aCoder encodeObject:[self.transferConPorts copy] forKey:@"transferConPorts"];
}

@end
