//
//  AINodeBase.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"
#import "AIKVPointer.h"

@implementation AINodeBase

-(NSMutableArray *)conPorts{
    if (!ISOK(_conPorts, NSMutableArray.class)) _conPorts = [[NSMutableArray alloc] initWithArray:_conPorts];
    return _conPorts;
}

-(NSMutableArray *)absPorts{
    if (!ISOK(_absPorts, NSMutableArray.class)) _absPorts = [[NSMutableArray alloc] initWithArray:_absPorts];
    return _absPorts;
}

-(NSMutableArray *)content_ps{
    if (_content_ps == nil) _content_ps = [[NSMutableArray alloc] init];
    return _content_ps;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(NSInteger) count{
    return self.content_ps.count;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

-(BOOL)isEqual:(AINodeBase*)object{
    return [self.pointer isEqual:object.pointer];
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
        self.absPorts = [aDecoder decodeObjectForKey:@"absPorts"];
        self.content_ps = [aDecoder decodeObjectForKey:@"content_ps"];
    }
    return self;
}

/**
 *  MARK:--------------------序列化--------------------
 *  @bug
 *      2020.07.10: 最近老闪退,前段时间XGWedis异步存由10s改为2s,有UMeng看是这里闪的,打try也能捕获这里抛了异常,将ports加了copy试下,应该好了;
 *      2020.12.27: 老闪退,将ports加了copy应该就好了 (原来就有过类似问题,这次全局conPorts,absPorts和refPorts都加了copy);
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:[self.conPorts copy] forKey:@"conPorts"];
    [aCoder encodeObject:[self.absPorts copy] forKey:@"absPorts"];
    [aCoder encodeObject:self.content_ps forKey:@"content_ps"];
}

@end
