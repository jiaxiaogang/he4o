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
#import "AINetIndexUtils.h"

@implementation AIAbsFoManager

/**
 *  MARK:--------------------在foNode基础上构建抽象--------------------
 *  @version
 *      2020.08.18: 支持deltaTimes (抽象时序的deltaTime全部由conFos得出,参考:20201);
 *      2021.01.03: 判断abs已存在抽象节点时,加上ATDS的匹配判断,因为不同类型节点不必去重 (参考2120B-BUG2);
 */
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
        if ([samesMd5 isEqualToString:port.header] && [port.target_p.dataSource isEqualToString:ds]) {
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
    
    //4. 具象节点&抽象节点_关联 & 存储;
    [AINetUtils relateFoAbs:findAbsNode conNodes:conFos isNew:isNew];
    
    //5. 提取findAbsNode的deltaTimes & 存储;
    findAbsNode.deltaTimes = [AINetAbsFoUtils getDeltaTimes:conFos absFo:findAbsNode];
    
    [SMGUtils insertNode:findAbsNode];
    return findAbsNode;
}

/**
 *  MARK:--------------------构建fo_防重版--------------------
 *  @callers : 被外类比构建器调用;
 *  @功能说明: 1. 未支持内存去重;
 *  @param difStrong : 构建fo的被引用初始强度;
 *  @version
 *      2020.04.26: 去掉时序的全局去重;
 *      2021.04.25: 打开防重,仅对content_ps防重,但没有对ds做同区要求判断 (参考23054-疑点);
 *      2021.04.25: 把ThinkingUtils.createAbsFo_NoRepeat_General()搬至此处;
 *  @status
 *      2021.04.25: 打开后,gl经验全为0条,所以先关掉,后续测试打开后为什么为0条;
 */
-(AINetAbsFoNode*) create_NoRepeat:(NSArray*)conFos content_ps:(NSArray*)content_ps difStrong:(NSInteger)difStrong ds:(NSString*)ds{
    //1. 数据准备
    BOOL switch = false;//开关
    AINetAbsFoNode *result = nil;
    if (ARRISOK(conFos) && ARRISOK(content_ps)) {
        //2. 获取绝对匹配;
        AIFoNodeBase *absoluteFo = nil;
        if (switch) absoluteFo = [AINetIndexUtils getAbsoluteMatching_General:content_ps sort_ps:content_ps except_ps:Nodes2Pits(conFos) getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
            AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
            return [AINetUtils refPorts_All4Alg:itemAlg];
        } ds:ds];
        
        //3. 有则加强 (防重开关);
        if (ISOK(absoluteFo, AINetAbsFoNode.class)) {
            result = (AINetAbsFoNode*)absoluteFo;
            [AINetUtils relateFoAbs:result conNodes:conFos isNew:false];
            [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
        }else{
            //4. 无则构建
            result = [self create:conFos orderSames:content_ps difStrong:difStrong dsBlock:^NSString *{
                return ds;
            }];
        }
    }
    return result;
}

//+(AIFrontOrderNode*)createConFo_NoRepeat_General:(NSArray*)content_ps isMem:(BOOL)isMem{
//    //1. 数据准备
//    AIFrontOrderNode *result = nil;
//    if (ARRISOK(content_ps)) {
//2. 获取绝对匹配;
//AIFoNodeBase *localFo = [AINetIndexUtils getAbsoluteMatching_General:content_ps sort_ps:content_ps except_ps:nil getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
//    AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
//    return [AINetUtils refPorts_All4Alg:itemAlg];
//} ds:ds];
//        //2. 有则加强;
//        if (ISOK(localFo, AIFrontOrderNode.class)) {
//            result = (AIFrontOrderNode*)localFo;
//            [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
//        }else{
//            //3. 无则构建
//            result = [theNet createConFo:content_ps isMem:isMem];
//        }
//    }
//    return result;
//}

@end
