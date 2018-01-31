//
//  AIInputMindValueAlgsModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/24.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIInputModel.h"

@interface AIInputMindValueAlgsModel : AIInputModel

@property (assign, nonatomic)  NSInteger urgentValue; //经algs转化后的值;例如(饥饿状态向急切度的变化)
@property (assign, nonatomic) AITargetType targetType;

@end
