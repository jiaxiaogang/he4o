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

-(NSMutableArray *)diffBasePorts{
    if (!ISOK(_diffBasePorts, NSMutableArray.class)) _diffBasePorts = [[NSMutableArray alloc] initWithArray:_diffBasePorts];
    return _diffBasePorts;
}

-(NSMutableArray *)diffSubPorts{
    if (!ISOK(_diffSubPorts, NSMutableArray.class)) _diffSubPorts = [[NSMutableArray alloc] initWithArray:_diffSubPorts];
    return _diffSubPorts;
}

-(NSMutableDictionary *)spDic{
    if (!ISOK(_spDic, NSMutableDictionary.class)) _spDic = [[NSMutableDictionary alloc] initWithDictionary:_spDic];
    return _spDic;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
/**
 *  MARK:--------------------更新SP强度值--------------------
 *  @param cutIndex : 当前要更新sp强度值的下标 (如果是mv则输入-1);
 */
-(void) updateSPStrong:(NSInteger)cutIndex type:(AnalogyType)type{
    //1. 取kv;
    NSNumber *key = @(cutIndex);
    AISPStrong *value = [self.spDic objectForKey:key];
    if (!value) value = [[AISPStrong alloc] init];
    
    //2. 更新强度_线性+1 (参考25031-7);
    if (type == ATSub) {
        value.sStrong++;
    }else if(type == ATPlus){
        value.pStrong++;
    }
    [self.spDic setObject:value forKey:key];
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
        self.diffBasePorts = [aDecoder decodeObjectForKey:@"diffBasePorts"];
        self.diffSubPorts = [aDecoder decodeObjectForKey:@"diffSubPorts"];
        self.spDic = [aDecoder decodeObjectForKey:@"spDic"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cmvNode_p forKey:@"cmvNode_p"];
    [aCoder encodeObject:self.deltaTimes forKey:@"deltaTimes"];
    [aCoder encodeDouble:self.mvDeltaTime forKey:@"mvDeltaTime"];
    [aCoder encodeObject:[self.diffBasePorts copy] forKey:@"diffBasePorts"];
    [aCoder encodeObject:[self.diffSubPorts copy] forKey:@"diffSubPorts"];
    [aCoder encodeObject:[self.spDic copy] forKey:@"spDic"];
}

@end
