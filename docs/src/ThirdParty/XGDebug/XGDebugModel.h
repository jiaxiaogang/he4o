//
//  XGDebugModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/4/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGDebugModel : NSObject

@property (strong, nonatomic) NSString *key;            //key
@property (assign, nonatomic) NSTimeInterval sumTime;   //总耗时
@property (assign, nonatomic) NSInteger sumCount;       //总执行次数
@property (assign, nonatomic) NSInteger sumWriteCount;  //写硬盘数
@property (assign, nonatomic) NSInteger sumReadCount;   //读硬盘数

@end
