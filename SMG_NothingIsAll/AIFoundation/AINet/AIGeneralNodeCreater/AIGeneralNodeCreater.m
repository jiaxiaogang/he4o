//
//  AIGeneralNodeCreater.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/19.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIGeneralNodeCreater.h"

@implementation AIGeneralNodeCreater

/**
 *  MARK:--------------------构建组码--------------------
 *  @version
 *      2025.03.18: 支持构建组码（多个稀疏码组成）。
 *  @result notnull
 */
+(AIGroupValueNode*) createGroupValueNode:(NSArray*)content_ps conNodes:(NSArray*)conNodes at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut {
    return [AIGeneralNodeCreater createNode:content_ps conNodes:conNodes at:at ds:ds isOut:isOut newBlock:^id{
        AIGroupValueNode *newNode = [[AIGroupValueNode alloc] init];
        newNode.pointer = [SMGUtils createPointerForGroupValue:at dataSource:ds isOut:isOut];
        return newNode;
    }];
}

/**
 *  MARK:--------------------构建特征--------------------
 *  @version
 *      2025.03.19: 支持构建特征，由多个稀疏码（单码或组码）组成。
 *  @result notnull
 */
+(AIFeatureNode*) createFeatureNode:(NSDictionary*)groupDic_ps conNodes:(NSArray*)conNodes at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut {
    
    //TODOTOMORROW20250319:
    //1. 此处把key单独解析存为level,x,y值。
    for (NSString *key in groupDic_ps.allKeys) {
        
    }
    //2. 把value按一级level,二级x,三级y排好序再生成content_ps。
    
    NSArray *content_ps = nil;
    
    return [AIGeneralNodeCreater createNode:content_ps conNodes:conNodes at:at ds:ds isOut:isOut newBlock:^id{
        AIFeatureNode *newNode = [[AIFeatureNode alloc] init];
        newNode.pointer = [SMGUtils createPointerForFeature:at dataSource:ds isOut:isOut];
        return newNode;
    }];
}

/**
 *  MARK:--------------------通用节点构建器--------------------
 *  @param content_ps     : 要构建Node的content_ps (稀疏码组) notnull;
 *  @param conNodes      : 具象Node数组（可为空）。
 *  @param ds           : 为nil时,默认为DefaultDataSource;
 *  @result notnull
 */
+(id) createNode:(NSArray*)content_ps conNodes:(NSArray*)conNodes at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut newBlock:(id(^)())newBlock {
    //1. 数据检查
    content_ps = ARRTOOK(content_ps);
    if (!at) at = DefaultAlgsType;
    if (!ds) ds = DefaultDataSource;
    NSString *samesMd5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:content_ps]]);
    NSMutableArray *validConAlgs = [[NSMutableArray alloc] initWithArray:conNodes];
    AINodeBase *result = nil;
    
    //2. 去重找本地 (仅抽象);
    AINodeBase *localResult = [AINetIndexUtils getAbsoluteMatching_General:content_ps sort_ps:content_ps except_ps:nil getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
        return [AINetUtils refPorts_All:item_p];
    } at:at ds:ds type:ATDefault];
    
    //3. 有则加强 并 返回;
    if (localResult) {
        [AINetUtils relateGeneralAbs:localResult absConPorts:localResult.conPorts conNodes:conNodes isNew:false difStrong:1];
        return localResult;
    }
    
    //4. 判断具象节点中,已有一个抽象sames节点,则不需要再构建新的;
    for (AINodeBase *checkNode in conNodes) {
        //b. 并且md5与orderSames相同时,即发现checkNode本身就是抽象节点;
        NSString *checkMd5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:checkNode.content_ps]]);
        if ([samesMd5 isEqualToString:checkMd5] && [checkNode.pointer.algsType isEqualToString:at] && [checkNode.pointer.dataSource isEqualToString:ds]) {
            
            //c. 则把conAlgs去掉checkNode;
            [validConAlgs removeObject:checkNode];
            
            //d. 找到result
            result = checkNode;
        }
    }
    
    //5. 判断具象节点的absPorts中,是否已有一个"sames"节点,有则无需构建新的;
    if (!result) {
        for (AINodeBase *conNode in conNodes) {
            NSArray *absPorts_All = [AINetUtils absPorts_All:conNode];
            for (AIPort *absPort in absPorts_All) {
                //1> 遍历找抽象是否已存在;
                if ([samesMd5 isEqualToString:absPort.header] && [absPort.target_p.algsType isEqualToString:at] && [absPort.target_p.dataSource isEqualToString:ds]) {
                    //3> findAbsNode成功;
                    result = [SMGUtils searchNode:absPort.target_p];
                    break;
                }
            }
        }
    }
    
    //6. 无则创建
    BOOL absIsNew = false;
    if (!result) {
        absIsNew = true;
        result = newBlock();
        
        //4. 概念是否交层,可以使用长度来判断 (有一条conAlg为交层 或 当前sames长度小于具象特征数 => 则当前为交层) (参考33111-TODO1);
        result.pointer.isJiao = [SMGUtils filterSingleFromArr:conNodes checkValid:^BOOL(AIAlgNodeBase *item) {
            return item.pointer.isJiao || content_ps.count < item.count;
        }];
        
        [result setContent_ps:content_ps];
        NSLog(@"构建新码:%@%ld fromConAlgs:%@",NSStringFromClass(result.class),result.pointer.pointerId,CLEANSTR([SMGUtils convertArr:conNodes convertBlock:^id(AINodeBase *obj) {
            return STRFORMAT(@"%@%ld",NSStringFromClass(obj.class),obj.pId);
        }]));
    }
    
    //4. value.refPorts (更新/加强微信息的引用序列)
    [AINetUtils insertRefPorts_General:result.pointer content_ps:result.content_ps difStrong:1 needSort:false];
    
    //5. 关联 & 存储
    [AINetUtils relateGeneralAbs:result absConPorts:result.conPorts conNodes:validConAlgs isNew:absIsNew difStrong:1];
    [SMGUtils insertNode:result];
    return result;
}

@end
