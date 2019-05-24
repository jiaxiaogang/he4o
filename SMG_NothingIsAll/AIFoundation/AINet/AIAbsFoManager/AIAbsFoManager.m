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
        
        
        //TODOUseMemNet:AddAbsMemPorts
        
        
        
        
        //TODOTOMORROW: (UseMemNet)
        //1. IndexRefrence和AINetUtil.insertPointer微信息部分有重复;
        //2. 取用时,优先取memPorts和memNode;
        //3. 处理所有TODOUseMemNet:
        
        
        
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
        
        ///1. 收集order_ps (将不在hdNet中的转移)
        for (AIKVPointer *item_p in sortSames) {
            if (item_p.isMem) {
                AIAlgNodeBase *memAlgNode = [SMGUtils searchObjectForPointer:item_p fileName:FILENAME_MemNode time:cRedisNodeTime_Mem];
                AIAlgNodeBase *hdAlgNode = [SMGUtils searchObjectForPointer:item_p fileName:FILENAME_Node time:cRedisNodeTime];
                
                ///2. 转移_hdNet不存在,才转移;
                if (hdAlgNode == nil) {
                    hdAlgNode = memAlgNode;
                    hdAlgNode.pointer.isMem = false;
                    
                    ///3. 转移_微信息引用序列;
                    [AINetUtils insertRefPorts_AllAlgNode:hdAlgNode.pointer value_ps:hdAlgNode.content_ps ps:hdAlgNode.content_ps];
                    
                    ///4. 转移_存储到hdNet
                    [SMGUtils insertNode:hdAlgNode];
                }
                
                ///5. 收集order_p
                [findAbsNode.orders_kvp addObject:hdAlgNode.pointer];
            }else{
                ///6. 收集order_p
                [findAbsNode.orders_kvp addObject:item_p];
            }
        }
        
        //4. order_ps更新祖母节点引用序列;
        [AINetUtils insertRefPorts_AllFoNode:findAbsNode.pointer order_ps:findAbsNode.orders_kvp ps:findAbsNode.orders_kvp];
    }
    
    //5. 具象节点&抽象节点_关联&存储
    [AINetUtils relateFoAbs:findAbsNode conNodes:conFos];
    return findAbsNode;
}

@end
