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
@property (strong, nonatomic) NSMutableArray *subDemands;

@end

@implementation TOFoModel

+(TOFoModel*) newWithFo_p:(AIKVPointer*)fo_p base:(TOModelBase<ITryActionFoDelegate>*)base basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel{
    //1. 数据准备;
    AIFoNodeBase *fo = [SMGUtils searchNode:fo_p];
    TOFoModel *result = [[TOFoModel alloc] initWithContent_p:fo_p];
    
    //2. 赋值;
    result.status = TOModelStatus_Runing;
    if (base) [base.actionFoModels addObject:result];
    result.baseOrGroup = base;
    result.actionIndex = -1;//默认为头(-1),r和h任务自行重赋值;
    result.targetSPIndex = fo.count;//默认到尾(foCount),h任务自行重赋值;
    result.basePFoOrTargetFoModel = basePFoOrTargetFoModel;
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
    if (_subModels == nil) _subModels = [[NSMutableArray alloc] init];
    return _subModels;
}
-(NSMutableArray *)subDemands{
    if (_subDemands == nil) _subDemands = [[NSMutableArray alloc] init];
    return _subDemands;
}

//-(void)setActionIndex:(NSInteger)actionIndex{
//    NSLog(@"toFo.setActionIndex:%ld -> %ld",self.actionIndex,actionIndex);
//    _actionIndex = actionIndex;
//}

/**
 *  MARK:--------------------将每帧反馈转成orders,以构建protoFo--------------------
 *  @param fromRegroup : 从TCRegroup调用时未发生部分也取, 而用于canset抽象时仅取已发生部分;
 *  @version
 *      2022.11.25: 转regroupFo时收集默认content_p内容(代码不变),canset再类比时仅获取feedback反馈的alg (参考27207-1);
 *      2023.02.12: 返回改为: matchFo的前段+执行部分反馈帧 (参考28068-方案1);
 */
-(NSArray*) getOrderUseMatchAndFeedbackAlg:(BOOL)fromRegroup {
    //1. 数据准备 (收集除末位外的content为order);
    AIFoNodeBase *fo = [SMGUtils searchNode:self.content_p];
    NSMutableArray *order = [[NSMutableArray alloc] init];
    NSArray *feedbackIndexArr = [self getIndexArrIfHavFeedback];
    NSInteger max = fromRegroup ? fo.count : self.actionIndex;
    
    //2. 将fo逐帧收集真实发生的alg;
    for (NSInteger i = 0; i < max; i++) {
        //3. 找到当前帧alg_p;
        AIKVPointer *matchAlg_p = ARR_INDEX(fo.content_ps, i);
        
        //4. 如果有反馈feedbackAlg,则优先取反馈;
        AIKVPointer *findAlg_p = matchAlg_p;
        if ([feedbackIndexArr containsObject:@(i)]) {
            findAlg_p = [self getFeedbackAlgWithSolutionIndex:i];
        }
        
        //5. 生成时序元素;
        if (findAlg_p) {
            NSTimeInterval inputTime = [NUMTOOK(ARR_INDEX(fo.deltaTimes, i)) longLongValue];
            [order addObject:[AIShortMatchModel_Simple newWithAlg_p:findAlg_p inputTime:inputTime]];
        }
    }
    return order;
}

/**
 *  MARK:--------------------算出新的indexDic--------------------
 *  @desc 用旧indexDic和feedbackAlg计算出新的indexDic (参考27206d-方案2);
 */
-(NSDictionary*) convertOldIndexDic2NewIndexDic:(AIKVPointer*)targetOrPFo_p {
    //1. 数据准备;
    AIFoNodeBase *targetOrPFo = [SMGUtils searchNode:targetOrPFo_p];
    AIKVPointer *solutionFo = self.content_p;
    
    //2. 将fo逐帧收集有反馈的conIndex (参考27207-7);
    NSArray *feedbackIndexArr = [self getIndexArrIfHavFeedback];
    
    //3. 取出solutionFo旧有的indexDic (参考27207-8);
    NSDictionary *oldIndexDic = [targetOrPFo getConIndexDic:solutionFo];
    
    //4. 筛选出有反馈的absIndex数组 (参考27207-9);
    NSArray *feedbackAbsIndexArr = [SMGUtils filterArr:oldIndexDic.allKeys checkValid:^BOOL(NSNumber *absIndexKey) {
        NSNumber *conIndexValue = NUMTOOK([oldIndexDic objectForKey:absIndexKey]);
        return [feedbackIndexArr containsObject:conIndexValue];
    }];
    
    //5. 转成newIndexDic (参考27207-10);
    NSMutableDictionary *newIndexDic = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < feedbackAbsIndexArr.count; i++) {
        NSNumber *absIndex = ARR_INDEX(feedbackAbsIndexArr, i);
        [newIndexDic setObject:@(i) forKey:absIndex];
    }
    return newIndexDic;
}

