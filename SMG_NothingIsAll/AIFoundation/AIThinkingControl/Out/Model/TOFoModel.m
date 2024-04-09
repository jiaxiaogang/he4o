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

+(TOFoModel*) newWithCansetFo:(AIKVPointer*)cansetFo sceneFo:(AIKVPointer*)sceneFo base:(TOModelBase<ITryActionFoDelegate>*)base
           protoFrontIndexDic:(NSDictionary *)protoFrontIndexDic matchFrontIndexDic:(NSDictionary *)matchFrontIndexDic
              frontMatchValue:(CGFloat)frontMatchValue frontStrongValue:(CGFloat)frontStrongValue
               midEffectScore:(CGFloat)midEffectScore midStableScore:(CGFloat)midStableScore
                 backIndexDic:(NSDictionary*)backIndexDic backMatchValue:(CGFloat)backMatchValue backStrongValue:(CGFloat)backStrongValue
                     cutIndex:(NSInteger)cutIndex sceneCutIndex:(NSInteger)sceneCutIndex
                  targetIndex:(NSInteger)targetIndex sceneTargetIndex:(NSInteger)sceneTargetIndex
       basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel baseSceneModel:(AISceneModel*)baseSceneModel {
    TOFoModel *model = [[TOFoModel alloc] init];
    
    //1. 原CansetModel相关赋值;
    model.cansetFo = cansetFo;
    model.sceneFo = sceneFo;
    model.basePFoOrTargetFoModel = basePFoOrTargetFoModel;
    model.baseSceneModel = baseSceneModel;
    model.protoFrontIndexDic = protoFrontIndexDic;
    model.matchFrontIndexDic = matchFrontIndexDic;
    model.frontMatchValue = frontMatchValue;
    model.frontStrongValue = frontStrongValue;
    model.midEffectScore = midEffectScore;
    model.midStableScore = midStableScore;
    model.backMatchValue = backMatchValue;
    model.backStrongValue = backStrongValue;
    model.cutIndex = cutIndex;
    model.targetIndex = targetIndex;
    model.sceneTargetIndex = sceneTargetIndex;
    
    //2. TOFoModel相关赋值;
    model.content_p = cansetFo;
    model.status = TOModelStatus_Runing;
    if (base) [base.actionFoModels addObject:model];
    model.baseOrGroup = base;
    return model;
}

+(TOFoModel*) newForHCansetFo:(AIKVPointer*)canset sceneFo:(AIKVPointer*)scene base:(TOModelBase<ITryActionFoDelegate>*)base
               cansetCutIndex:(NSInteger)cansetCutIndex sceneCutIndex:(NSInteger)sceneCutIndex
            cansetTargetIndex:(NSInteger)cansetTargetIndex sceneTargetIndex:(NSInteger)sceneTargetIndex
       basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel baseSceneModel:(AISceneModel*)baseSceneModel {
    TOFoModel *model = [[TOFoModel alloc] init];
    
    //1. 原CansetModel相关赋值;
    model.cansetFo = canset;
    model.sceneFo = scene;
    model.basePFoOrTargetFoModel = basePFoOrTargetFoModel;
    model.baseSceneModel = baseSceneModel;//H任务时,其实是复用了R任务的RSceneModel;
    model.cutIndex = cansetCutIndex;//H任务时,cansetCutIndex其实是顺着scene找上一帧有映射的 (参考TOUtils.goBackToFindConIndexByAbsIndex());
    model.targetIndex = cansetTargetIndex;
    model.sceneTargetIndex = sceneTargetIndex;//H任务时,其实hScene的目标就是hScene的下一帧 (即目标 = hScene.cutIndex + 1);
    
    //2. TOFoModel相关赋值;
    model.content_p = canset;
    model.status = TOModelStatus_Runing;
    model.baseOrGroup = base;
    return model;
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
//    //1. 从当前cutIndex
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
    NSInteger max = fromRegroup ? fo.count : self.cutIndex;
    
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
            NSTimeInterval inputTime = [NUMTOOK(ARR_INDEX(fo.deltaTimes, i)) doubleValue];
            [order addObject:[AIShortMatchModel_Simple newWithAlg_p:findAlg_p inputTime:inputTime isTimestamp:false]];
        }
    }
    return order;
}

/**
 *  MARK:--------------------算出新的indexDic--------------------
 *  @desc 用旧indexDic和feedbackAlg计算出新的indexDic (参考27206d-方案2);
 *  @param targetOrPFo_p 传sceneTo,因为要用它与cansetTo取旧的indexDic的;
 */
