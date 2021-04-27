//
//  AINetIndexUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/31.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AINetIndexUtils.h"
#import "NSString+Extension.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "AIAlgNodeBase.h"

@implementation AINetIndexUtils

//MARK:===============================================================
//MARK:                     < 概念绝对匹配 >
//MARK:===============================================================
//+(id) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p{
//    if (value_p) {
//        return [self getAbsoluteMatchingAlgNodeWithValuePs:@[value_p]];
//    }
//    return nil;
//}
//+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps{
//    AIAlgNodeBase *result = [self getAbsoluteMatchingAlgNodeWithValuePs:value_ps except_ps:nil isMem:true];
//    if (!result) {
//        result = [self getAbsoluteMatchingAlgNodeWithValuePs:value_ps except_ps:nil isMem:false];
//    }
//    return result;
//}
//+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps except_ps:(NSArray*)except_ps isMem:(BOOL)isMem {
//    //1. 取数据;
//    except_ps = ARRTOOK(except_ps);
//    NSArray *sort_ps = [SMGUtils sortPointers:value_ps];
//
//    //2. 执行并返回;
//    return [self getAbsoluteMatching_General:value_ps sort_ps:sort_ps except_ps:except_ps getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
//        return ARRTOOK([SMGUtils searchObjectForFilePath:item_p.filePath fileName:kFNRefPorts_All(isMem) time:cRTReference_All(isMem)]);
//    }];
//}


//MARK:===============================================================
//MARK:                     < 绝对匹配 (概念/时序) 通用方法 >
//MARK:===============================================================

/**
 *  MARK:--------------------alg/fo 绝对匹配通用方法--------------------
 *  @version
 *      2021.04.25: 支持ds同区判断 (参考23054-疑点);
 *      2021.04.27: 修复因ds为空时默认dsSeem为true逻辑错误,导致alg防重失败,永远返回nil的BUG;
 */
+(id) getAbsoluteMatching_General:(NSArray*)content_ps sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps getRefPortsBlock:(NSArray*(^)(AIKVPointer *item_p))getRefPortsBlock ds:(NSString*)ds{
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
            BOOL dsSeem = STRISOK(ds) ? [ds isEqualToString:refPort.target_p.dataSource] : true;
            
            //6. ds同区 & 将md5匹配header & 不在except_ps的找到并返回;
            if (dsSeem && ![except_ps containsObject:refPort.target_p] && [md5 isEqualToString:refPort.header]) {
                return [SMGUtils searchNode:refPort.target_p];
            }
        }
    }
    return nil;
}

@end
