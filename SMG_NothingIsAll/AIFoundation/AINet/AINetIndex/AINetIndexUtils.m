//
//  AINetIndexUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/31.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AINetIndexUtils.h"
#import "NSString+Extension.h"

@implementation AINetIndexUtils


//MARK:===============================================================
//MARK:                     < 绝对匹配 (概念/时序) 通用方法 >
//MARK:===============================================================

/**
 *  MARK:--------------------alg/fo 绝对匹配通用方法--------------------
 *  @version
 *      2021.04.25: 支持ds同区判断 (参考23054-疑点);
 *      2021.04.27: 修复因ds为空时默认dsSeem为true逻辑错误,导致alg防重失败,永远返回nil的BUG;
 *      2021.09.22: 支持type防重;
 */
+(id) getAbsoluteMatching_General:(NSArray*)content_ps sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps getRefPortsBlock:(NSArray*(^)(AIKVPointer *item_p))getRefPortsBlock at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type{
    return [self getAbsoluteMatching_ValidPs:content_ps sort_ps:sort_ps except_ps:except_ps noRepeatArea_ps:nil getRefPortsBlock:getRefPortsBlock at:at ds:ds type:type];
}

/**
 *  MARK:--------------------绝对匹配 + 限定范围--------------------
 *  @param noRepeatArea_ps 限定范围: 结果必须从valid_ps中找 (限定范围时不得传nil,不限定时直接传nil即可);
 */
+(id) getAbsoluteMatching_ValidPs:(NSArray*)content_ps sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps noRepeatArea_ps:(NSArray*)noRepeatArea_ps getRefPortsBlock:(NSArray*(^)(AIKVPointer *item_p))getRefPortsBlock at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type{
    //1. 数据检查
    if (!getRefPortsBlock) return nil;
    content_ps = ARRTOOK(content_ps);
    NSString *md5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:sort_ps]]);
    except_ps = ARRTOOK(except_ps);
    
    //2. 依次找content_ps的被引用序列,并判断header匹配;
    for (AIKVPointer *item_p in content_ps) {
        //3. 取refPorts;
        NSArray *refPorts = ARRTOOK(getRefPortsBlock(item_p));
        
        //4. 判定refPort.header是否一致;
        for (AIPort *refPort in refPorts) {
            //5. ds防重 (ds无效时,默认为true);
            BOOL atSeem = STRISOK(at) ? [at isEqualToString:refPort.target_p.algsType] : true;
            BOOL dsSeem = STRISOK(ds) ? [ds isEqualToString:refPort.target_p.dataSource] : true;
            BOOL typeSeem = type == refPort.target_p.type;
            
            //6. ds同区 & 将md5匹配header & 不在except_ps的找到并返回;
            if (atSeem && dsSeem && typeSeem && ![except_ps containsObject:refPort.target_p] && [md5 isEqualToString:refPort.header]) {
                
                //7. 当valid_ps不为空时,要求必须包含在valid_ps中;
                if (noRepeatArea_ps) {
                    if ([noRepeatArea_ps containsObject:refPort.target_p]) {
                        return [SMGUtils searchNode:refPort.target_p];
                    }
                }else {
                    return [SMGUtils searchNode:refPort.target_p];
                }
            }
        }
    }
    return nil;
}

/**
 *  MARK:--------------------从指定范围中获取绝对匹配--------------------
 *  @param validPorts : 指定范围域;
 *  @version
 *      2021.09.23: 指定范围获取绝对匹配,也要判断type类型 (但有时传入的validPorts本来就是已筛选过type的) (参考24019);
 */