-(NSDictionary*) convertOldIndexDic2NewIndexDic:(AIKVPointer*)targetOrPFo_p {
    //1. 数据准备;
    AIFoNodeBase *targetOrPFo = [SMGUtils searchNode:targetOrPFo_p];
    AIKVPointer *cansetToFo = self.content_p;//行为化中的siFo
    
    //2. 将fo逐帧收集有反馈的conIndex (参考27207-7);
    NSArray *feedbackIndexArr = [self getIndexArrIfHavFeedback];
    
    //3. 取出solutionFo旧有的indexDic (参考27207-8);
    NSDictionary *oldIndexDic = [targetOrPFo getConIndexDic:cansetToFo];
    
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
    NSLog(@"oldIndexDic:%@ newIndexDic:%@",CLEANSTR(oldIndexDic),CLEANSTR(newIndexDic));
    if (oldIndexDic.count > 0 && newIndexDic.count == 0) {
        NSLog(@"查下,为什么总是取到空映射");
        //第1步: 来自于NewRCanset的映射 (有值);
        //第2步: 在TCTransfer.xv中有映射;
        //第3步: 在TCTransfer.si中有映射;
        //第4步: 在此处oldIndexDic有映射 (有值);
        //第5步: 在此处newIndexDic有映射;
        //TODOTOMORROW20240408: 明天继续查下这里,看为什么旧的indexDic都有值,新的indexDic却没值;
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

//MARK:===============================================================
//MARK:                     < for 三级场景 >
//MARK:===============================================================

/**
 *  MARK:--------------------有iCanset直接返回进行行为化等 (参考29069-todo9 & todo10.1b)--------------------
 */
-(AIKVPointer *)content_p {
    if (_transferSiModel) return _transferSiModel.canset;
    return super.content_p;
}

/**
 *  MARK:--------------------返回需用于反省或有效统计的cansets (参考29069-todo11 && todo11.2)--------------------
 *  @result notnull
 */
-(NSArray*) getRethinkEffectCansets {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //1. father和i两级canset有值时,收集 (参考29069-todo11.2);
    if (self.transferSiModel) [result addObject:self.transferSiModel];
    
    //2. 三级canset都无值时,默认返回content_p;
    if (!ARRISOK(result)) [result addObject:[AITransferModel newWithScene:self.sceneFo canset:self.cansetFo]];
    return result;
}

/**
 *  MARK:--------------------下帧初始化 (可接受反馈) (参考31073-TODO2g)--------------------
 *  @desc 上帧推进完成时调用: 1.更新cutIndex++ 2.挂载下帧TOAlgModel
 *  @version
 *      2024.01.25: 初版: 此方法逻辑与TCAction一致,只是为了允许被反馈和记录feedbackAlg,所以把这些代码前置了 (参考31073-TODO2g);
 */
-(void) pushNextFrame {
    //1. 数据准备;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:self.content_p];
    NSInteger actionIndex = self.cutIndex + 1; //现在正在行为化中的帧下标 (随后验证一下这里的index是不是搞乱了,都修正下);
    
    //2. 更新cutIndex;
    self.cutIndex ++;
    
    //3. 挂载TOAlgModel;
    if (self.cutIndex < self.targetIndex - 1) {
        //6. 转下帧: 理性帧则生成TOAlgModel;
        AIKVPointer *nextCansetA_p = ARR_INDEX(cansetFo.content_ps, self.cutIndex);
        [TOAlgModel newWithAlg_p:nextCansetA_p group:self];
    }else{
        if(ISOK(self.baseOrGroup, HDemandModel.class)){
            //9. H目标帧只需要等 (转hActYes) (参考25031-9);
            AIKVPointer *hTarget_p = ARR_INDEX(cansetFo.content_ps, self.cutIndex);
            [TOAlgModel newWithAlg_p:hTarget_p group:self];
        }
    }
}

/**
 *  MARK:--------------------获取当前正在推进中的帧--------------------
 */
-(TOAlgModel*) getCurFrame {
    //方法1. 从subModels中找出cutIndex对应的那一条返回;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:self.content_p];
    AIKVPointer *curCansetA_p = ARR_INDEX(cansetFo.content_ps, self.cutIndex);
    return [SMGUtils filterSingleFromArr:self.subModels checkValid:^BOOL(TOAlgModel *item) {
        return [item.content_p isEqual:curCansetA_p];
    }];
    
    //方法2. 直接取subModels的最后一条 (按道理最后一条就是当前正在推进中的,但严谨上说目前不太确定,所以先用方法1)
    //return ARR_INDEX_REVERSE(self.subModels, 0);
}

/**
 *  MARK:--------------------feedbackTOR反馈时触发,用于每个cansetFo都可以接受持续反馈推进--------------------
 */
-(void) commit4FeedbackTOR:(NSArray*)feedbackMatchAlg_ps protoAlg:(AIKVPointer*)protoAlg_p {
    //1. 反馈判断,无反馈直接return (参考31073-TODO2);
    BOOL feedbackValid = [self step1_CheckFeedbackTORIsValid:feedbackMatchAlg_ps protoAlg:protoAlg_p];
    if (!feedbackValid) return;
    
    //2. 反馈有效: 构建hCanset;
    [self step2_FeedbackThenCreateHCanset:protoAlg_p];
        
    //3. 并推进到下帧 (参考31073-TODO2g-3);
    [self pushNextFrame];
}

/**
 *  MARK:--------------------检查feedbackTOR反馈是否对此CansetModel有效 (参考31073-TODO2)--------------------
 */
-(BOOL) step1_CheckFeedbackTORIsValid:(NSArray*)feedbackMatchAlg_ps protoAlg:(AIKVPointer*)protoAlg_p {
    //2024.01.11: 此处可以考虑支持持续反馈 (参考31063-todo1);
    //2024.01.25: 现在应该能支持仅靠匹配度来竞争了,因为CansetModels已经支持实时竞争了,但现在接受一次反馈后,就会pushNextFrame,是不支持以往帧持续反馈的,随后再改支持吧);
    //AIKVPointer *oldFeedbackAlg = curAlgModel.feedbackAlg;//新旧反馈用匹配度竞争一下: 更匹配则替换等 | 否则则把oldFeedbackAlg改回去;
    
    //1. 未达到targetIndex才接受反馈;
    if (self.cutIndex >= self.targetIndex) return false;
    feedbackMatchAlg_ps = ARRTOOK(feedbackMatchAlg_ps);
    
    //2. 判断反馈mIsC是否有效 (比如找锤子,看到锤子了 & 再如吃,确定自己是否真吃了);
    NSArray *cansetToContent_ps = [self getCansetToContent_ps];
    AIKVPointer *cansetToWaitAlg_p = ARR_INDEX(cansetToContent_ps, self.cutIndex + 1);
    BOOL mIsC = [feedbackMatchAlg_ps containsObject:cansetToWaitAlg_p];
    if (!mIsC) return false;
    
    //3. 有效时: 记录feedbackAlg;
    TOAlgModel *curAlgModel = [self getCurFrame];
    curAlgModel.feedbackAlg = protoAlg_p;
    curAlgModel.status = TOModelStatus_OuterBack;
    return true;
}

/**
 *  MARK:--------------------feedback有效后: 构建newHCanset和absHCanset (参考31073-TODO7)--------------------
 *  @desc 此方法代码是从feedbackTOR搬过来的,原来的代码有点乱,整理了下使之易读些,并搬到了这里 (参考31073-TODO7);
 *  @param protoAlg_p feedbackTOR方法中的protoAlg传过来;
 */
-(void) step2_FeedbackThenCreateHCanset:(AIKVPointer*)protoAlg_p {
    //1. 数据准备;
    TOAlgModel *curAlgModel = [self getCurFrame];
    
    //========== 第1部分: 当R任务有理性帧推进时,生成newHCanset ==========
    //"行为输出" 和 "demand.ActYes" 和 "静默成功 的有效判断
    //此处有两种frameAlg,第1种是isOut为true的行为反馈,第2种是hDemand.baseAlg;
    if (ISOK(self.baseOrGroup, ReasonDemandModel.class)) {
        //2. 旧有那些改状态status的代码,整理在此处 (参考31073-TODO7-4);
        //3. 当waitModel为hDemand.targetAlg时,此处提前反馈了,hDemand改为finish状态 (参考26185-TODO6);
        HDemandModel *subHDemand = [SMGUtils filterSingleFromArr:curAlgModel.subDemands checkValid:^BOOL(id item) {
            return ISOK(item, HDemandModel.class);
        }];
        //注: 此处非CS_None状态的cansetModel,subHDemand一般为nil;
        if (subHDemand) subHDemand.status = TOModelStatus_Finish;
        if (Log4OPushM) NSLog(@"RCansetA有效:M(A%ld) C(A%ld) CAtFo:%@",protoAlg_p.pointerId,curAlgModel.content_p.pointerId,Pit2FStr(self.content_p));
        self.status = TOModelStatus_Runing;
        
        //4. 收集真实发生realMaskFo,收集成hCanset (参考30131-todo1 & 30132-方案);
        //2023.12.29: mcIsBro=true时,生成新hCanset (做31026-第2步时临时起意改的);
        if (ISOK(self.basePFoOrTargetFoModel, AIMatchFoModel.class)) {
            AIFoNodeBase *rCanset = [SMGUtils searchNode:self.content_p];
            AIMatchFoModel *basePFo = (AIMatchFoModel*)self.basePFoOrTargetFoModel;
            NSArray *order = [basePFo convertOrders4NewCansetV2];
            if (ARRISOK(order) && self.cutIndex < rCanset.count) {
                AIFoNodeBase *newHCanset = [theNet createConFoForCanset:order sceneFo:rCanset sceneTargetIndex:self.cutIndex];
                [rCanset updateConCanset:newHCanset.pointer targetIndex:self.cutIndex];
                AIKVPointer *cutIndexAlg_p = ARR_INDEX(rCanset.content_ps, self.cutIndex);
                
                
                //现有资源1: pFo与实际反馈的映射: basePFo.indexDic2
                //现有资源2: self(RCanset)与pFo的映射: self.xvModel.sceneToCansetToIndexDic
                //需要得到3: 实际反馈 与 RCanset之间的映射;
                //实现方式4: 可以看下,调用indexDic综合计算算法来算这里的映射;
                
                
                //TODOTOMORROW20240406: 看这里怎么把rCanset和hCanset的indexDic映射补上;
                //15. 计算出absCansetFo的indexDic & 并将结果持久化 (参考27207-7至11);
                NSDictionary *newIndexDic = [self convertOldIndexDic2NewIndexDic:basePFo.matchFo];
                [newHCanset updateIndexDic:rCanset indexDic:newIndexDic];
                
                NSLog(@"Canset演化> NewHCanset:%@ 挂载在: rScene:F%ld rCanset:F%ld 的第%ld帧:A%ld",ShortDesc4Node(newHCanset),basePFo.matchFo.pointerId,rCanset.pId,self.cutIndex+1,cutIndexAlg_p.pointerId);
            }
        }
    }
    
    //========== 第2部分: 当H任务推进到最终target时,触发预想与实际类比absHCanset ==========
    //5. H返回的有效判断
    if (ISOK(self.baseOrGroup, HDemandModel.class)) {
        
        //6. HDemand即使waitModel不是actYes状态也处理反馈;
        HDemandModel *hDemand = (HDemandModel*)self.baseOrGroup;//h需求模型
        TOAlgModel *targetAlgModel = (TOAlgModel*)hDemand.baseOrGroup;   //hDemand的目标alg;
        TOFoModel *targetFoModel = (TOFoModel*)targetAlgModel.baseOrGroup;    //hDemand的目标alg所在的fo;
        if (Log4OPushM) NSLog(@"HCansetA有效:M(A%ld) C:%@",protoAlg_p.pointerId,Pit2FStr(targetAlgModel.content_p));
        
        //7. 记录feedbackAlg (参考27204-1);
        BOOL isEndFrame = self.cutIndex == self.targetIndex;
        
        //8. 旧有那些改状态status的代码,整理在此处 (参考31073-TODO7-4);
        //9. H反馈中段: 标记OuterBack,solutionFo继续;
        self.status = isEndFrame ? TOModelStatus_Finish : TOModelStatus_Runing;
        hDemand.status = isEndFrame ? TOModelStatus_Finish : TOModelStatus_Runing;
        if (isEndFrame) {
            hDemand.effectStatus = ES_HavEff;
            targetAlgModel.status = TOModelStatus_OuterBack;
            targetFoModel.status = TOModelStatus_Runing;
            targetAlgModel.feedbackAlg = protoAlg_p;
            
            //10. H反馈末帧时: 做触发H"预想与实际"类比的准备;
            //11. 用realMaskFo & realDeltaTimes生成protoFo (参考30154-todo2);
            AIMatchFoModel *pFo = [TOUtils getBasePFoWithSubOutModel:self];
            NSArray *orders = [pFo convertOrders4NewCansetV2];
            
            //12. H任务完成时,H当前正执行的S提前完成,并进行外类比 (参考27206c-H任务);
            //2023.11.03: 即使已失败也可以触发"预想与实际"的类比抽象;
            //2024.01.25: 只有正在推进中的才有资格做"预想与实际"的类比抽象;
            if (self.cansetStatus == CS_Besting && orders.count > 1) {
                //13. 数据准备;
                AIFoNodeBase *siCansetFo = [SMGUtils searchNode:self.transferSiModel.canset];
                AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoModel.content_p];
                AIFoNodeBase *newHCanset = [theNet createConFo:orders];
                
                //14. 外类比 & 并将结果持久化 (挂到当前目标帧下标targetFoModel.actionIndex下) (参考27204-4&8);
                NSLog(@"Canset演化> AbsHCanset:(状态:%@ fromTargetFo:F%ld) \n\t当前Canset:%@",TOStatus2Str(self.status),targetFoModel.content_p.pointerId,Pit2FStr(self.content_p));
                NSArray *noRepeatArea_ps = [targetFo getConCansets:targetFoModel.cutIndex];
                AIFoNodeBase *absCansetFo = [AIAnalogy analogyOutside:newHCanset assFo:siCansetFo type:ATDefault noRepeatArea_ps:noRepeatArea_ps];
                BOOL updateCansetSuccess = [targetFo updateConCanset:absCansetFo.pointer targetIndex:targetFoModel.cutIndex];
                [AITest test101:absCansetFo proto:newHCanset conCanset:siCansetFo];
                
                if (updateCansetSuccess) {
                    //15. 计算出absCansetFo的indexDic & 并将结果持久化 (参考27207-7至11);
                    NSDictionary *newIndexDic = [self convertOldIndexDic2NewIndexDic:targetFoModel.content_p];
                    [absCansetFo updateIndexDic:targetFo indexDic:newIndexDic];
                    [AITest test18:newIndexDic newCanset:absCansetFo absFo:targetFo];
                    
                    //16. 算出spDic (参考27213-5);
                    [absCansetFo updateSPDic:[self convertOldSPDic2NewSPDic]];
                    [AITest test20:absCansetFo newSPDic:absCansetFo.spDic];
                }
            } else {
                NSLog(@"HCanset预想与实际类比未执行,F%ld 状态:%ld %ld 实际的帧数:%ld",self.content_p.pointerId,self.status,self.cansetStatus,orders.count);
            }
        }
    }
}

//无论现在self是体是用阶段,此方法都能顺利返回实际: cansetTo最终行为化时的canset的content_ps;
-(NSArray*) getCansetToContent_ps {
    if (!self.transferXvModel) {
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:self.cansetFo];
        return cansetFo.content_ps;
    } else {
        return [SMGUtils convertArr:self.transferXvModel.cansetToOrders convertBlock:^id(AIShortMatchModel_Simple *obj) {
            return obj.alg_p;
        }];
    }
}

