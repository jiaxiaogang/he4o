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
    //1. 从宏信息索引中,查找是否已经存在针对refs_p的抽象;(有则复用)(无则创建)
    AIKVPointer *absValue_p = [theNet getNetAbsIndex_AbsPointer:refs_p];
    AIKVPointer *absNode_p = [theNet getItemAbsNodePointer:absValue_p];
    AINetAbsNode *absNode = [SMGUtils searchObjectForPointer:absNode_p fileName:FILENAME_Node];
    
    //2. absNode:无则创建;
    if (absNode == nil) {
        absNode = [[AINetAbsNode alloc] init];
        absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_ABSNODE];
        absNode.absValue_p = absValue_p;//指定微信息
        [[AINet sharedInstance] setAbsIndexReference:absValue_p target_p:absNode.pointer difValue:1];//引用插线
    }
    
    //3. 关联
    for (AIFrontOrderNode *foNode in ARRTOOK(foNodes)) {
        //4. conPorts插口(有则强化 & 无则创建)
        AIPort *findConPort = [AINetAbsUtils searchPortWithTargetP:foNode.pointer fromPorts:absNode.conPorts];
        if (findConPort) {
            [findConPort strongPlus];
        }else{
            AIPort *conPort = [[AIPort alloc] init];
            conPort.target_p = foNode.pointer;
            [absNode.conPorts addObject:conPort];
        }
        
        //5. absPorts插口(有则强化 & 无则创建)
        AIPort *findAbsPort = [AINetAbsUtils searchPortWithTargetP:absNode.pointer fromPorts:foNode.absPorts];
        if (findAbsPort) {
            [findAbsPort strongPlus];
        }else{
            AIPort *absPort = [[AIPort alloc] init];
            absPort.target_p = absNode.pointer;
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

//废弃此方法,按强度排序
-(void) addConPort:(AIPort*)conPort{
    if (ISOK(conPort, AIPort.class) && ISOK(conPort.target_p, AIKVPointer.class)) {
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(self.conPorts, checkIndex);
            return [SMGUtils comparePointerA:conPort.target_p pointerB:checkPort.target_p];
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
        self.absValue_p = [aDecoder decodeObjectForKey:@"absValue_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pointer forKey:@"pointer"];
    [aCoder encodeObject:self.conPorts forKey:@"conPorts"];
    [aCoder encodeObject:self.absValue_p forKey:@"absValue_p"];
}

-(void) print{
    //1. header
    NSLog(@"________ABSNODE:%d_______\n",self.pointer.pointerId);
    
    //2. conNode
    NSMutableString *conDesc = [[NSMutableString alloc] init];
    
    for (AIPort *conPort in self.conPorts) {
        id con = [SMGUtils searchObjectForPointer:conPort.target_p fileName:FILENAME_Node];
        NSMutableString *micDesc = [NSMutableString new];
        NSString *conPath = nil;
        if (ISOK(con, AIFrontOrderNode.class)) {
            AIFrontOrderNode *foNode = (AIFrontOrderNode*)con;
            for (AIKVPointer *foValue_p in ARRTOOK(foNode.orders_kvp)) {
                [micDesc appendFormat:@"%@ ",[SMGUtils searchObjectForPointer:foValue_p fileName:FILENAME_Value]];
            }
            conPath = STRFORMAT(@"%@/%@/%@/%ld",foNode.pointer.folderName,foNode.pointer.algsType,foNode.pointer.dataSource,(long)foNode.pointer.pointerId);
        }else if(ISOK(con, AINetAbsNode.class)){
            AINetAbsNode *absNode = (AINetAbsNode*)con;
            [micDesc appendString:[SMGUtils searchObjectForPointer:absNode.absValue_p fileName:FILENAME_AbsValue]];
            conPath = STRFORMAT(@"%@/%@/%@/%ld",absNode.pointer.folderName,absNode.pointer.algsType,absNode.pointer.dataSource,(long)absNode.pointer.pointerId);
        }
        [conDesc appendFormat:@"\n> 具象地址:%@\n> 微信息:%@\n",conPath,micDesc];
    }
    NSLog(@"conNode>>>\n%@\n",conDesc);
    
    //3. refs
    NSMutableString *refsDesc = [[NSMutableString alloc] init];
    [refsDesc appendFormat:@"%@ ",[SMGUtils searchObjectForPointer:self.absValue_p fileName:FILENAME_Value]];
    NSLog(@"refs>>>\n> %@",refsDesc);
    
    //4. footer
    NSLog(@"________ABSNODEEND_______\n\n");
}

@end
