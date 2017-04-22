//
//  LanguageUtils.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "LanguageUtils.h"
#import "SMGHeader.h"

@implementation LanguageUtils

/**
 *  MARK:--------------------获取句子中未知词数--------------------
 *
 *  参数:
 *      1,knowRangeArr: 扫描到的所有词
 *      2,fromIndex:    从哪里开始扫描(正反双向都扫)
 *      3,sentence:     句子
 *
 *  返回值:NSNumber数组
 *
 */
+(NSArray*) getUnknownWordCount:(NSArray*)knowRangeArr fromIndex:(NSInteger)fromIndex withSentence:(NSString*)sentence{
    //数据检查
    NSMutableArray *valueArr = nil;
    
    knowRangeArr = ARRTOOK(knowRangeArr);
    
    fromIndex = MAX(fromIndex, 0);
    fromIndex = MIN(sentence.length - 1, fromIndex);
    
    if (!STRISOK(sentence)) return valueArr;
    
    //向前找
    for (NSUInteger i = fromIndex; i > 0; i--) {
        
    }
    
    //向后找
    for (NSUInteger i = 0; i < knowRangeArr.count; <#increment#>) {
        
    }
    knowRangeArr[0];
    if (knowRangeArr) {
        
    }
}

/**
 *  MARK:--------------------ContainsIndexAtRange--------------------
 */
//RangeArr是否包含Index
+(BOOL) containsIndex:(NSInteger)index atRangeArr:(NSArray*)rangeArr{
    //数据检查
    if (ARRISOK(rangeArr)) {
        for (SMGRange *range in rangeArr) {
            if ([self containsIndex:index atRange:range]) {
                return true;
            }
        }
    }
    return false;
}

//SMGRange是否包含Index
+(BOOL) containsIndex:(NSInteger)index atRange:(SMGRange*)range{
    return (range && index >= range.location && index < range.location + range.length);
}




@end





