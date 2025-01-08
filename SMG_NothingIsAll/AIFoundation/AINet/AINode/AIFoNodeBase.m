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

-(NSMutableDictionary *)outSPDic{
    if (!ISOK(_outSPDic, NSMutableDictionary.class)) _outSPDic = [[NSMutableDictionary alloc] initWithDictionary:_outSPDic];
    return _outSPDic;
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

-(NSMutableArray *)transferIPorts{
    if (!ISOK(_transferIPorts, NSMutableArray.class)) _transferIPorts = [[NSMutableArray alloc] initWithArray:_transferIPorts];
    return _transferIPorts;
}

-(NSMutableArray *)transferFPorts{
    if (!ISOK(_transferFPorts, NSMutableArray.class)) _transferFPorts = [[NSMutableArray alloc] initWithArray:_transferFPorts];
    return _transferFPorts;
}

//-(NSMutableDictionary *)debugSPMinXiLog{
//    if (!ISOK(_debugSPMinXiLog, NSMutableDictionary.class)) _debugSPMinXiLog = [[NSMutableDictionary alloc] initWithDictionary:_debugSPMinXiLog];
//    return _debugSPMinXiLog;
//}

//MARK:===============================================================
//MARK:                     < spDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新SP强度值--------------------
 *  @param spIndex : 当前要更新sp强度值的下标 (参考25031-3);
 *                    1. 表示责任帧下标,比如为1时,则表示第2帧的责任;
 *                    2. 如果是mv则输入content.count;
 */
-(void) updateSPStrong:(NSInteger)spIndex type:(AnalogyType)type caller:(NSString*)caller {
    [self updateSPStrong:spIndex difStrong:1 type:type caller:caller];
}
-(void) updateSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type caller:(NSString*)caller {
    [self updateSPStrong:spIndex difStrong:difStrong type:type forSPDic:self.spDic];
    
    //DEBUG: 如果sp值异常,可以打开此处训练,把整个sp累计的过程明细打出来,调试sp值都是从哪里来的 (参考33137-出过SP巨大的BUG);
    //NSString *logKey = STRFORMAT(@"%ld %@ %@",spIndex,caller,ATType2Str(type));
    //NSString *countKey = STRFORMAT(@"次数 %@",logKey);
    //NSString *sumKey = STRFORMAT(@"和数 %@",logKey);
    //
    //long oldCount = NUMTOOK([self.debugSPMinXiLog objectForKey:countKey]).longValue;
    //[self.debugSPMinXiLog setObject:@(oldCount+1) forKey:countKey];
    //
    //long oldSum = NUMTOOK([self.debugSPMinXiLog objectForKey:sumKey]).longValue;
    //[self.debugSPMinXiLog setObject:@(oldSum+difStrong) forKey:sumKey];
    //
    //for (id key in self.debugSPMinXiLog.allKeys) {
    //    NSNumber *value = [self.debugSPMinXiLog objectForKey:key];
    //    if (NUMTOOK(value).integerValue > 1000000) {
    //        NSLog(@"debugSPMinXiLog: \n%@",self.debugSPMinXiLog);
    //        NSLog(@"%@ = %@",key,value);
    //        NSLog(@"");
    //    }
    //}
}

/**
 *  MARK:--------------------更新SP强度值 (指定SPDic)--------------------
 */
-(void) updateSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type forSPDic:(NSMutableDictionary*)forSPDic {
    //1. 取kv;
    NSNumber *key = @(spIndex);
    AISPStrong *value = [forSPDic objectForKey:key];
    if (!value) value = [[AISPStrong alloc] init];
    
    //2. 更新强度_线性+1 (参考25031-7);
    if (type == ATSub) {
        value.sStrong += difStrong;
    }else if(type == ATPlus){
        value.pStrong += difStrong;
    }
    [forSPDic setObject:value forKey:key];
    
    //3. 保存fo
    [SMGUtils insertNode:self];
}

/**
 *  MARK:--------------------从start到end都计一次P--------------------
 *  @desc 含start 也含end;
 */
-(void) updateSPStrong:(NSInteger)start end:(NSInteger)end type:(AnalogyType)type caller:(NSString*)caller {
    for (NSInteger i = start; i <= end; i++) {
        [self updateSPStrong:i type:type caller:caller];
    }
}

/**
 *  MARK:--------------------更新整个spDic--------------------
 */
-(void) updateSPDic:(NSDictionary*)newSPDic {
    newSPDic = DICTOOK(newSPDic);
    for (NSNumber *newIndex in newSPDic.allKeys) {
        AISPStrong *newStrong = [newSPDic objectForKey:newIndex];
        [self updateSPStrong:newIndex.integerValue difStrong:newStrong.sStrong type:ATSub caller:@"更新整个spDic"];
        [self updateSPStrong:newIndex.integerValue difStrong:newStrong.pStrong type:ATPlus caller:@"更新整个spDic"];
    }
}

//MARK:===============================================================
//MARK:                     < outSPDic组 >
//MARK:===============================================================

/**
 *  MARK:--------------------更新OutSPDic强度值--------------------
 *  @callers 默认由scene来调用;
 */
-(void) updateOutSPStrong:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type canset:(NSArray*)cansetContent_ps debugMode:(BOOL)debugMode caller:(NSString*)caller {
    //1. 取得canstFrom的spStrong;
    NSString *key = [AINetUtils getOutSPKey:cansetContent_ps];
    NSMutableDictionary *itemOutSPDic = [self.outSPDic objectForKey:key];
    
    //2. 如果没有,则新建防空;
    if (!ISOK(itemOutSPDic, NSMutableDictionary.class)) itemOutSPDic = [[NSMutableDictionary alloc] initWithDictionary:itemOutSPDic];
    [self.outSPDic setObject:itemOutSPDic forKey:key];
    
    //3. 更新它的spDic值;
    NSString *spFrom = STRFORMAT(@"%@",[itemOutSPDic objectForKey:@(spIndex)]);
    [self updateSPStrong:spIndex difStrong:difStrong type:type forSPDic:itemOutSPDic];
    
    //4. log
    if (Log4OutSPDic && debugMode) {
        AISPStrong *spTo = [itemOutSPDic objectForKey:@(spIndex)];
        NSString *flt1 = FltLog4DefaultIf(true, @"4");
        NSLog(@"%@updateOutSP:%ld/%ld (%@) %@->%@ sceneTo:F%ld cansetTo:%@ caller:%@",flt1,spIndex,cansetContent_ps.count,ATType2Str(type),spFrom,spTo,self.pId,Pits2FStr(cansetContent_ps),caller);
        NSLog(@"\t%@sceneTo:%@",flt1,Fo2FStr(self));
    }
}

-(BOOL) containsOutSPStrong:(NSArray*)cansetContent_ps {
    NSString *key = [AINetUtils getOutSPKey:cansetContent_ps];
    return [self.outSPDic objectForKey:key];
}

/**
 *  MARK:--------------------由sceneFo调用,返回canset对应的itemOutSPDic--------------------
 */
-(NSDictionary*) getItemOutSPDic:(NSString*)cansetOutSPKey {
    return [self.outSPDic objectForKey:cansetOutSPKey];
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
    NSArray *strongs = [ARRTOOK([self.effectDic objectForKey:@(effectIndex)]) copy];
    
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
    
    //TODOTOMORROW20240626: 看下有没indexDic越界了;
    for (NSNumber *key in indexDic.allKeys) {
        NSNumber *value = [indexDic objectForKey:key];
        if (value.integerValue >= self.count) {
            NSLog(@"映射的value越界,已修,复测一段时间,遇过两次,都修了,如果到2024.07.26没断过点,则删除此处");
        } else if (key.integerValue >= absFo.count) {
            NSLog(@"映射的key越界,已修,复测一段时间,遇过两次,都修了,如果到2024.07.26没断过点,则删除此处");
        }
    }
    [AITest test34:indexDic];
    
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
 *  @version
 *      2023.09.10: H任务时,>targetIndex的未必包含targetIndex,所以加上H任务时,canset中必须包含targetIndex对应帧;
 *  @result notnull
 */
-(NSArray*) getConCansets:(NSInteger)targetIndex {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    BOOL forH = targetIndex < self.count;
    for (NSInteger i = targetIndex; i <= self.count; i++) {
        NSArray *itemArr = ARRTOOK([self.conCansetsDic objectForKey:@(i)]);
        if (forH) { //H任务时,要求canset中必须包含targetIndex映射帧;
            itemArr = [SMGUtils filterArr:itemArr checkValid:^BOOL(AIKVPointer *item) {
                NSDictionary *indexDic = [self getConIndexDic:item];
                return [indexDic objectForKey:@(targetIndex)];
            }];
        }
        [result addObjectsFromArray:itemArr];
    }
    return [SMGUtils removeRepeat:result];
}

/**
 *  MARK:--------------------更新一条候选--------------------
 *  @version
 *      2023.06.16: 修复更新updateEffectStrong的targetIndex传错了,每次都传的1的问题 (参考30023-修复);
 *  @result 将是否保存成功返回 (长度为1及以下的没后段,所以直接不存了) (参考28052-4 && 29094-BUG1);
 */
-(HEResult*) updateConCanset:(AIKVPointer*)newConCansetFo targetIndex:(NSInteger)targetIndex {
    //0. canset没后段的直接不存了 (没可行为化的东西) (参考28052-4);
    AIFoNodeBase *newCanset = [SMGUtils searchNode:newConCansetFo];
    if (newCanset.count <= 1) return [HEResult newFailure];
    
    //1. 更新一条候选;
    NSMutableArray *conCansets = [[NSMutableArray alloc] initWithArray:[self.conCansetsDic objectForKey:@(targetIndex)]];
    if (![conCansets containsObject:newConCansetFo]) {
        //2024.10.22: 此处在33107修复后,仍测到过一次NewHCanset时,有重复的情况,不过后来死活不复现了,如果以后发现HCanset有重复内容的情况,再来打开这个日志,看能不能复现;
        //NSString *newDesc = Pits2FStr(newCanset.content_ps);
        //for (AIKVPointer *oldCanset in conCansets) {
        //    AIFoNodeBase *oldFo = [SMGUtils searchNode:oldCanset];
        //    NSString *oldDesc = Pits2FStr(oldFo.content_ps);
        //    if (newCanset.pId != oldFo.pId && [newDesc isEqualToString:oldDesc]) {
        //        //此处等FZ1013重跑跑不断点后,说明canset重复的bug彻底好了,到时此日志可删掉 (参考33107);
        //        ELog(@"发现内容重复 更新入scene: %@ %@",Fo2FStr(newCanset),Fo2FStr(oldFo));
        //    }
        //}
        
        [conCansets addObject:newConCansetFo];
        [self.conCansetsDic setObject:conCansets forKey:@(targetIndex)];
        [SMGUtils insertNode:self];
        return [[HEResult newSuccess] mkIsNew:@(true)];
    }
    
    //2. 更新后 (新的默认eff.h=1,旧的eff则增强+1);
    [self updateEffectStrong:targetIndex solutionFo:newConCansetFo status:ES_HavEff];
    return [[HEResult newSuccess] mkIsNew:@(false)];
}

/**
 *  MARK:--------------------将当前fo解析成orders返回--------------------
 */
-(NSArray*) convert2Orders {
    return [SMGUtils convertArr:self.content_ps iConvertBlock:^id(NSInteger i, AIKVPointer *obj) {
        double deltaTime = [NUMTOOK(ARR_INDEX(self.deltaTimes, i)) doubleValue];
        return [AIShortMatchModel_Simple newWithAlg_p:obj inputTime:deltaTime isTimestamp:false];
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
        self.outSPDic = [aDecoder decodeObjectForKey:@"outSPDic"];
        self.effectDic = [aDecoder decodeObjectForKey:@"effectDic"];
        self.absIndexDDic = [aDecoder decodeObjectForKey:@"absIndexDDic"];
        self.conIndexDDic = [aDecoder decodeObjectForKey:@"conIndexDDic"];
        self.conCansetsDic = [aDecoder decodeObjectForKey:@"conCansetsDic"];
        self.transferFPorts = [aDecoder decodeObjectForKey:@"transferFPorts"];
        self.transferIPorts = [aDecoder decodeObjectForKey:@"transferIPorts"];
        //self.debugSPMinXiLog = [aDecoder decodeObjectForKey:@"debugSPMinXiLog"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cmvNode_p forKey:@"cmvNode_p"];
    [aCoder encodeObject:self.deltaTimes forKey:@"deltaTimes"];
    [aCoder encodeDouble:self.mvDeltaTime forKey:@"mvDeltaTime"];
    [aCoder encodeObject:[self.spDic copy] forKey:@"spDic"];
    [aCoder encodeObject:[self.outSPDic copy] forKey:@"outSPDic"];
    [aCoder encodeObject:[self.effectDic copy] forKey:@"effectDic"];
    [aCoder encodeObject:[self.absIndexDDic copy] forKey:@"absIndexDDic"];
    [aCoder encodeObject:[self.conIndexDDic copy] forKey:@"conIndexDDic"];
    [aCoder encodeObject:[self.conCansetsDic copy] forKey:@"conCansetsDic"];
    [aCoder encodeObject:[self.transferFPorts copy] forKey:@"transferFPorts"];
    [aCoder encodeObject:[self.transferIPorts copy] forKey:@"transferIPorts"];
    //[aCoder encodeObject:[self.debugSPMinXiLog copy] forKey:@"debugSPMinXiLog"];
}

@end
