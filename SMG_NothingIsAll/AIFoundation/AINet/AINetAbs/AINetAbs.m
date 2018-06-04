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
#import "SMGUtils.h"

@implementation AINetAbs

-(AINetAbsNode*) create:(NSArray*)foNodes refs_p:(NSArray*)refs_p{
    //1. 从foNodes中,查找是否已经存在针对refs_p的抽象;
    AIKVPointer *findAbsNode_p = nil;
    for (AIFrontOrderNode *foNode in ARRTOOK(foNodes)) {
        for (AIAbsPort *absPort in foNode.absPorts) {
            if ([SMGUtils compareArrayA:absPort.refs_p arrayB:refs_p]) {
                findAbsNode_p = absPort.pointer;
                break;
            }
        }
        if (findAbsNode_p) {
            break;
        }
    }
    
    //2. 有则复用,无则创建;
    if (findAbsNode_p) {
        
    }else{
        
    }
    
    
    
    //1. 构建absNode;
    AINetAbsNode *absNode = [[AINetAbsNode alloc] init];
    absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_NODE];
    
    for (AIFrontOrderNode *foNode in ARRTOOK(foNodes)) {
        //2. 给absNode插上conPorts
        AIPort *conPort = [[AIPort alloc] init];
        conPort.pointer = foNode.pointer;
        [absNode.conPorts addObject:conPort];
        
        //3. 给foNode插上absPorts
        AIAbsPort *absPort = [[AIAbsPort alloc] init];
        absPort.pointer = absNode.pointer;
        [absPort.refs_p addObjectsFromArray:refs_p];
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

-(void) print{
    NSLog(@"________ABSNODE:%d_______\n",self.pointer.pointerId);
    NSLog(@"___conNode\n");
    for (AIPort *conPort in self.conPorts) {
        id con = [DBUtils searchObjectForPointer:conPort.pointer fileName:FILENAME_Node];
        NSLog(@"%@\n",con);
    }
    NSLog(@"___ref\n");
    for (AIKVPointer *ref_p in self.refs_p) {
        NSLog(@"%@\n",[DBUtils searchObjectForPointer:ref_p fileName:FILENAME_Value]);
    }
    NSLog(@"\n\n\n");
}

@end