+(id) getAbsoluteMatching_ValidPorts:(NSArray*)validPorts sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type{
    //1. 数据检查
    NSString *md5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:sort_ps]]);
    except_ps = ARRTOOK(except_ps);
    
    //2. 从指定的validPorts中依次找header匹配;
    for (AIPort *validPort in validPorts) {
        //5. ds防重 (ds无效时,默认为true);
        BOOL atSeem = STRISOK(at) ? [at isEqualToString:validPort.target_p.algsType] : true;
        BOOL dsSeem = STRISOK(ds) ? [ds isEqualToString:validPort.target_p.dataSource] : true;
        BOOL typeSeem = type == validPort.target_p.type;
        
        //6. ds同区 & 将md5匹配header & 不在except_ps的找到并返回;
        if (atSeem && dsSeem && typeSeem && ![except_ps containsObject:validPort.target_p] && [md5 isEqualToString:validPort.header]) {
            return [SMGUtils searchNode:validPort.target_p];
        }
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < 索引序列 >
//MARK:===============================================================
/**
 *  MARK:--------------------索引序列--------------------
 *  @desc 取现有索引序列 (无则新建);
 *  @version
 *      2023.07.19: 因为索引序列为空,导致闪退问题 (检查索引fnIndexArr不得为空);
 *  @result notnull
 */
+(AINetIndexModel*) searchIndexModel:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut{
    //1. 取出所有索引序列;
    NSArray *fnIndexArr = ARRTOOK([SMGUtils searchObjectForPointer:[SMGUtils createPointerForIndex] fileName:kFNIndex(isOut) time:cRTIndex]);
    NSMutableArray *indexModels = [[NSMutableArray alloc] initWithArray:fnIndexArr];
    
    //2. 找出同标识相符的;
    AINetIndexModel *model = ARR_INDEX([SMGUtils filterArr:indexModels checkValid:^BOOL(AINetIndexModel *item) {
        return [item.algsType isEqualToString:at] && [item.dataSource isEqualToString:ds];
    }], 0);
    
    //3. 找不到则新建
    if (model == nil) {
        model = [[AINetIndexModel alloc] init];
        model.algsType = at;
        model.dataSource = ds;
        [indexModels addObject:model];
    }
    return model;
}

+(void) insertIndexModel:(AINetIndexModel*)model isOut:(BOOL)isOut{
    //1. 取出所有索引序列;
    NSMutableArray *models = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:[SMGUtils createPointerForIndex] fileName:kFNIndex(isOut) time:cRTIndex]];
    
    //2. 将旧同标识model移除;
    models = [SMGUtils filterArr:models checkValid:^BOOL(AINetIndexModel *item) {
        return ![item.dataSource isEqualToString:model.dataSource] || ![item.algsType isEqualToString:model.algsType];
    }];
    
    //3. 将新的model加入;
    [models addObject:model];
    
    //4. 存新models;
    [SMGUtils insertObject:models pointer:[SMGUtils createPointerForIndex] fileName:kFNIndex(isOut) time:cRTIndex];
}

/**
 *  MARK:--------------------稀疏码值字典--------------------
 *  @result notnull
 */
+(NSDictionary*) searchDataDic:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut{
    return DICTOOK([SMGUtils searchObjectForPointer:[SMGUtils createPointerForData:at dataSource:ds isOut:isOut] fileName:kFNData(isOut) time:cRTData]);
}

+(void) insertDataDic:(NSDictionary*)dataDic at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut{
    [SMGUtils insertObject:DICTOOK(dataDic) pointer:[SMGUtils createPointerForData:at dataSource:ds isOut:isOut] fileName:kFNData(isOut) time:cRTData];
}

/**
 *  MARK:--------------------取两个V差值--------------------
 *  @param vInfo notnull 为性能好,提前取好valueInfo传过来复用;
 */
+(CGFloat) deltaWithValueA:(double)valueA valueB:(double)valueB at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut vInfo:(AIValueInfo*)vInfo {
    //1. 计算两个V差值;
    double delta = fabs(valueA - valueB);
    
    //2. 如果是循环V时,正反取小;
    if (vInfo.loop && delta > (vInfo.span / 2)) {
        delta = vInfo.max - delta;
    }
    return delta;
}

@end
