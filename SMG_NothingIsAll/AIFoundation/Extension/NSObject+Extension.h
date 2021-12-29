//
//  NSObject+Extension.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PrintConvertDicOrJson)

/**
 *  MARK:--------------------将obj转为dic类型--------------------
 *  @param containParent : 是否转换父类中的属性
 *  @result notnull
 */
+ (NSMutableDictionary*) getDic:(NSObject*)obj containParent:(BOOL)containParent;

@end
