//
//  AINetAbs.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsFoManager.h"
#import "AIMvFoManager.h"
#import "AIPort.h"
#import "PINCache.h"
#import "AIKVPointer.h"
#import "SMGUtils.h"
#import "XGRedisUtil.h"
#import "AINet.h"
#import "AINetAbsFoUtils.h"
#import "AIFrontOrderNode.h"
#import "AINetAbsFoNode.h"
#import "AINetUtils.h"
#import "NSString+Extension.h"
#import "AIAlgNodeBase.h"

@implementation AIAbsFoManager

-(AINetAbsFoNode*) create:(NSArray*)conFos orderSames:(NSArray*)orderSames{
    //1. 数据准备
    if (!ARRISOK(conFos)) {
        return nil;
    }
    NSArray *sortSames = ARRTOOK([SMGUtils sortPointers:orderSames]);
    NSString *samesStr = [SMGUtils convertPointers2String:sortSames];
    NSString *samesMd5 = STRTOOK([NSString md5:samesStr]);
    
    //2. 判断algA.absPorts和absB.absPorts中的header,是否已存在algSames的抽象节点;
    AINetAbsFoNode *findAbsNode = nil;
    NSMutableArray *allAbsPorts = [[NSMutableArray alloc] init];
    for (AIFoNodeBase *conItem in conFos) {
        [allAbsPorts addObjectsFromArray:conItem.absPorts];
    }
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
        
        
        //TODOTOMORROW:
        //1. IndexRefrence和AINetUtil.insertPointer微信息部分有重复;
        //3. 取用时,优先取memPorts和memNode;
        //4. 存储时,将当前的排到首位;
        
        //1. 此处hdNet中的absFo有可能引用,memNet中的algNode;
        
        
        
        
    }
    
    //5. 具象节点_关联&存储
    for (AIFoNodeBase *conItem in conFos) {
        if (findAbsNode.pointer.isMem) {
            ////TODO判断此处是否调用toMemPorts:方法;
        }
        [AINetUtils insertPointer:findAbsNode.pointer toPorts:conItem.absPorts ps:findAbsNode.orders_kvp];
        [AINetUtils insertPointer:conItem.pointer toPorts:findAbsNode.conPorts ps:conItem.orders_kvp];
        [SMGUtils insertObject:conItem pointer:conItem.pointer fileName:FILENAME_Node time:cRedisNodeTime];
    }
    
    //6. 抽象节点_存储
    [SMGUtils insertObject:findAbsNode pointer:findAbsNode.pointer fileName:FILENAME_Node time:cRedisNodeTime];
    
    return findAbsNode;
}

@end
