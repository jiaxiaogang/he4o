//
//  OutputDelegate.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//


/**
 *  MARK:--------------------实现此方法的对象指定给SMG--------------------
 */
@protocol OutputDelegate <NSObject>



/**
 *  MARK:--------------------输出字符串--------------------
 */
-(void) output_Text:(NSString*)text;



@end
