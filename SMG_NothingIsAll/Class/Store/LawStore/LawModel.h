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
