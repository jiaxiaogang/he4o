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
 *  @params orderSames  : algNode组
 *  注: 转移: 仅概念支持内存网络向硬盘网络的转移,fo不进行转移;
 *
 *  @version
 *      2020.08.18: 支持deltaTimes (抽象时序的deltaTime全部由conFos得出,参考:20201);
 *      2021.01.03: 判断abs已存在抽象节点时,加上ATDS的匹配判断,因为不同类型节点不必去重 (参考2120B-BUG2);
 *      2022.12.27: 构建抽象fo时,从源assFo复用contentPort的强度 (参考2722f-todo12);
 *      2023.03.28: 将assFo和absFo是否本来就有关联通过&conAbsIsRelate返回 (参考29032-todo2.1);
 *  @result : notnull
 */
-(AINetAbsFoNode*) create:(NSArray*)orderSames protoFo:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo difStrong:(NSInteger)difStrong at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type conAbsIsRelate:(BOOL*)conAbsIsRelate{
    //1. 数据准备
    NSArray *conFos = @[protoFo,assFo];
    if(!at) at = DefaultAlgsType;
    if(!ds) ds = DefaultDataSource;
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
            break;
        }
    }
    
    //3. 无则创建
    BOOL isNew = false;
    if (!findAbsNode) {
        isNew = true;
        findAbsNode = [[AINetAbsFoNode alloc] init];
        findAbsNode.pointer = [SMGUtils createPointerForFo:kPN_FO_ABS_NODE at:at ds:ds type:type];
        
        //3. content_ps中有一个是交,则fo是交 (参考33111-TODO1);
        findAbsNode.pointer.isJiao = [SMGUtils filterSingleFromArr:orderSames checkValid:^BOOL(AIKVPointer *item) {
            return item.isJiao;
        }];
        
        //3. 收集order_ps
        [findAbsNode setContent_ps:orderSames getStrongBlock:^NSInteger(AIKVPointer *item_p) {
            //4. 复用类比orderSames的assFo中的原content强度 (参考2722f-todo12);
            for (AIPort *port in assFo.contentPorts) {
                if ([port.target_p isEqual:item_p]) return port.strong.value + 1;
            }
            return 1;
        }];
        
        //4. order_ps更新概念节点引用序列;
        [AINetUtils insertRefPorts_AllFoNode:findAbsNode.pointer order_ps:findAbsNode.content_ps ps:findAbsNode.content_ps difStrong:difStrong];
    }
    
    //4. 节点非新的:absFo早就和assFo有关联,否则反之 (参考29032-todo2.1);
    if (conAbsIsRelate) *conAbsIsRelate = !isNew;
    
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
 *  _param ds : 新构建时传入指定ds,尤其是GL类型时,一般要将value.dataSource传递过来 (参考24019-概念部分);
 *              非新构建时,可传nil,此时尝试从conFos继承获取 (如果它们有共同的ds);
 *  @param outConAbsIsRelate : 将con和abs是否本来就有关联返回 (参考29032-todo2.1);
 *  @param noRepeatArea_ps : 结果防重范围
 *  @version
 *      2020.04.26: 去掉时序的全局去重;
 *      2021.04.25: 打开防重,仅对content_ps防重,但没有对ds做同区要求判断 (参考23054-疑点);
 *      2021.04.25: 把ThinkingUtils.createAbsFo_NoRepeat_General()搬至此处;
 *      2021.04.28: 修复当content_ps为空时,不构建新时序的BUG (参考23057);
 *      2021.05.22: 对SP类型仅在当时场景下防重 (参考2307b-方案3);
 *      2021.05.23: 对GL类型仅在当前场景下防重 (参考23081);
 *      2021.09.22: fo支持type防重 (参考24019);
 *      2021.09.23: fo支持从conFos中继承ds,如果conFos的ds都相同的话 (参考24019-时序部分);
 *      2023.03.28: 将两条具象与absFo的indexDic映射传过来 (用于继承sp和eff) (参考29032-todo1);
 *      2023.03.28: 支持判断ass和abs本来无关联时,继承ass的SPEFF (参考29032-todo2.1 & todo2.2);
 *      2023.03.28: 将outConAbsIsRelate返回 (因为只有Canset类比时才更新EFF,需要返回这个值判断) (参考29032-todo2.4);
 *      2024.10.20: 修复Canset类比后,抽象和具象内容一致时,重复构建了两个一模一样的cansetFo (参考33107);
 *  @status
 *      2021.04.25: 打开后,gl经验全为0条,所以先关掉,后续测试打开后为什么为0条;
 */
