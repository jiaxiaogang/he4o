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
 */
+(void) getWordArrAtText:(NSString*)text outBlock:(void(^)(NSArray *oldWordArr,NSArray *newWordArr))outBlock;





/**
 *  MARK:--------------------从'记忆'中找到需要'理解'处理的数据--------------------
 *  value:中的元素数据格式:{unknowObjArr=[@"2",@"3"],unknowDoArr=[@"2",@"3"],unknowWordArr=[@"苹果",@"吃"]}
 */
+(NSMutableArray*) getNeedUnderstandMemoryWithObjId:(NSString*)objId;
+(NSMutableArray*) getNeedUnderstandMemoryWithDoId:(NSString*)doId;
+(NSMutableArray*) getNeedUnderstandMemoryWithMemArr:(NSMutableArray*)memArr;//获取需要理解的memArr(未理解的元素<=3 && 句子分词完整)

@end
