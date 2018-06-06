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
#import "XGRedisUtil.h"
#import "AINet.h"
#import "AINetAbsUtils.h"

@implementation AINetAbs

-(AINetAbsNode*) create:(NSArray*)foNodes refs_p:(NSArray*)refs_p{
    //1. 从宏信息索引中,查找是否已经存在针对refs_p的抽象;(有则复用)
    AIKVPointer *oldAbsNode_p = [[AINet sharedInstance] getNetAbsIndex_AbsPointer:refs_p];
    AINetAbsNode *absNode = [SMGUtils searchObjectForPointer:oldAbsNode_p fileName:FILENAME_Node];
    
    //2. absNode:无则创建;
    if (absNode == nil) {
        absNode = [[AINetAbsNode alloc] init];
        absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_NODE];
        [absNode.refs_p addObjectsFromArray:refs_p];//指定微信息
        [[AINet sharedInstance] setNetAbsIndex_AbsNode:absNode];//建索引
    }
    
    //3. 关联
    for (AIFrontOrderNode *foNode in ARRTOOK(foNodes)) {
        //4. conPorts插口(有则强化 & 无则创建)
        AIPort *findConPort = [AINetAbsUtils searchPortWithTargetP:foNode.pointer fromPorts:absNode.conPorts];
        if (findConPort) {
            [findConPort strongPlus];
        }else{
            AIPort *conPort = [[AIPort alloc] init];
            conPort.pointer = foNode.pointer;
            [absNode.conPorts addObject:conPort];
        }
        
        //5. absPorts插口(有则强化 & 无则创建)
        AIPort *findAbsPort = [AINetAbsUtils searchPortWithTargetP:absNode.pointer fromPorts:foNode.absPorts];
        if (findAbsPort) {
            [findAbsPort strongPlus];
        }else{
            AIPort *absPort = [[AIPort alloc] init];
            absPort.pointer = absNode.pointer;
            [foNode.absPorts addObject:absPort];
        }
        
        //6. 存foNode
        [SMGUtils insertObject:foNode rootPath:foNode.pointer.filePath fileName:FILENAME_Node];
    }
    
    //7. 存储absNode并返回
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

//废弃此方法,按强度排序
-(void) addConPort:(AIPort*)conPort{
    if (ISOK(conPort, AIPort.class) && ISOK(conPort.pointer, AIKVPointer.class)) {
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(self.conPorts, checkIndex);
            return [SMGUtils comparePointerA:conPort.pointer pointerB:checkPort.pointer];
        } startIndex:0 endIndex:self.conPorts.count success:^(NSInteger index) {
            //省略
        } failure:^(NSInteger index) {
            //省略
        }];
    }
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
        id con = [SMGUtils searchObjectForPointer:conPort.pointer fileName:FILENAME_Node];
        NSLog(@"%@\n",con);
    }
    NSLog(@"___ref\n");
    for (AIKVPointer *ref_p in self.refs_p) {
        NSLog(@"%@\n",[SMGUtils searchObjectForPointer:ref_p fileName:FILENAME_Value]);
    }
    NSLog(@"\n\n\n");
}

@end
