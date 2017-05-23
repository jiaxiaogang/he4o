//
//  LawModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------规律(同时)--------------------
 *  作用:用于形成理解系统金字塔的第3层;(详见第二本笔记page3右示图)
 *  什么时候;从记忆往规律倒数据;
 *      • 答案:当需要的时候;(重复的时候)
 *      • 原因:记忆是大海;杂乱而多;
 *          • 规律是记忆到知识的桥;
 *          • 人类三岁前的记忆几乎忘干净,但这个不断完善的桥;一直存在;所以四岁时;会说话;会走路;等;
 *
 *
 *
 */
@class PointerModel;
@interface LawModel : NSObject

/**
 *  MARK:--------------------初始化规律类--------------------
 */
+ (LawModel*) initWithPointerModels:(PointerModel*)pModel,... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead");

/**
 *  MARK:--------------------初始化规律类--------------------
 *  注:model...必须是已在数据库中的数据
 */
+ (LawModel*) initWithModels:(NSObject*)model,...  NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead");

@property (strong,nonatomic) NSMutableArray *pointerArr;    //指针数组(存PointerModel)
@property (assign, nonatomic) NSInteger count;      //计数器

- (void) print;

@end
