//
//  LogicStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>




/**
 *  MARK:--------------------存储_逻辑/因果--------------------
 *  Logic是Mem被Understand加工后的结果;
 *  同时出现为MK
 *  先后出现为Logic
 *
 *  注:
 *      1,可以被GC从dic回收到local;甚至删掉;
 *      2,Logic是被Understand生成,是习惯系统,推理,解决新问题能力的基础;
 */
@interface LogicStore : NSObject

@end
