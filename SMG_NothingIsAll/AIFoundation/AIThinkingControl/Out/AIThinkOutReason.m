//
//  AIThinkOutReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutReason.h"
#import "AIAlgNodeBase.h"
#import "AICMVNodeBase.h"
#import "AINetIndex.h"
#import "AIKVPointer.h"
#import "ThinkingUtils.h"
#import "TOFoModel.h"
#import "TOAlgScheme.h"
#import "Output.h"
#import "AIShortMatchModel.h"
#import "TOUtils.h"
#import "AINetUtils.h"
#import "AIThinkOutAction.h"
#import "TOAlgModel.h"

@interface AIThinkOutReason() <TOAlgSchemeDelegate,TOActionDelegate>

@property (strong, nonatomic) TOAlgScheme *algScheme;
@property (strong, nonatomic) AIThinkOutAction *toAction;

@end

@implementation AIThinkOutReason

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}
-(void) initData{
    self.algScheme = [[TOAlgScheme alloc] init];
    self.algScheme.delegate = self;
    self.toAction = [[AIThinkOutAction alloc] init];
    self.toAction.delegate = self;
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

//MARK:===============================================================
//MARK:                     < 决策行为化 >
//MARK: 1. 以algScheme开始,优先使用简单的方式,后向fo,mv;
//MARK: 2. 因为TOP已经做了很多工作,此处与TOP协作 (与从左至右的理性向性是相符的);
//MARK:===============================================================

/**
 *  MARK:--------------------FromTOP主入口--------------------
 *  @version
 *      20200416 - actions行为输出前,先清空; (如不清空,下轮外循环TIR->TOP.dataOut()时,导致不重新决策,直接输出上轮actions,行为再被TIR预测,又一轮,形成外层死循环 (参考n19p5-B组BUG2);
 */
-(void) commitFromTOP_Convert2Actions:(TOFoModel*)foModel{
    if (foModel) {
        //1. 为空,进行行为化_尝试输出"可行性之首"并找到实际操作 (子可行性判定) (algScheme)
        if (!ARRISOK(foModel.actions)) {
            [self dataOut_AlgScheme:foModel];
        }
        
        //2. actionScheme (行为方案输出,并清空actions)
        if (ARRISOK(foModel.actions)) {
            NSArray *outArr = [foModel.actions copy];
            [foModel.actions removeAllObjects];
            [self dataOut_ActionScheme:outArr];
        }
    }
}

/**
 *  MARK:--------------------R+行为化--------------------
 *  @desc R+行为化,两级判断,参考:19164;
 *          1. isOut则输出;
 *          2. notOut则等待;
 */
-(void) commitReasonPlus:(TOFoModel*)outModel complete:(void(^)(BOOL actSuccess,NSArray *acts))complete{
    //1. isOut时,直接输出;
    AIKVPointer *cAlg_p = ARR_INDEX(outModel.fo.content_ps, outModel.actionIndex);
    if (cAlg_p && cAlg_p.isOut) {
        outModel.status = TOModelStatus_ActYes;
        complete(true,@[cAlg_p]);
    }else{
        //2. cHav行为化;
        TOAlgModel *algOutModel = [TOAlgModel newWithAlg_p:cAlg_p parent:outModel];
        [self.toAction convert2Out_P:algOutModel complete:complete];
    }
}

/**
 *  MARK:--------------------R-行为化--------------------
 *  @desc R-行为化,三级判断,参考19165;
 *          1. is(SP)判断 (转移sp行为化);
 *          2. isOut判断 (输出);
 *          3. notOut判断 (等待);
 *  @存储 负只是正的帧推进器,比如买菜为了做饭 (参考19171);
 */
-(void) commitReasonSub:(AIFoNodeBase*)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo outModel:(TOFoModel*)outModel complete:(void(^)(BOOL actSuccess,NSArray *acts))complete{
    //1. 数据准备
    AIKVPointer *firstPlusItem = ARR_INDEX(plusFo.content_ps, 0);
    AIKVPointer *checkAlg_p = ARR_INDEX(outModel.fo.content_ps, outModel.actionIndex);
    if (!matchFo || !plusFo || !subFo || !complete || !checkAlg_p) {
        complete(false,nil);
        return;
    }
    
    //2. 正影响首元素,错过判断 (错过,行为化失败);
    NSInteger firstAt_Plus = [TOUtils indexOfAbsItem:firstPlusItem atConContent:outModel.fo.content_ps];
    if (outModel.actionIndex > firstAt_Plus) {
        complete(false,nil);
        return;
    }
    
    //3. 当firstPlus就是checkAlg_p时 (尝试对checkAlg行为化);
    if (firstAt_Plus == outModel.actionIndex) {
        
        //4. 从SFo中,找出checkAlg的兄弟节点matchAlg;
        AIKVPointer *matchAlg_p = [SMGUtils filterSingleFromArr:matchFo.content_ps checkValid:^BOOL(AIKVPointer *item_p) {
            return [TOUtils mcSameLayer:item_p c:checkAlg_p];
        }];
        
        //5. 根据matchAlg找到对应的S;
        AIKVPointer *sAlg_p = [SMGUtils filterSingleFromArr:subFo.content_ps checkValid:^BOOL(AIKVPointer *item) {
            return [TOUtils mIsC_1:matchAlg_p c:item];
        }];
        
        //6. 行为化 (围绕P做行为);
        AIKVPointer *pAlg_p = firstPlusItem;
        if (sAlg_p) {
            NSInteger sIndex = [TOUtils indexOfAbsItem:sAlg_p atConContent:matchFo.content_ps];
            BOOL sHappened = sIndex < outModel.actionIndex;
            if (sHappened) {
                //a. S存在,且S已发生,则加工SP;
                TOAlgModel *algOutModel = [TOAlgModel newWithAlg_p:checkAlg_p parent:outModel];
                [self.toAction convert2Out_SP:sAlg_p pAlg_p:pAlg_p outModel:algOutModel complete:complete];
            }else{
                //b. S存在,但S未发生,则等待 (等S发生);
                complete(true,nil);
            }
        }else{
            //c. S不存在,则仅实现P即可;
            TOAlgModel *algOutModel = [TOAlgModel newWithAlg_p:pAlg_p parent:outModel];
            [self.toAction convert2Out_P:algOutModel complete:complete];
        }
    }
}

/**
 *  MARK:--------------------P+行为化--------------------
 *  @desc P+行为化,两级判断,参考:19166;
 *          1. isOut则输出;
 *          2. notOut则进行cHav行为化;
 *  @version
 *      2020-05-27 : 将isOut=false时等待改成进行cHav行为化;
 */
-(void) commitPerceptPlus:(TOFoModel*)outModel complete:(void(^)(BOOL actSuccess,NSArray *acts))complete{
    //1. 数据检查
    if (!outModel.fo) {
        complete(false,nil);
        return;
    }
    
    //2. 行为化;
    AIKVPointer *curAlg_p = ARR_INDEX(outModel.fo.content_ps, outModel.actionIndex);//从0开始
    if (curAlg_p && curAlg_p.isOut) {
        outModel.status = TOModelStatus_ActYes;
        complete(true,@[curAlg_p]);
    }else{
        //3. cHav行为化
        TOAlgModel *algOutModel = [TOAlgModel newWithAlg_p:curAlg_p parent:outModel];
        [self.toAction convert2Out_P:algOutModel complete:complete];
    }
}

/**
 *  MARK:--------------------P-行为化--------------------
 *  @desc P-行为化,三级判断,参考19167;
 *          1. is(SP)判断 (转移sp行为化);
 *          2. isOut判断 (输出);
 *          3. notOut判断 (等待);
 *  @废弃: 因为左负是不存在的(或者说目前不需要的),可以以左正,转为右正,来实现,累了歇歇的例子;
 */
-(void) commitPerceptSub:(AIFoNodeBase*)matchFo plusFo:(AIFoNodeBase*)plusFo subFo:(AIFoNodeBase*)subFo checkFo:(AIFoNodeBase*)checkFo complete:(void(^)(BOOL actSuccess,NSArray *acts))complete{
    ////1. 数据准备
    //AIKVPointer *firstSubItem = ARR_INDEX(subFo.content_ps, 0);
    //AIKVPointer *firstPlusItem = ARR_INDEX(plusFo.content_ps, 0);
    //AIKVPointer *curAlg_p = ARR_INDEX(checkFo.content_ps, 0);//当前plusFo的具象首元素;
    //if (!matchFo || !plusFo || !subFo || !checkFo || !complete || !curAlg_p) {
    //    complete(false,nil);
    //    return;
    //}
    //
    ////1. 负影响首元素,错过判断 (错过,行为化失败);
    //NSInteger firstAt_Sub = [TOUtils indexOfAbsItem:firstSubItem atConContent:matchFo.content_ps];
    //
    ////2. 正影响首元素,错过判断 (错过,行为化失败);
    //NSInteger firstAt_Plus = [TOUtils indexOfAbsItem:firstPlusItem atConContent:checkFo.content_ps];
    //
    ////3. 三级行为化判断;
    //if (firstAt_Sub == 0 && firstAt_Plus == 0) {
    //    //a. 把S加工成P;
    //}else if(firstAt_Sub == 0){
    //    //b. 把S加工修正;
    //}else if(firstAt_Plus == 0){
    //    //c. 把P加工满足;
    //}else if(curAlg_p.isOut){
    //    //d. isOut输出;
    //    complete(true,@[curAlg_p]);
    //}else{
    //    //e. notOut等待;
    //    complete(true,nil);
    //}
}

/**
 *  MARK:--------------------algScheme--------------------
 *  1. 对条件概念进行判定 (行为化);
 *  2. 理性判定;
 */
-(void) dataOut_AlgScheme:(TOFoModel*)outFoModel{
    //1. 数据准备
    if (!ISOK(outFoModel, TOFoModel.class)) {
        return;
    }
    AIFoNodeBase *foNode = [SMGUtils searchNode:outFoModel.content_p];
    if (!foNode) {
        return;
    }
    
    //2. 进行行为化; (通过有无,变化,等方式,将结构中所有条件概念行为化);
    [self.algScheme setData:[self.delegate aiTOR_GetShortMatchModel]];
    
    [self.algScheme convert2Out_Fo:foNode.content_ps curFo:foNode success:^(NSArray *acts) {
        [outFoModel.actions addObjectsFromArray:acts];
    } failure:^{
        WLog(@"STEPKEYTOR_行为化失败");
    }];
}

//MARK:===============================================================
//MARK:                     < FromTOP_反射反应 >
//MARK:===============================================================
-(void) commitFromTOP_ReflexOut{
    [self dataOut_ActionScheme:nil];
}

-(void) dataOut_ActionScheme:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (ARRISOK(outArr)) {
        for (AIKVPointer *algNode_p in outArr) {
            //>1 检查micro_p是否是"输出";
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [Output output_FromTC:algNode_p];
            if (invoked) {
                tryOutSuccess = true;
            }
        }
    }
    
    //2. 无法解决时,反射一些情绪变化,并增加额外输出;
    if (!tryOutSuccess) {
        //>1 产生"心急mv";(心急产生只是"urgent.energy x 2")
        //>2 输出反射表情;
        //>3 记录log到foOrders;(记录log应该到output中执行)
        
        //1. 如果未找到复现方式,或解决方式,则产生情绪:急
        //2. 通过急,输出output表情哭
        
        //1. 心急情绪释放,平复思维;
        [self.delegate aiThinkOutReason_UpdateEnergy:-1];
        
        //2. 反射输出
        [Output output_FromMood:AIMoodType_Anxious];
    }
}

