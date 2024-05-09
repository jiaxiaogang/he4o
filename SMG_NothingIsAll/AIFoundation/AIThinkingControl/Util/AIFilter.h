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
+(NSArray*) recognitionAlgFilter:(NSArray*)matchAlgModels radio:(CGFloat)radio;

/**
 *  MARK:--------------------时序识别过滤器 (参考28111-todo1)--------------------
 */
+(NSArray*) recognitionFoFilter:(NSArray*)matchModels;

/**
 *  MARK:--------------------Canset识别过滤器 (参考29042)--------------------
 */
//+(NSArray*) recognitionCansetFilter:(NSArray*)matchModels sceneFo:(AIFoNodeBase*)sceneFo;

/**
 *  MARK:--------------------Canset求解过滤器 (参考29081-todo41)--------------------
 */
//+(NSArray*) solutionRCansetFilter:(AIFoNodeBase*)sceneFo targetIndex:(NSInteger)targetIndex;

/**
 *  MARK:--------------------Scene求解过滤器 (参考2908a-todo2)--------------------
 */
+(NSArray*) rSolutionSceneFilter:(AIFoNodeBase*)protoScene type:(SceneType)type;
+(NSArray*) hSolutionSceneFilter:(AISceneModel*)protoScene;

/**
 *  MARK:--------------------识别二次过滤器--------------------
 */
+(void) secondRecognitionFilter:(AIShortMatchModel*)inModel;

/**
 *  MARK:--------------------行为化前反思识别过滤器 (参考30059)--------------------
 */
+(void) secondActionRecognitionFilter:(AIShortMatchModel*)inModel;

@end
