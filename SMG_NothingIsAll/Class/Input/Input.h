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
 *  注意力对象有可能是一颗树;或者两颗树;或者注意力仅仅是树的大小;
 *  注意力是可持续的;一次注意力,可以提交很多次数据;有时是声音;有时是图像;有时是大脑指定的属性值;
 */
@class InputModel;
@interface Input : NSObject


-(void) seeWorld:(id)property;//指定注意下某物的某属性;

/**
 *  MARK:--------------------在视野查找某物--------------------
 *  attributes:确认唯一性的参数集;
 */
-(void) findAtWorld:(NSDictionary*)attributes;

@end
