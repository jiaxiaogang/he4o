//
//  MKStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------知识图谱--------------------
 *
 *  注:
 *      1,可以被GC从dic回收到local;甚至删掉;
 *      2,MK是被Understand生成,更可信,更稳定,明确mind值;
 */

@class TextStore,ObjStore,DoStore;
@interface MKStore : NSObject


@property (strong,nonatomic) TextStore *textStore;       //字符串 处理能力
@property (strong,nonatomic) ObjStore *objStore;
@property (strong,nonatomic) DoStore *doStore;


@end
