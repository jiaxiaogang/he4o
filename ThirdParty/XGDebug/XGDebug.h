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
@interface XGDebug : NSObject

+(XGDebug*) sharedInstance;
-(void) debug:(NSString*)key line:(NSInteger)line;
-(NSMutableArray *)models; //notnull

@end
