//
//  AINetAbs.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsManager.h"
#import "AICMVManager.h"
#import "AIPort.h"
#import "PINCache.h"
#import "AIKVPointer.h"
#import "SMGUtils.h"
#import "XGRedisUtil.h"
#import "AINet.h"
#import "AINetAbsUtils.h"
#import "AIFrontOrderNode.h"
#import "AINetAbsFoNode.h"
#import "AINetUtils.h"
#import "NSString+Extension.h"
#import "AIAlgNodeBase.h"

@implementation AIAbsManager

-(AINetAbsFoNode*) create:(AIFoNodeBase*)foA foB:(AIFoNodeBase*)foB orderSames:(NSArray*)orderSames{
    //1. 数据准备
    NSArray *sortSames = ARRTOOK([SMGUtils sortPointers:orderSames]);
    NSString *samesStr = [SMGUtils convertPointers2String:sortSames];
    NSString *samesMd5 = STRTOOK([NSString md5:samesStr]);
    
    //2. 判断algA.absPorts和absB.absPorts中的header,是否已存在algSames的抽象节点;
    AINetAbsFoNode *findAbsNode = nil;
    NSMutableArray *allAbsPorts = [[NSMutableArray alloc] init];
    [allAbsPorts addObjectsFromArray:foA.absPorts];
    [allAbsPorts addObjectsFromArray:foB.absPorts];
    for (AIPort *port in allAbsPorts) {
        if ([samesMd5 isEqualToString:port.header]) {
            findAbsNode = [SMGUtils searchObjectForPointer:port.target_p fileName:FILENAME_Node time:cRedisNodeTime];
            break;
        }
    }
    
    //3. 无则创建
    if (!findAbsNode) {
        findAbsNode = [[AINetAbsFoNode alloc] init];
        findAbsNode.pointer = [SMGUtils createPointerForNode:PATH_NET_FO_ABS_NODE];
        [findAbsNode.orders_kvp addObjectsFromArray:sortSames];//指定微信息
        
        //4. value.refPorts (更新微信息的引用序列)
        [AINetUtils insertPointer:findAbsNode.pointer toRefPortsByOrders:findAbsNode.orders_kvp ps:findAbsNode.orders_kvp];
    }
    
    //5. 关联
    [AINetUtils insertPointer:findAbsNode.pointer toPorts:foA.absPorts ps:findAbsNode.orders_kvp];
    [AINetUtils insertPointer:findAbsNode.pointer toPorts:foB.absPorts ps:findAbsNode.orders_kvp];
    [AINetUtils insertPointer:foA.pointer toPorts:findAbsNode.conPorts ps:foA.orders_kvp];
    [AINetUtils insertPointer:foB.pointer toPorts:findAbsNode.conPorts ps:foB.orders_kvp];
    
    //6. 存储
    [SMGUtils insertObject:findAbsNode pointer:findAbsNode.pointer fileName:FILENAME_Node time:cRedisNodeTime];
    [SMGUtils insertObject:foA pointer:foA.pointer fileName:FILENAME_Node time:cRedisNodeTime];
    [SMGUtils insertObject:foB pointer:foB.pointer fileName:FILENAME_Node time:cRedisNodeTime];
    
    return findAbsNode;
}

@end
