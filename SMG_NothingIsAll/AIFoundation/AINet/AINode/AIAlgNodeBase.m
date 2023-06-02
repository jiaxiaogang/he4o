//
//  AIAlgNodeBase.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIAlgNodeBase.h"

@implementation AIAlgNodeBase

-(NSMutableArray *)refPorts{
    if (!ISOK(_refPorts, NSMutableArray.class)) {
        _refPorts = [[NSMutableArray alloc] initWithArray:_refPorts];
    }
    return _refPorts;
}

-(NSMutableDictionary *)absMatchDic{
    if (!ISOK(_absMatchDic, NSMutableDictionary.class)) _absMatchDic = [[NSMutableDictionary alloc] initWithDictionary:_absMatchDic];
    return _absMatchDic;
}

-(NSMutableDictionary *)conMatchDic{
    if (!ISOK(_conMatchDic, NSMutableDictionary.class)) _conMatchDic = [[NSMutableDictionary alloc] initWithDictionary:_conMatchDic];
    return _conMatchDic;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------更新抽具象相似度--------------------
 *  @param absAlg : 传抽象节点进来,而self为具象节点;
 *  @version
 *      2022.10.24: 将algNode的抽具象关系也存上相似度 (参考27153-todo2);
 */
-(void) updateMatchValue:(AIAlgNodeBase*)absAlg matchValue:(CGFloat)matchValue{
    //1. 更新抽象相似度;
    [self.absMatchDic setObject:@(matchValue) forKey:@(absAlg.pointer.pointerId)];
    
    //2. 更新具象相似度;
    [absAlg.conMatchDic setObject:@(matchValue) forKey:@(self.pointer.pointerId)];
    
    //3. 保存节点;
    [SMGUtils insertNode:self];
    [SMGUtils insertNode:absAlg];
}

/**
 *  MARK:--------------------取抽或具象的相近度--------------------
 *  @version
 *      2022.12.04: 当二者相等时,默认返回1 (因为时序识别时mIsC1有自身判断,所以取相似度时要兼容支持下);
 */
-(CGFloat) getConMatchValue:(AIKVPointer*)con_p {
    if (PitIsMv(self.pointer) && PitIsMv(con_p)) return [self getMatchValue4Mv:con_p];
    if ([self.pointer isEqual:con_p]) return 1;
    [AITest test26:self.conMatchDic checkA:con_p];
    return NUMTOOK([self.conMatchDic objectForKey:@(con_p.pointerId)]).floatValue;
}
-(CGFloat) getAbsMatchValue:(AIKVPointer*)abs_p {
    if (PitIsMv(self.pointer) && PitIsMv(abs_p)) return [self getMatchValue4Mv:abs_p];
    if ([self.pointer isEqual:abs_p]) return 1;
    [AITest test26:self.absMatchDic checkA:abs_p];
    return NUMTOOK([self.absMatchDic objectForKey:@(abs_p.pointerId)]).floatValue;
}

/**
 *  MARK:--------------------mv匹配度 (参考28171-todo9)--------------------
 *  @desc mv的匹配度就是匹配度的相近度;
 */
-(CGFloat) getMatchValue4Mv:(AIKVPointer*)otherMv_p {
    if ([self.pointer.algsType isEqualToString:otherMv_p.algsType]) {
        AICMVNodeBase *selfMv = (AICMVNodeBase*)self;
        AICMVNodeBase *otherMv = [SMGUtils searchNode:otherMv_p];
        return [AIAnalyst compareCansetValue:selfMv.urgentTo_p protoValue:otherMv.urgentTo_p vInfo:nil];
    }
    return 0;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.refPorts = [aDecoder decodeObjectForKey:@"refPorts"];
        self.absMatchDic = [aDecoder decodeObjectForKey:@"absMatchDic"];
        self.conMatchDic = [aDecoder decodeObjectForKey:@"conMatchDic"];
    }
    return self;
}

/**
 *  MARK:--------------------序列化--------------------
 *  @bug
 *      2020.07.10: 最近老闪退,前段时间XGWedis异步存由10s改为2s,有UMeng看是这里闪的,打try也能捕获这里抛了异常,将ports加了copy试下,应该好了;
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[self.refPorts copy] forKey:@"refPorts"];
    [aCoder encodeObject:[self.absMatchDic copy] forKey:@"absMatchDic"];
    [aCoder encodeObject:[self.conMatchDic copy] forKey:@"conMatchDic"];
}

@end
