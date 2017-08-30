//
//  AIThinkModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/8/24.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------用户model化神经网络点亮的数据--------------------
 *  //ThinkModel应该只是对神经网络AreaLight的映射，因为思考过程还需要对神经网络进行重建等操作(参考N5P8);
 */
@interface ThinkModel : NSObject

@property (strong,nonatomic) AIObject *model;               //中心model
@property (strong,nonatomic) AIPointer *linePointer;        //点亮方向 (中心model的哪条神经网络连接扩展)
@property (strong,nonatomic) NSMutableArray *lightModels;   //点亮的结果

@end
