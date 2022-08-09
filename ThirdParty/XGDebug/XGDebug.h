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
 */
@class XGDebugModel;
@interface XGDebug : NSObject

+(XGDebug*) sharedInstance;

/**
 *  MARK:--------------------追加一条记录--------------------
 *  @param fileName : 调用者类名 (参考防重);
 *  @param suffix   : 调用者后辍 (参与防重);
 *  _param prefix   : 调用者前辍 (参考防重);
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
