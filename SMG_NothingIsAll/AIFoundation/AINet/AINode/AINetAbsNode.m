//
//  AINetAbsNode.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsNode.h"
#import "XGRedisUtil.h"
#import "AIPort.h"
#import "AIKVPointer.h"
#import "AIFrontOrderNode.h"

@implementation AINetAbsNode


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================


//废弃此方法,按强度排序
//-(void) addConPort:(AIPort*)conPort{
//    if (ISOK(conPort, AIPort.class) && ISOK(conPort.target_p, AIKVPointer.class)) {
//        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
//            AIPort *checkPort = ARR_INDEX(self.conPorts, checkIndex);
//            return [SMGUtils comparePointerA:conPort.target_p pointerB:checkPort.target_p];
//        } startIndex:0 endIndex:self.conPorts.count success:^(NSInteger index) {
//            //省略
//        } failure:^(NSInteger index) {
//            //省略
//        }];
//    }
//}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.absValue_p = [aDecoder decodeObjectForKey:@"absValue_p"];
        self.absCmvNode_p = [aDecoder decodeObjectForKey:@"absCmvNode_p"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.absValue_p forKey:@"absValue_p"];
    [aCoder encodeObject:self.absCmvNode_p forKey:@"absCmvNode_p"];
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
