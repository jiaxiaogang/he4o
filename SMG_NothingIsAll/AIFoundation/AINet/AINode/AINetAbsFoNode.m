//
//  AINetAbsFoNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsFoNode.h"

@implementation AINetAbsFoNode


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

-(NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [[NSMutableArray alloc] init];
    }
    return _conPorts;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
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
    [aCoder encodeObject:[self.conPorts copy] forKey:@"conPorts"];
}

@end