/**
 *  MARK:--------------------此方案是用于什么任务 (true=H false=R)--------------------
 */
-(BOOL) isH {
    //目前判断方式为: pFo的任务是R,targetFoM的任务是H;
    return !ISOK(self.basePFoOrTargetFoModel, AIMatchFoModel.class);
    //return self.targetIndex < self.cansetFo.count; //用目标帧位置来判断;
}

/**
 *  MARK:--------------------取此方案迁移目标--------------------
 */
-(AIKVPointer*) sceneTo {
    if (self.isH) {
        TOFoModel *targetFoM = (TOFoModel*)self.basePFoOrTargetFoModel;//当前如果是H,这表示正在推进中targetFoM;
        return targetFoM.transferSiModel.canset;
    } else {
        return self.baseSceneModel.getIScene;//无论是R还是H,它的baseSceneModel都是rSceneModel;
    }
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.subModels = [aDecoder decodeObjectForKey:@"subModels"];
        self.cutIndex = [aDecoder decodeIntegerForKey:@"cutIndex"];
        self.targetIndex = [aDecoder decodeIntegerForKey:@"targetIndex"];
        self.subDemands = [aDecoder decodeObjectForKey:@"subDemands"];
        self.feedbackMv = [aDecoder decodeObjectForKey:@"feedbackMv"];
        self.transferXvModel = [aDecoder decodeObjectForKey:@"transferXvModel"];
        self.transferSiModel = [aDecoder decodeObjectForKey:@"transferSiModel"];
        self.refrectionNo = [aDecoder decodeBoolForKey:@"refrectionNo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.subModels forKey:@"subModels"];
    [aCoder encodeInteger:self.cutIndex forKey:@"cutIndex"];
    [aCoder encodeInteger:self.targetIndex forKey:@"targetIndex"];
    [aCoder encodeObject:self.subDemands forKey:@"subDemands"];
    [aCoder encodeObject:self.feedbackMv forKey:@"feedbackMv"];
    [aCoder encodeObject:self.transferXvModel forKey:@"transferXvModel"];
    [aCoder encodeObject:self.transferSiModel forKey:@"transferSiModel"];
    [aCoder encodeBool:self.refrectionNo forKey:@"refrectionNo"];
}

@end
