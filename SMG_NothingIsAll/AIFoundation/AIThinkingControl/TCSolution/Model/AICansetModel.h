//
//  AICansetModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/11.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AICansetModel : NSObject

+(AICansetModel*) newWithBase:(AICansetModel*)base type:(CansetType)type scene:(AIKVPointer*)scene;

/**
 *  MARK:--------------------base--------------------
 *  @desc 参考29069-数据结构示图 (兄弟的base=父类 父类的base=自己);
 */
@property (strong, nonatomic) AICansetModel *base;

/**
 *  MARK:--------------------subs--------------------
 *  @desc 参考29069-数据结构示图 (自己的subs=父类 父类的subs=兄弟);
 *  @init 在子模型构建时,一个个报名填充进来;
 */
@property (strong, nonatomic) NSMutableArray *subs;

/**
 *  MARK:--------------------type--------------------
 *  @desc 当前是自己,还是父类,还是兄弟;
 */
@property (assign, nonatomic) CansetType type;

/**
 *  MARK:--------------------cansets--------------------
 *  @desc 当前下面挂载的cansets;
 */
@property (strong, nonatomic) NSArray *cansets;

/**
 *  MARK:--------------------scene--------------------
 *  @desc 当前cansetModel是基于哪个scene;
 */
@property (strong, nonatomic) AIKVPointer *scene;

@end
