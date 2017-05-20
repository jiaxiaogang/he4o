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
 *  @params  text:查找目标字符串
 *  @params  forceWordArr:句子中已知的词
 *  @params  outBlock:结果回调函数
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



/**
 *  MARK:--------------------预判词--------------------
 *  参数:
 *      1,limit:取几个
 *      2,havThan:有没达到多少个结果
 *
 *  注:
 *      1,目前仅支持用"一刀两"推出"一刀两断"从前至后预判;
 *      2,词本身不作数 如:"计算" 只能判出"计算机"不能返回"计算";
 */
-(void) getInferenceWord:(NSString*)str withLimit:(NSInteger)limit withHavThan:(NSInteger)havThan withOutBlock:(void(^)(NSMutableArray *valueWords,BOOL havThan))outBlock;


@end
