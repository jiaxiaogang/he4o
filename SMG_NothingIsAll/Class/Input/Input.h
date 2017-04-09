//
//  Input.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------输入--------------------
 *  输入是多媒体的;(音,视,行为,文字)
 */
@class InputModel;
@interface Input : NSObject

/**
 *  MARK:--------------------提交输入多媒体模型--------------------
 */
-(void)commitInputModel:(InputModel*)inputModel;

@end
