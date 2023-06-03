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

-(NSMutableArray *)contentPorts{
    if (_contentPorts == nil) _contentPorts = [[NSMutableArray alloc] init];
    return _contentPorts;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(NSInteger) count{
    return self.contentPorts.count;
}

-(NSMutableArray *)content_ps{
    return [SMGUtils convertArr:self.contentPorts convertBlock:^id(AIPort *obj) {
        return obj.target_p;
    }];
}

-(void) setContent_ps:(NSArray*)content_ps {
    [self setContent_ps:content_ps getStrongBlock:^NSInteger(AIKVPointer *item_p) {
        return 1;
    }];
}

-(AIKVPointer*) p {
    return self.pointer;
}

-(NSInteger) pId {
    return self.pointer.pointerId;
}

/**
 *  MARK:--------------------设置引用--------------------
 *  @version
 *      2023.04.15: BUG_此处header应该以alg元素为准;
 */
-(void) setContent_ps:(NSArray*)content_ps getStrongBlock:(NSInteger(^)(AIKVPointer *item_p))getStrongBlock{
    content_ps = ARRTOOK(content_ps);
    self.contentPorts = [SMGUtils convertArr:content_ps convertBlock:^id(AIKVPointer *obj) {
        //1. 数据准备: 求出header
        AIAlgNodeBase *alg = [SMGUtils searchNode:obj];
        NSArray *sortValue_ps = ARRTOOK([SMGUtils sortPointers:alg.content_ps]);
        NSString *header = [NSString md5:[SMGUtils convertPointers2String:sortValue_ps]];
        
        //2. 生成port
        AIPort *port = [[AIPort alloc] init];
        port.target_p = obj;
        port.header = header;
        port.strong.value = getStrongBlock(obj);
        return port;
    }];
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
        self.contentPorts = [aDecoder decodeObjectForKey:@"contentPorts"];
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
    [aCoder encodeObject:[self.contentPorts copy] forKey:@"contentPorts"];
}

@end
