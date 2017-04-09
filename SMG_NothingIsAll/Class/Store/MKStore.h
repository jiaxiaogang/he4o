//
//  MKStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemStore.h"

/**
 *  MARK:--------------------知识图谱--------------------
 *  MK也是记忆;(对比如下:)
 *  共同点:都可以被GC从dic回收到local;甚至删掉;
 *  不同点:知识图谱是被理解系统生成,更可信,更稳定,明确mind值;
 */
@interface MKStore : MemStore


/**
 *  MARK:--------------------分词--------------------
 *  计划功能:随后添加分词使用频率;使其更正确的工作;
 */
-(BOOL) containerWord:(NSString*)word;//图谱分词数组;包含某词;
-(void) addWord:(NSString*)word;




@end
