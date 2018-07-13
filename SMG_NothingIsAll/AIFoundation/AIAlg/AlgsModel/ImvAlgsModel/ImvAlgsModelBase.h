//
//  ImvAlgsModelBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/2/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImvAlgsModelBase : NSObject

@property (assign, nonatomic)  NSInteger delta;     //经algs转化后的值;例如(饥饿状态向急切度的变化)
@property (assign, nonatomic)  NSInteger urgentTo;  //经algs转化后的值,所有的变化,都有迫切度;

@end
