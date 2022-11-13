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

//MARK:===============================================================
//MARK:                     < publicMethod >
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

/**
 *  MARK:--------------------获取cutIndex--------------------
 *  @desc 根据indexDic取得截点cutIndex (参考27177-todo2);
 */
-(int) getCutIndexByIndexDic{
//    //2. assFo已发生截点 (含cutIndex已发生,所以cutIndex应该就是proto末位在assFo中匹配到的assIndex下标);
//    NSInteger assCutIndex = -1;
//    //6. 匹配时_记录assFo匹配到的cutIndex;
//    if (protoIndex == protoOrRegroupFo.count - 1) {
//        assCutIndex = assIndex;
//    }
    return 0;
}

/**
 *  MARK:--------------------获取near数据--------------------
 *  @desc 根据indexDic取得nearCount&sumNear (参考27177-todo3);
 */
-(void) getNearCountAndSumNearByIndexDic {
//    int nearCount = 0;  //总相近数 (匹配值<1)
//    CGFloat sumNear = 0;//总相近度
//    //10. 统计匹配度 & 匹配数;
//    AIAlgNodeBase *protoAlg = [SMGUtils searchNode:protoAlg_p];
//    CGFloat near = [protoAlg getAbsMatchValue:assAlg_p];
//
//    //10. 二者一样时,直接=1;
//    if ([protoAlg_p isEqual:assAlg_p]) near = 1;
//    AddTCDebug(@"时序识别15");
//
//    //10. 只记录near<1的 (取<1的原因未知,参考2619j-todo5);
//    if (near < 1) {
//        [AITest test14:near];
//        sumNear += near;
//        nearCount++;
//    }
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
}

@end
