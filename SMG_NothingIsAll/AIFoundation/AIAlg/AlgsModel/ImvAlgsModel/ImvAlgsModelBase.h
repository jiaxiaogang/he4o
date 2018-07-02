//
//  ImvAlgsModelBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/2/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImvAlgsModelBase : NSObject

@property (assign, nonatomic)  NSInteger urgentValue; //经algs转化后的值;例如(饥饿状态向急切度的变化)
@property (assign, nonatomic) AITargetType targetType;  
@property (assign, nonatomic) MVType type;              //1.饥饿 2.焦急

@end
