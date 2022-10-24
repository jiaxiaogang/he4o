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
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.refPorts = [aDecoder decodeObjectForKey:@"refPorts"];
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
}

@end
