//
//  SMG.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------大脑控制器--------------------
 *  用于控制Input,Feel,Think,Mind,Output之间的工作;
 */
@class Store,ThinkControl,Feel,Input,Output,MindControl;
@interface SMG : NSObject

+(SMG*) sharedInstance;
@property (strong,nonatomic) Store *store;          //记忆功能;
@property (strong,nonatomic) MindControl *mindControl;            //心理控制器
@property (strong,nonatomic) ThinkControl *thinkControl;//闲下时,开始理解分析自己的记忆和知识;
@property (strong,nonatomic) Feel *feel;            //感觉系统
@property (strong,nonatomic) Input *input;          //输入系统(计算机视觉,听觉,文字,触觉,网络等)
@property (strong,nonatomic) Output *output;        //输出系统(肢体行为表情眼神,声音,文字等)

@end







