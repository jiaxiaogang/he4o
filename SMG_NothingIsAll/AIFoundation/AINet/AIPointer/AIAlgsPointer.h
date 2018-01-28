//
//  AIAlgsPointer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/1/28.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@interface AIAlgsPointer : AIPointer

+(AIAlgsPointer*) initWithAlgsClass:(Class)algsClass algsName:(NSString*)algsName;
@property (strong,nonatomic) NSString *algsClass;   //算法所在类
@property (strong,nonatomic) NSString *algsName;    //算法名

@end
