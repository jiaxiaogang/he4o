//
//  HeLogUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/14.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HeLogUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation HeLogUtil

/**
 *  MARK:--------------------filter--------------------
 */
+(NSArray*) filterByTime:(NSString*)startT endT:(NSString*)endT checkDatas:(NSArray*)checkDatas{
    //1. 转换startT和endT的时间戳;
    checkDatas = ARRTOOK(checkDatas);
    long long startTime = [SMGUtils timestampFromStr_yyyyMMddHHmmssSSS:startT defaultResult:0];
    long long endTime = [SMGUtils timestampFromStr_yyyyMMddHHmmssSSS:endT defaultResult:LONG_LONG_MAX];
    
    //2. 找起始index
    NSInteger startIndex = checkDatas.count;
    NSInteger endIndex = -1;
    for (NSInteger i = 0; i < checkDatas.count; i++) {
        NSDictionary *item = checkDatas[i];
        long long itemTime = [NUMTOOK([item objectForKey:kTime]) longLongValue];
        if (itemTime >= startTime && startIndex == checkDatas.count) {
            startIndex = i;
        }
        if (itemTime == endTime) {
            endIndex = i;
        }else if(itemTime < endTime){
            endIndex = i - 1;
        }
    }
    
    //3. 截取
    NSInteger length = endIndex - startIndex + 1;
    return ARR_SUB(checkDatas, startIndex,length);
}

+(NSArray*) filterByKeyword:(NSString*)keyword checkDatas:(NSArray*)checkDatas{
    //1. 数据准备
    checkDatas = ARRTOOK(checkDatas);
    if (!STRISOK(keyword)) {
        return checkDatas;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *sep = @"&";
    NSArray *kws = STRTOARR(keyword, sep);
    
    //2. 筛选
    for (NSDictionary *item in checkDatas) {
        NSString *log = [item objectForKey:kLog];
        
        //3. 判断包含所有关键字:kws
        BOOL contains = true;
        for (NSString *kw in kws) {
            if (![log containsString:kw]) {
                contains = false;
                break;
            }
        }
        if (contains) {
            [result addObject:item];
        }
    }
    return result;
}

/**
 *  MARK:--------------------数据的标识--------------------
 *  @version
 *      xxxx.xx.xx: 初版: 使用md5=> STRTOOK([HeLogUtil md5ByData:OBJ2DATA(datas)]);
 *      2022.06.05: v2使用末位时间戳;
 *  @result notnull;
 */
+(NSString*) idenByData:(NSMutableArray*)datas{
    NSDictionary *lastDic = DICTOOK(ARR_INDEX_REVERSE(datas, 0));
    long long lastTime = [NUMTOOK([lastDic objectForKey:kTime]) longLongValue];
    return STRFORMAT(@"%lld",lastTime);
}

+(NSString *)md5ByData:(NSData*)data{
    //1: 创建一个MD5对象
    CC_MD5_CTX md5;
    //2: 初始化MD5
    CC_MD5_Init(&md5);
    //3: 准备MD5加密
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    //4: 准备一个字符串数组, 存储MD5加密之后的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //5: 结束MD5加密
    CC_MD5_Final(result, &md5);
    NSMutableString *resultString = [NSMutableString string];
    //6:从result数组中获取最终结果
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X", result[i]];
    }
    return resultString;
}

//返回demand打日志时的pointer
+(AIKVPointer*) demandLogPointer:(DemandModel*)demand {
    if (ISOK(demand, ReasonDemandModel.class)) {
        ReasonDemandModel *rDemand = (ReasonDemandModel*)demand;
        return rDemand.protoOrRegroupFo;//R返回protoFo;
    } else if (ISOK(demand, HDemandModel.class)) {
        HDemandModel *hDemand = (HDemandModel*)demand;
        return hDemand.baseOrGroup.content_p;//H返回targetAlg.content_p
    }
    return nil;
}

//缩进的前辍,每缩进单位两个空字符;
+(NSString*) getPrefixStr:(int)prefixNum {
    NSString *spaceStr = @"";
    for (int i = 0; i < prefixNum; i++) {
        spaceStr = STRFORMAT(@"%@  ",spaceStr);
    }
    return STRFORMAT(@"%@%@ ",spaceStr,[TOModelVisionUtil getUnorderPrefix:prefixNum]);
}

@end
