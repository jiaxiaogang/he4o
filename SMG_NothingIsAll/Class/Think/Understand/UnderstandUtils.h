//
//  UnderstandUtils.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnderstandUtils : NSObject

/**
 *  MARK:--------------------从text中找出生分词和已有分词--------------------
 *  @param  text:查找目标字符串
 *  @param  forceWordArr:句子中已知的词
 *  @param  outBlock:结果回调函数
 *  @params oldWordArr:本来就有的词
 *  @params newWordArr:新发现的词
 *  @params unknownCount:不认识的字符数
 */
+(void) getWordArrAtText:(NSString*)text forceWordArr:(NSArray*)forceWordArr outBlock:(void(^)(NSArray *oldWordArr,NSArray *newWordArr ,NSInteger unknownCount))outBlock;





/**
 *  MARK:--------------------从'记忆'中找到需要'理解'处理的数据--------------------
 *  value:中的元素数据格式:{unknowObjArr=[@"2",@"3"],unknowDoArr=[@"2",@"3"],unknowWordArr=[@"苹果",@"吃"]}
 */
+(NSMutableArray*) getNeedUnderstandMemoryWithObjId:(NSString*)objId;
+(NSMutableArray*) getNeedUnderstandMemoryWithDoId:(NSString*)doId;
+(NSMutableArray*) getNeedUnderstandMemoryWithMemArr:(NSMutableArray*)memArr;//获取需要理解的memArr(未理解的元素<=3 && 句子分词完整)

@end
