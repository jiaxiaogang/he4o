//
//  LanguageUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageUtils : NSObject

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
+(NSArray*) getUnknownWordCount:(NSArray*)knowRangeArr fromIndex:(NSInteger)fromIndex withSentence:(NSString*)sentence;

@end
