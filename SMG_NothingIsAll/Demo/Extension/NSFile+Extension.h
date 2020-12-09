//
//  NSFile+Extension.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/12/9.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFile_Extension : NSObject

//所有子文件收集 notnull
+ (NSArray*)subFiles_AllDeep:(NSString*)dirString;

@end
