//
//  Store.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemStore.h"
#import "MKStore.h"

@interface Store : NSObject

@property (strong,nonatomic) MemStore *memStore;    //记忆存储
@property (strong,nonatomic) MKStore *mkStore;      //知识图谱

@end
