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

//temp
#import "NVHeUtil.h"

@implementation AIAbsFoManager

-(AINetAbsFoNode*) create:(NSArray*)conFos orderSames:(NSArray*)orderSames difStrong:(NSInteger)difStrong dsBlock:(NSString*(^)())dsBlock{
    //1. 数据准备
    NSString *ds = dsBlock ? dsBlock() : DefaultDataSource;
    if (!ARRISOK(conFos)) return nil;
    orderSames = ARRTOOK(orderSames);
    NSString *samesStr = [SMGUtils convertPointers2String:orderSames];
    NSString *samesMd5 = STRTOOK([NSString md5:samesStr]);
    
    //2. 判断algA.absPorts和absB.absPorts中的header,是否已存在algSames的抽象节点;
    AINetAbsFoNode *findAbsNode = nil;
    NSMutableArray *allAbsPorts = [[NSMutableArray alloc] init];
    for (AIFoNodeBase *conItem in conFos) {
        [allAbsPorts addObjectsFromArray:[AINetUtils absPorts_All:conItem]];
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
    BOOL isNew = false;
    if (!findAbsNode) {
        isNew = true;
        findAbsNode = [[AINetAbsFoNode alloc] init];
        findAbsNode.pointer = [SMGUtils createPointerForFo:kPN_FO_ABS_NODE ds:ds];
        
        //3. 收集order_ps (将不在hdNet中的转移)
        findAbsNode.content_ps = [AINetUtils move2Hd4Alg_ps:orderSames];
        
        //4. order_ps更新概念节点引用序列;
        [AINetUtils insertRefPorts_AllFoNode:findAbsNode.pointer order_ps:findAbsNode.content_ps ps:findAbsNode.content_ps difStrong:difStrong];
    }
    
    //5. 具象节点&抽象节点_关联&存储
    [AINetUtils relateFoAbs:findAbsNode conNodes:conFos isNew:isNew];
    return findAbsNode;
}

@end
