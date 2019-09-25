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
#import "NVHeUtil.h"

@implementation AIAbsFoManager

-(AINetAbsFoNode*) create:(NSArray*)conFos orderSames:(NSArray*)orderSames{
    BOOL eatFood = false;
    if (orderSames.count == 2) {
        AIKVPointer *eatAlg_p = ARR_INDEX(orderSames, 1);
        AIKVPointer *foodAlg_p = ARR_INDEX(orderSames, 0);
        AIAlgNodeBase *foodAlg = [SMGUtils searchNode:foodAlg_p];
        
        if ([NVHeUtil isHeight:5 fromContent_ps:foodAlg.content_ps]) {
            if ([EAT_RDS isEqualToString:eatAlg_p.dataSource]) {
                NSLog(@"构建'吃坚果'时序");
                eatFood = true;
            }
        }
    }
    
    //1. 数据准备
    if (!ARRISOK(conFos)) {
        return nil;
    }
    orderSames = ARRTOOK(orderSames);
    NSString *samesStr = [SMGUtils convertPointers2String:orderSames];
    NSString *samesMd5 = STRTOOK([NSString md5:samesStr]);
    
    //2. 判断algA.absPorts和absB.absPorts中的header,是否已存在algSames的抽象节点;
    AINetAbsFoNode *findAbsNode = nil;
    NSMutableArray *allAbsPorts = [[NSMutableArray alloc] init];
    for (AIFoNodeBase *conItem in conFos) {
        ///1. 收集硬盘absPorts;
        [allAbsPorts addObjectsFromArray:conItem.absPorts];
        ///2. 收集内存memAbsPorts;
        NSArray *memAbsPorts = [SMGUtils searchObjectForPointer:conItem.pointer fileName:kFNMemAbsPorts time:cRTPort_All(conItem.pointer.isMem)];
        [allAbsPorts addObjectsFromArray:memAbsPorts];
    }
    for (AIPort *port in allAbsPorts) {
        if ([samesMd5 isEqualToString:port.header]) {
            findAbsNode = [SMGUtils searchNode:port.target_p];
            if (findAbsNode.pointer.isMem) {
                ///3. 转移foNode到硬盘网络;
                findAbsNode = [AINetUtils move2HdNodeFromMemNode_Fo:findAbsNode];
                NSLog(@"检查!!!!,此处对findAbsFo做内存到硬盘网络的转移!!!");
                if (findAbsNode.content_ps.count == 0) {
                    NSLog(@"警告...fo.orders为空");
                }
            }
            break;
        }
    }
    
    //3. 无则创建
    if (!findAbsNode) {
        findAbsNode = [[AINetAbsFoNode alloc] init];
        findAbsNode.pointer = [SMGUtils createPointerForNode:kPN_FO_ABS_NODE];
        
        ///1. 收集order_ps (将不在hdNet中的转移)
        for (AIKVPointer *item_p in orderSames) {
            if (item_p.isMem) {
                AIAlgNodeBase *memAlgNode = [SMGUtils searchNode:item_p];
                
                ///2. 转移memAlgNode到硬盘网络;
                AIAlgNodeBase *hdAlgNode = [AINetUtils move2HdNodeFromMemNode_Alg:memAlgNode];
                
                ///3. 收集order_p
                if (hdAlgNode) {
                    [findAbsNode.content_ps addObject:hdAlgNode.pointer];
                }
            }else{
                ///4. 收集order_p
                [findAbsNode.content_ps addObject:item_p];
            }
        }
        
        //4. order_ps更新概念节点引用序列;
        [AINetUtils insertRefPorts_AllFoNode:findAbsNode.pointer order_ps:findAbsNode.content_ps ps:findAbsNode.content_ps];
    }
    
    //5. 具象节点&抽象节点_关联&存储
    [AINetUtils relateFoAbs:findAbsNode conNodes:conFos];
    if (eatFood) {
        [theNV setNodeData:findAbsNode.pointer lightStr:@"果-吃"];
    }
    return findAbsNode;
}

@end