/**
 *  MARK:--------------------算出新的spDic--------------------
 *  @desc 用旧spDic和feedbackAlg计算出新的spDic (参考27211-todo1);
 *  @version
 *      2023.04.01: 修复算出的S可能为负的BUG,改为直接从conSolution继承对应帧的SP值 (参考27214);
 *  @result notnull (建议返回后,检查一下spDic和absCansetFo的长度是否一致,不一致时来查BUG);
 */
-(NSDictionary*) convertOldSPDic2NewSPDic {
    //1. 数据准备 (收集除末位外的content为order) (参考27212-步骤1);
    AIFoNodeBase *solutionFo = [SMGUtils searchNode:self.content_p];
    NSArray *feedbackIndexArr = [self getIndexArrIfHavFeedback];
    NSMutableDictionary *newSPDic = [[NSMutableDictionary alloc] init];
    
    //2. sulutionIndex都是有反馈的帧,
    for (NSInteger i = 0; i < feedbackIndexArr.count; i++) {
        //3. 数据准备: 有反馈的帧,在solution对应的index (参考27212-步骤1);
        NSNumber *solutionIndex = ARR_INDEX(feedbackIndexArr, i);
        
        //4. 取得具象solutionFo的spStrong (参考27213-2&3);
        AISPStrong *conSPStrong = [solutionFo.spDic objectForKey:@(solutionIndex.integerValue)];
        
        //5. 直接继承solutionFo对应帧的SP值 (参考27214-方案);
        AISPStrong *absSPStrong = conSPStrong ? conSPStrong : [[AISPStrong alloc] init];
        [AITest test19:absSPStrong];
        
        //6. 新的spDic收集一帧: 抽象canset的帧=i (因为比如有3帧有反馈,那么这三帧就是0,1,2) (参考27207-10);
        NSInteger absCansetIndex = i;
        [newSPDic setObject:absSPStrong forKey:@(absCansetIndex)];
    }
    return newSPDic;
}

//MARK:===============================================================
//MARK:                     < privateMthod >
//MARK:===============================================================

/**
 *  MARK:--------------------获取当前solution中有反馈的下标数组--------------------
 *  @result <K:有反馈的下标,V:有反馈的feedbackAlg_p>
 */
-(NSMutableArray*) getIndexArrIfHavFeedback {
    //1. 数据准备;
    AIFoNodeBase *solutionFo = [SMGUtils searchNode:self.content_p];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //2. 将fo逐帧收集有反馈的conIndex (参考27207-7);
    for (NSInteger i = 0; i < solutionFo.count; i++) {
        AIKVPointer *solutionAlg_p = ARR_INDEX(solutionFo.content_ps, i);
        for (TOAlgModel *item in self.subModels) {
            if (item.status == TOModelStatus_OuterBack && [item.content_p isEqual:solutionAlg_p] && item.feedbackAlg) {
                [result addObject:@(i)];
                break;
            }
        }
    }
    return result;
}

/**
 *  MARK:--------------------根据solutionIndex取feedbackAlg--------------------
 */
-(AIKVPointer*) getFeedbackAlgWithSolutionIndex:(NSInteger)solutionIndex {
    //1. 数据准备;
    AIFoNodeBase *solutionFo = [SMGUtils searchNode:self.content_p];
    AIKVPointer *solutionAlg_p = ARR_INDEX(solutionFo.content_ps, solutionIndex);
    
    //2. 找出反馈返回;
    for (TOAlgModel *item in self.subModels) {
        if (item.status == TOModelStatus_OuterBack && [item.content_p isEqual:solutionAlg_p] && item.feedbackAlg) {
            return item.feedbackAlg;
        }
    }
    return nil;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.subModels = [aDecoder decodeObjectForKey:@"subModels"];
        self.actionIndex = [aDecoder decodeIntegerForKey:@"actionIndex"];
        self.targetSPIndex = [aDecoder decodeIntegerForKey:@"targetSPIndex"];
        self.subDemands = [aDecoder decodeObjectForKey:@"subDemands"];
        self.feedbackMv = [aDecoder decodeObjectForKey:@"feedbackMv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.subModels forKey:@"subModels"];
    [aCoder encodeInteger:self.actionIndex forKey:@"actionIndex"];
    [aCoder encodeInteger:self.targetSPIndex forKey:@"targetSPIndex"];
    [aCoder encodeObject:self.subDemands forKey:@"subDemands"];
    [aCoder encodeObject:self.feedbackMv forKey:@"feedbackMv"];
}

@end
