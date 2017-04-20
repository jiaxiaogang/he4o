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




/**
 *  MARK:--------------------分析知识图谱的归类--------------------
 *  
 *  1,先天不知道人类
 *  2,类并不是类;只是有相同特征的一些东西;(类,限制了灵活性,而人工智能要求最大的灵活性,所以);
 *  3,观察每个个体与共同点;
 *  思考:小说中出现小芳,思考,小说里的小芳是个人类;但不是我认识的那个小芳;
 */
-(void) addPerson;//临时,,随后删掉


@end
