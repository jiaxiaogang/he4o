//
//  AIFilter.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/2/25.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------过滤器 (参考28109-todo1)--------------------
 */
@interface AIFilter : NSObject

/**
 *  MARK:--------------------概念识别过滤器 (参考28109-todo2)--------------------
 */
+(NSArray*) recognitonAlgFilter:(NSArray*)matchAlgModels;

/**
 *  MARK:--------------------时序识别过滤器 (参考28111-todo1)--------------------
 */
+(NSArray*) recognitonFoFilter:(NSArray*)matchModels;

/**
 *  MARK:--------------------Canset识别过滤器 (参考29042)--------------------
 */
+(NSArray*) recognitonCansetFilter:(NSArray*)matchModels sceneFo:(AIFoNodeBase*)sceneFo;

/**
 *  MARK:--------------------Canset求解过滤器 (参考29081-todo41)--------------------
 */
+(NSArray*) solutionCansetFilter:(AIFoNodeBase*)sceneFo targetIndex:(NSInteger)targetIndex;

/**
 *  MARK:--------------------Scene求解过滤器 (参考2908a-todo2)--------------------
 */
+(NSArray*) solutonSceneFilter:(AIFoNodeBase*)protoScene type:(SceneType)type;

@end
