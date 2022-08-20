//
//  XGDebug.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/4/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------性能分析--------------------
 *  @desc 使用说明: 每条显示的用时为,当前条到下条执行间的代码用时;
 */
@class XGDebugModel;
@interface XGDebug : NSObject

+(XGDebug*) sharedInstance;

/**
 *  MARK:--------------------追加一条记录--------------------
 *  @param fileName : 调用者类名 (参考防重);
 *  @param suffix   : 调用者后辍 (参与防重);
 *  _param prefix   : 调用者前辍 (参考防重);
 *  @desc 参数说明: 一般容易写死判断匹配的作为前辍 (如FILENAME或LoopId),常变不易匹配的用作后辍(如代码块标识:"R1.1");
 */
-(void) debugModuleWithFileName:(NSString*)fileName suffix:(NSString*)suffix;
-(void) debugModuleWithPrefix:(NSString*)prefix suffix:(NSString*)suffix;
-(void) debugWrite;
-(void) debugRead;
-(NSMutableArray *)models; //notnull

/**
 *  MARK:--------------------根据前辍取debugModels--------------------
 */
-(NSArray*) getDebugModels:(NSString*)prefix;

@end
