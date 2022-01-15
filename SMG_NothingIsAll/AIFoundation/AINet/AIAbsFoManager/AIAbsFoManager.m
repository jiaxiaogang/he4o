//
//  AINetAbs.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsFoManager.h"
#import "AIMvFoManager.h"
#import "AINetAbsFoUtils.h"

@implementation AIAbsFoManager

/**
 *  MARK:--------------------在foNode基础上构建抽象--------------------
 *  @params conFos      : 具象节点们 (外类比时,传入foA和foB) (内类比时传入baseFo即可)
 *  @params orderSames  : algNode组
 *  注: 转移: 仅概念支持内存网络向硬盘网络的转移,fo不进行转移;
 *
 *  @version
 *      2020.08.18: 支持deltaTimes (抽象时序的deltaTime全部由conFos得出,参考:20201);
 *      2021.01.03: 判断abs已存在抽象节点时,加上ATDS的匹配判断,因为不同类型节点不必去重 (参考2120B-BUG2);
 *  @result : notnull
 */
-(AINetAbsFoNode*) create:(NSArray*)conFos orderSames:(NSArray*)orderSames difStrong:(NSInteger)difStrong at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type{
    //1. 数据准备
    if(!at) at = DefaultAlgsType;
    if(!ds) ds = DefaultDataSource;
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
        if ([samesMd5 isEqualToString:port.header] && [port.target_p.algsType isEqualToString:at] && [port.target_p.dataSource isEqualToString:ds] && port.target_p.type == type) {
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
        findAbsNode.pointer = [SMGUtils createPointerForFo:kPN_FO_ABS_NODE at:at ds:ds type:type];
        
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
    [AITest test7:findAbsNode.content_ps type:type];
    [AITest test8:findAbsNode.content_ps type:type];
    return findAbsNode;
}

/**
 *  MARK:--------------------构建fo_防重版--------------------
 *  @callers : 被外类比构建器调用;
 *  @功能说明: 1. 未支持内存去重;
 *  @param difStrong : 构建fo的被引用初始强度;
 *  @param ds : 新构建时传入指定ds,尤其是GL类型时,一般要将value.dataSource传递过来 (参考24019-概念部分);
 *              非新构建时,可传nil,此时尝试从conFos继承获取 (如果它们有共同的ds);
 *  @version
 *      2020.04.26: 去掉时序的全局去重;
 *      2021.04.25: 打开防重,仅对content_ps防重,但没有对ds做同区要求判断 (参考23054-疑点);
 *      2021.04.25: 把ThinkingUtils.createAbsFo_NoRepeat_General()搬至此处;
 *      2021.04.28: 修复当content_ps为空时,不构建新时序的BUG (参考23057);
 *      2021.05.22: 对SP类型仅在当时场景下防重 (参考2307b-方案3);
 *      2021.05.23: 对GL类型仅在当前场景下防重 (参考23081);
 *      2021.09.22: fo支持type防重 (参考24019);
 *      2021.09.23: fo支持从conFos中继承ds,如果conFos的ds都相同的话 (参考24019-时序部分);
 *  @status
 *      2021.04.25: 打开后,gl经验全为0条,所以先关掉,后续测试打开后为什么为0条;
 */
-(AINetAbsFoNode*) create_NoRepeat:(NSArray*)conFos content_ps:(NSArray*)content_ps difStrong:(NSInteger)difStrong at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type{
    //1. 数据准备
    conFos = ARRTOOK(conFos);
    content_ps = ARRTOOK(content_ps);
    if(!at) at = DefaultAlgsType;
    if(!ds) ds = DefaultDataSource;
    AINetAbsFoNode *result = nil;
    
    //2. 防重_SP类型时,嵌套范围内绝对匹配;
    if (type == ATSub || type == ATPlus || type == ATGreater || type == ATLess) {
        NSMutableArray *validPorts = [[NSMutableArray alloc] init];
        for (AIFoNodeBase *conItem in conFos) {
            [validPorts addObjectsFromArray:[AINetUtils absPorts_All:conItem type:type]];
        }
        result = [AINetIndexUtils getAbsoluteMatching_ValidPorts:validPorts sort_ps:content_ps except_ps:Nodes2Pits(conFos) at:at ds:ds type:type];
    }else{
        //3. 防重_其它类型时,全局绝对匹配;
        result = [AINetIndexUtils getAbsoluteMatching_General:content_ps sort_ps:content_ps except_ps:Nodes2Pits(conFos) getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
            AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
            return [AINetUtils refPorts_All4Alg:itemAlg];
        } at:at ds:ds type:type];
    }
    
    //3. 有则加强关联;
    if (ISOK(result, AINetAbsFoNode.class)) {
        [AINetUtils relateFoAbs:result conNodes:conFos isNew:false];
        [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
    }else{
        //4. 无则新构建;
        result = [self create:conFos orderSames:content_ps difStrong:difStrong at:at ds:ds type:type];
    }
    return result;
}

@end
