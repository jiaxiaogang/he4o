//
//  AISceneModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/11.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------CansetModel--------------------
 *  @desc 一个CansetModel中包含多个overrideCanset;
 */
@interface AISceneModel : NSObject

+(AISceneModel*) newWithBase:(AISceneModel*)base type:(SceneType)type scene:(AIKVPointer*)scene cutIndex:(NSInteger)cutIndex;

/**
 *  MARK:--------------------base--------------------
 *  @desc 参考29069-数据结构示图 (兄弟的base=父类 父类的base=自己);
 */
@property (strong, nonatomic) AISceneModel *base;

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
@property (assign, nonatomic) SceneType type;

/**
 *  MARK:--------------------获取scene树的根model--------------------
 */
-(AISceneModel*) getRoot;

/**
 *  MARK:--------------------scene--------------------
 *  @desc 当前cansetModel是基于哪个scene;
 */
@property (strong, nonatomic) AIKVPointer *scene;

/**
 *  MARK:--------------------cutIndex--------------------
 *  @desc cutIndex的值 = aleardayCount - 1 = actionIndex - 1
 *      1. H任务时: H任务的targetIndex = actionIndex (H任务目标是当前场景targetFo的actionIndex帧);
 *      2. R任务时: R任务的targetIndex = sceneFo.count (R任务目标是最后的mv结果);
 */
@property (assign, nonatomic) NSInteger cutIndex;

//向base方向自动取fatherScene
-(AIKVPointer*) getFatherScene;
-(AISceneModel*) getFatherSceneModel;

//向base方向自动取brotherScene
-(AIKVPointer*) getBrotherScene;
-(AISceneModel*) getBrotherSceneModel;

//向base方向自动取iScene
-(AIKVPointer*) getIScene;
-(AISceneModel*) getISceneModel;

@end