-(HEResult*) create_NoRepeat:(NSArray*)content_ps protoFo:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo difStrong:(NSInteger)difStrong type:(AnalogyType)type protoIndexDic:(NSDictionary*)protoIndexDic assIndexDic:(NSDictionary*)assIndexDic outConAbsIsRelate:(BOOL*)outConAbsIsRelate noRepeatArea_ps:(NSArray*)noRepeatArea_ps{
    //1. 数据准备
    NSArray *conFos = @[protoFo,assFo];
    NSString *at = DefaultAlgsType; //[AINetUtils getDSFromConNodes:conFos type:type];
    NSString *ds = DefaultDataSource; //[AINetUtils getATFromConNodes:conFos type:type];
    content_ps = ARRTOOK(content_ps);
    AINetAbsFoNode *result = nil;
    
    //2. 防重_SP类型时,嵌套范围内绝对匹配;
    if (type == ATSub || type == ATPlus || type == ATGreater || type == ATLess) {
        NSMutableArray *validPorts = [[NSMutableArray alloc] init];
        for (AIFoNodeBase *conItem in conFos) {
            [validPorts addObjectsFromArray:[AINetUtils absPorts_All:conItem type:type]];
        }
        result = [AINetIndexUtils getAbsoluteMatching_ValidPorts:validPorts sort_ps:content_ps except_ps:nil at:at ds:ds type:type];
    }else{
        //3. 防重_其它类型时,全局绝对匹配;
        result = [AINetIndexUtils getAbsoluteMatching_ValidPs:content_ps sort_ps:content_ps except_ps:nil noRepeatArea_ps:noRepeatArea_ps getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
            AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
            return [AINetUtils refPorts_All4Alg:itemAlg];
        } at:at ds:ds type:type];
    }
    
    //4. 在下面的ifelse中,判断下具象和抽象时序是否本来就有关联 (参考29032-todo2.1);
    BOOL conAbsIsRelate = false;
    
    //5. 有则加强关联;
    BOOL isNew = false;
    if (ISOK(result, AIFoNodeBase.class)) {
        conAbsIsRelate = [Ports2Pits(assFo.absPorts) containsObject:result.pointer];
        [AINetUtils relateFoAbs:result conNodes:conFos isNew:false];
        [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
    }else{
        //6. 无则新构建;
        isNew = true;
        result = [self create:content_ps protoFo:protoFo assFo:assFo difStrong:difStrong at:at ds:ds type:type conAbsIsRelate:&conAbsIsRelate];
    }
    
    //7. 继承sp和eff (参考29032-todo2.2);
    //2024.12.03: 改为仅未抽象过的似层(即AIFrontOrderNode)时,才初始推assFo的spDic给absFo (参考33137-问题2-方案v4);
    if (ISOK(assFo, AIFrontOrderNode.class) && !conAbsIsRelate && ![assFo isEqual:result]) {
        [AINetUtils extendSPByIndexDic:assIndexDic assFo:assFo absFo:result];
    }
    
    //8. 把protoFo给absFo的SP+1 (参考29032-todo2.3);
    [AINetUtils updateSPByIndexDic:protoIndexDic conFo:protoFo absFo:result];
    
    //9. 存下conFo与absFo的indexDic (参考29032-todo3);
    [protoFo updateIndexDic:result indexDic:protoIndexDic];
    [assFo updateIndexDic:result indexDic:assIndexDic];
    
    //10. 存储protoFo与matchFo之间的匹配度 (参考33143-方案1);
    CGFloat protoAbsMatchValue = [AINetUtils getMatchByIndexDic:protoIndexDic absFo:result.p conFo:protoFo.p callerIsAbs:false];
    CGFloat assAbsMatchValue = [AINetUtils getMatchByIndexDic:assIndexDic absFo:result.p conFo:assFo.p callerIsAbs:false];
    [protoFo updateMatchValue:result matchValue:protoAbsMatchValue];
    [assFo updateMatchValue:result matchValue:assAbsMatchValue];
    
    //10. 将结果outConAbsIsRelate和absFo返回;
    if (outConAbsIsRelate) *outConAbsIsRelate = conAbsIsRelate;
    return [[[HEResult newSuccess] mkData:result] mkIsNew:@(isNew)];
}

@end