//MARK:===============================================================
//MARK:                     < TOAlgSchemeDelegate >
//MARK:===============================================================
-(void)toAlgScheme_updateEnergy:(CGFloat)delta{
    [self.delegate aiThinkOutReason_UpdateEnergy:delta];
}
-(BOOL) toAlgScheme_EnergyValid{
    return [self.delegate aiThinkOutReason_EnergyValid];
}
//反思
-(AIShortMatchModel*) toAlgScheme_LSPRethink:(AIAlgNodeBase*)rtAlg rtFoContent_ps:(NSArray*)rtFoContent_ps{
    return [self.delegate aiTOR_LSPRethink:rtAlg rtFoContent_ps:rtFoContent_ps];
}
-(AIAlgNodeBase*) toAlgScheme_MatchRTAlg:(AIAlgNodeBase*)rtAlg mUniqueV_p:(AIKVPointer*)mUniqueV_p{
    return [self.delegate aiTOR_MatchRTAlg:rtAlg mUniqueV_p:mUniqueV_p];
}

//MARK:===============================================================
//MARK:                     < TOActionDelegate >
//MARK:===============================================================
-(void)toAction_updateEnergy:(CGFloat)delta{
    [self.delegate aiThinkOutReason_UpdateEnergy:delta];
}
-(BOOL)toAction_EnergyValid{
    return [self.delegate aiThinkOutReason_EnergyValid];
}

@end
