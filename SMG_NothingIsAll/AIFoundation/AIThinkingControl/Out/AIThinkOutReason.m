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

@interface AIThinkOutReason() <TOAlgSchemeDelegate>

@property (strong, nonatomic) AIShortMatchModel *shortMatchModel;
@property (strong, nonatomic) TOAlgScheme *algScheme;

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
}


//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

//FromTIR主入口
-(void) commitFromTIR:(AIShortMatchModel*)shortMatchModel {
    self.shortMatchModel = shortMatchModel;
}

//MARK:===============================================================
//MARK:                     < 决策行为化 >
//MARK: 1. 以algScheme开始,优先使用简单的方式,后向fo,mv;
//MARK: 2. 因为TOP已经做了很多工作,此处与TOP协作 (与从左至右的理性向性是相符的);
//MARK:===============================================================

//FromTOP主入口
-(void) commitFromTOP_Convert2Actions:(TOFoModel*)foModel{
    if (foModel) {
        //1. 为空,进行行为化_尝试输出"可行性之首"并找到实际操作 (子可行性判定) (algScheme)
        if (!ARRISOK(foModel.actions)) {
            [self dataOut_AlgScheme:foModel];
        }
        
        //2. actionScheme (行为方案输出)
        if (ARRISOK(foModel.actions)) {
            [self dataOut_ActionScheme:foModel.actions];
        }
    }
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
    [self.algScheme setData:self.shortMatchModel];
    
    [self.algScheme convert2Out_Fo:foNode.content_ps curFo:foNode success:^(NSArray *acts) {
        outFoModel.actions = acts;
    } failure:^{
        WLog(@"TOR_行为化失败");
    } oldCheckScore:nil];
}

//MARK:===============================================================
//MARK:                     < FromTOP_反射反应 >
//MARK:===============================================================
-(void) commitFromTOP_ReflexOut{
    [self dataOut_ActionScheme:nil];
}

/**
 *  MARK:--------------------尝试输出信息--------------------
 *  @param outArr : orders里筛选出来的algNode组;
 *
 *  三种输出方式:
 *  1. 反射输出 : reflexOut
 *  2. 激活输出 : absNode信息无conPorts方向的outPointer信息时,将absNode的宏信息尝试输出;
 *  3. 经验输出 : expOut指在absNode或conPort方向有outPointer信息;
 *
 *  功能: 将行为概念组成的长时序,转化为真实输出;
 *  1. 找到行为的具象;
 *  2. 正式执行行为 (小脑);
 */
-(void) dataOut_ActionScheme:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (ARRISOK(outArr)) {
        for (AIKVPointer *algNode_p in outArr) {
            //>1 检查micro_p是否是"输出";
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [Output output_TC:algNode_p];
            [theNV setNodeData:algNode_p lightStr:@"o3"];
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
        [Output output_Mood:AIMoodType_Anxious];
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

@end
