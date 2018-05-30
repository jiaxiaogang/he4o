//
//  AINetAbs.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbs.h"
#import "AINetCMV.h"
#import "AIPort.h"
#import "PINCache.h"
#import "AIKVPointer.h"

@implementation AINetAbs

-(AINetAbsNode*) create:(NSArray*)foNodes refs_p:(NSArray*)refs_p{
    //1. 构建absNode;
    AINetAbsNode *absNode = [[AINetAbsNode alloc] init];
    absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_NODE];
    
    for (AIFrontOrderNode *foNode in ARRTOOK(foNodes)) {
        //2. 给absNode插上conPorts
        AIPort *conPort = [[AIPort alloc] init];
        conPort.pointer = foNode.pointer;
        [absNode.conPorts addObject:conPort];
        
        //3. 给foNode插上absPorts
        AIPort *absPort = [[AIPort alloc] init];
        absPort.pointer = absNode.pointer;
        [foNode.absPorts addObject:absPort];
    }
    
    //4. 指定微信息
    [absNode.refs_p addObjectsFromArray:refs_p];
    
    //5. 存储absNode并返回
    PINDiskCache *pinCache = [[PINDiskCache alloc] initWithName:@"" rootPath:absNode.pointer.filePath];
    [pinCache setObject:absNode forKey:FILENAME_Node];
    return absNode;
}

@end



@implementation AINetAbsNode


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(NSMutableArray *)conPorts{
    if (_conPorts == nil) {
        _conPorts = [[NSMutableArray alloc] init];
    }
    return _conPorts;
}

-(NSMutableArray *)refs_p{
    if (_refs_p == nil) {
        _refs_p = [[NSMutableArray alloc] init];
    }
    return _refs_p;
}


/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.pointer = [aDecoder decodeObjectForKey:@"pointer"];
        self.conPorts = [aDecoder decodeObjectForKey:@"conPorts"];
        self.refs_p = [aDecoder decodeObjectForKey:@"refs_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.refs_p forKey:@"refs_p"];
}

@end
