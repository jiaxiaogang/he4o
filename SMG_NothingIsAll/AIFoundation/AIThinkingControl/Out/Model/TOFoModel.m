//
//  TOFoModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/30.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "TOFoModel.h"

@interface TOFoModel()

@property (strong, nonatomic) NSMutableArray *subModels;
@property (strong, nonatomic) NSMutableArray *actionFoModels;

@end

@implementation TOFoModel

+(TOFoModel*) newWithFo_p:(AIKVPointer*)fo_p base:(id<ITryActionFoDelegate>)base{
    TOFoModel *result = [[TOFoModel alloc] initWithContent_p:fo_p];
    result.status = TOModelStatus_Runing;
    if (base) [base.actionFoModels addObject:result];
    result.baseOrGroup = base;
    result.actionIndex = -1;//当前帧,初始为-1;
    return result;
}

/**
 *  MARK:--------------------每层第一名之和分值--------------------
 *  @desc 跨fo的综合评分,
 *          1. 比如打篮球去?还是k歌去,打篮球考虑到有没有球,球场是否远,自己是否累,天气是否好, k歌也考虑到自己会唱歌不,嗓子是否舒服;
 *          2. 当对二者进行综合评分,选择时,涉及到结构化下的综合评分;
 *          3. 目前用不着,以后可能也用不着;
 *
 */
//-(CGFloat) allNiceScore{
//    //TOModelBase *subModel = [self itemSubModels];
//    //if (subModel) {
//    //    return self.score + [subModel allNiceScore];
//    //}
//    //1. 从当前actionIndex
//    //2. 找itemSubModels下
//    //3. 所有status未中止的
//    //4. 那些时序的评分总和
//    return self.score;
//}

-(NSMutableArray *)subModels {
    if (_subModels == nil) {
        _subModels = [[NSMutableArray alloc] init];
    }
    return _subModels;
}
-(NSMutableArray *)actionFoModels{
    if (_actionFoModels == nil) {
        _actionFoModels = [[NSMutableArray alloc] init];
    }
    return _actionFoModels;
}

//-(void)setActionIndex:(NSInteger)actionIndex{
//    NSLog(@"toFo.setActionIndex:%ld -> %ld",self.actionIndex,actionIndex);
//    _actionIndex = actionIndex;
//}

@end
