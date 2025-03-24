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
+(AIGroupValueNode*) createGroupValueNode:(NSArray*)subDots conNodes:(NSArray*)conNodes at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut {
    NSArray *content_ps = [SMGUtils convertArr:subDots convertBlock:^id(MapModel *obj) {
        return obj.v1;
    }];
    NSArray *xs = [SMGUtils convertArr:subDots convertBlock:^id(MapModel *obj) {
        return obj.v2;
    }];
    NSArray *ys = [SMGUtils convertArr:subDots convertBlock:^id(MapModel *obj) {
        return obj.v3;
    }];
    return [AIGeneralNodeCreater createNode:content_ps conNodes:conNodes at:at ds:ds isOut:isOut newBlock:^id{
        AIGroupValueNode *newNode = [[AIGroupValueNode alloc] init];
        newNode.pointer = [SMGUtils createPointerForGroupValue:at dataSource:ds isOut:isOut];
        newNode.xs = xs;
        newNode.ys = ys;
        return newNode;
    } header:nil];
}

/**
 *  MARK:--------------------构建特征--------------------
 *  @version
 *      2025.03.19: 支持构建特征，由多个稀疏码（单码或组码）组成。
 *  @result notnull
 */
+(AIFeatureNode*) createFeatureNode:(NSArray*)groupModels conNodes:(NSArray*)conNodes at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut logDesc:(NSString*)logDesc {
    //2. 数据准备：转content_ps。
    NSArray *content_ps = [SMGUtils convertArr:groupModels convertBlock:^id(InputGroupValueModel *obj) {
        return obj.groupValue_p;
    }];
    NSArray *levels = [SMGUtils convertArr:groupModels convertBlock:^id(InputGroupValueModel *obj) {
        return @(obj.level);
    }];
    NSArray *xs = [SMGUtils convertArr:groupModels convertBlock:^id(InputGroupValueModel *obj) {
        return @(obj.x);
    }];
    NSArray *ys = [SMGUtils convertArr:groupModels convertBlock:^id(InputGroupValueModel *obj) {
        return @(obj.y);
    }];
    
    //3. 生成node
    //注意：即使content_ps一模一样，level,x,y不一样时，一样不可以复用（所以要把level,x,y生成一个字符串也用于生成header）。
    NSString *header = [AINetUtils getFeatureNodeHeader:content_ps levels:levels xs:xs ys:ys];
    
    //4. 构建节点
    AIFeatureNode *result = [AIGeneralNodeCreater createNode:content_ps conNodes:conNodes at:at ds:ds isOut:isOut newBlock:^id{
        AIFeatureNode *newNode = [[AIFeatureNode alloc] init];
        newNode.pointer = [SMGUtils createPointerForFeature:at dataSource:ds isOut:isOut];
        
        //5. 单独存level,x,y值。
        newNode.levels = levels;
        newNode.xs = xs;
        newNode.ys = ys;
        newNode.logDesc = logDesc;
        return newNode;
    } header:header];
    return result;
}

/**
 *  MARK:--------------------通用节点构建器--------------------
 *  @param content_ps     : 要构建Node的content_ps (稀疏码组) notnull;
 *  @param conNodes      : 具象Node数组（可为空）。
 *  @param ds           : 为nil时,默认为DefaultDataSource;
 *  @result notnull
 */
+(id) createNode:(NSArray*)content_ps conNodes:(NSArray*)conNodes at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut newBlock:(id(^)())newBlock header:(NSString*)header {
    //1. 数据检查
    content_ps = ARRTOOK(content_ps);
    if (!at) at = DefaultAlgsType;
    if (!ds) ds = DefaultDataSource;
    if (!STRISOK(header)) header = [NSString md5:[SMGUtils convertPointers2String:content_ps]];
    NSMutableArray *validConAlgs = [[NSMutableArray alloc] initWithArray:conNodes];
    AINodeBase *result = nil;
    
    //2. 去重找本地 (仅抽象);
    AINodeBase *localResult = [AINetIndexUtils getAbsoluteMatching_ValidPs:content_ps findHeader:header except_ps:nil noRepeatArea_ps:nil getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
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
        if ([checkNode.pointer.algsType isEqualToString:at] && [checkNode.pointer.dataSource isEqualToString:ds] && [header isEqualToString:checkNode.getHeaderNotNull]) {
            
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
                if ([header isEqualToString:absPort.header] && [absPort.target_p.algsType isEqualToString:at] && [absPort.target_p.dataSource isEqualToString:ds]) {
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
        
        //7. 存header到node
        result.header = header;
        
        //8. 概念是否交层,可以使用长度来判断 (有一条conAlg为交层 或 当前sames长度小于具象特征数 => 则当前为交层) (参考33111-TODO1);
        result.pointer.isJiao = [SMGUtils filterSingleFromArr:conNodes checkValid:^BOOL(AIAlgNodeBase *item) {
            return item.pointer.isJiao || content_ps.count < item.count;
        }];
        
        [result setContent_ps:content_ps];
        //NSLog(@"构建新码:%@%ld fromConAlgs:%@",NSStringFromClass(result.class),result.pointer.pointerId,CLEANSTR([SMGUtils convertArr:conNodes convertBlock:^id(AINodeBase *obj) {
        //    return STRFORMAT(@"%@%ld",NSStringFromClass(obj.class),obj.pId);
        //}]));
    }
    
    //11. 关联 & 存储
    [AINetUtils relateGeneralAbs:result absConPorts:result.conPorts conNodes:validConAlgs isNew:absIsNew difStrong:1];
    [SMGUtils insertNode:result];
    
    //12. value.refPorts (更新/加强微信息的引用序列)
    [AINetUtils insertRefPorts_General:result.pointer content_ps:result.content_ps difStrong:1 header:header];
    return result;
}

@end
