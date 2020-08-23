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
@end

@implementation TOFoModel

+(TOFoModel*) newWithFo_p:(AIKVPointer*)fo_p base:(id<ITryActionFoDelegate>)base{
    TOFoModel *result = [[TOFoModel alloc] initWithContent_p:fo_p];
    result.status = TOModelStatus_Runing;
    if (base) [base.actionFoModels addObject:result];
    result.baseOrGroup = base;
    return result;
}

-(NSMutableArray *)actions{
    if (!_actions) _actions = [[NSMutableArray alloc] init];
    return _actions;
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

/**
 *  MARK:--------------------生物钟触发器--------------------
 *  @callers
 *      1. demand.ActYes处 (等待外循环mv抵消);
 *      2. 行为化Hav().HNGL.ActYes处 (等待外循环输入符合HNGL的概念)
 *      3. 行为输出ActYes处 (等待外循环输入推进下一帧概念)
 *  @version
 *      2020.08.14: 支持生物钟触发器;
 *          1. timer计时器触发,取deltaT x 1.3时间;
 *          2. "计时触发"时,对触发者的ActYes状态进行判断,如果还未由外循环实际输入,则"实际触发";
 *          3. 实际触发后,对预想时序fo 与 实际时序fo 进行反省类比;
 *          x. 当outModel中某时序完成时,则追回(销毁)与其对应的触发器 (废弃,不用销毁,改变status状态即可);
 *          x. 直到触发时,还未销毁,则说明实际时序并未完成,此时调用反省类比 (废弃,由commitFromOuterPushMiddleLoop()来做状态改变即可);
 */
-(void) setTimeTrigger{
    //1. 用after延迟定时触发;
    //2. 触发时,判定是否还是actYes状态;
    //3. 因为在commitFromOuterPushMiddleLoop()中,会将ActYes且符合,且PM算法成功的,改为Finish;
}

@end
