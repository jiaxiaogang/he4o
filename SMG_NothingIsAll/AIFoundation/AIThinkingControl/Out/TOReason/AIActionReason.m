//
//  AIActionReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/11.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIActionReason.h"
#import "ReasonDemandModel.h"
#import "AIMatchFoModel.h"
#import "AINetUtils.h"
#import "AIPort.h"
#import "TOFoModel.h"
#import "DemandManager.h"
#import "RSResultModelBase.h"

@implementation AIActionReason

/**
 *  MARK:--------------------RDemand行为化--------------------
 *  @version
 *      2021.11.13: 初版,废弃dsFo,并将reasonSubV5由TOR迁移至此RAction中 (参考24101-第3阶段);
 */
-(void) convert2Out_Demand:(ReasonDemandModel*)demand{
    //1. 根据demand取抽具象路径rs;
    NSArray *rs = [theTC.outModelManager getRDemandsBySameClass:demand];
    
    //2. 从具象出抽象,逐一取conPorts (前3条) (参考24127-步骤1);
    NSMutableArray *sumConPorts = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < rs.count; i++) {
        ReasonDemandModel *baseDemand = ARR_INDEX_REVERSE(rs, i);
        NSArray *conPorts = [AINetUtils conPorts_All_Normal:baseDemand.mModel.matchFo];
        conPorts = ARR_SUB(conPorts, 0, 3);
        [sumConPorts addObjectsFromArray:conPorts];
    }
    
    //3. 对conPorts进行FRS稳定性竞争 (参考24127-步骤2);
    NSArray *frsResults = [AIScore FRS_PK:sumConPorts];
    
    //不应期源于反思评价为否 & 且反思子任务也失败的;
    //NSArray *except_ps =
    for (RSResultModelBase *frs in frsResults) {
        
        //a. 排除不应期;
        
        //b. 对首条解决方案,进行行为化_Fo();
        
        //c. 在_Fo()中,进行反思;
        
    }
    
    
    
    //4. 对稳定性评价失败的,加入不应期,并继续循环 (参考24127-步骤3);
    
    
    //5. 将取到稳定性ok的,作为解决方案(加工目标),转_Fo()行为化 (参考24132-行为化1);
    
    
    
    
    
    //3. 不应期 (可以考虑改为将整个demand.actionFoModels全加入不应期);
    NSArray *exceptFoModels = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActNo || item.status == TOModelStatus_ScoreNo;
    }];
    NSMutableArray *except_ps = [TOUtils convertPointersFromTOModels:exceptFoModels];
    [except_ps addObject:demand.mModel.matchFo.pointer];
    
    //4. 收集baseFos (优先从matchFo找dsFo解决方案,其次从matchFo的抽象找dsFo解决方案);
    NSMutableArray *baseFo_ps = [[NSMutableArray alloc] init];
    [baseFo_ps addObject:demand.mModel.matchFo.pointer];
    [baseFo_ps addObjectsFromArray:Ports2Pits([AINetUtils absPorts_All_Normal:demand.mModel.matchFo])];
    
    //5. 从baseFo取dsFo解决方案;
    for (AIKVPointer *baseFo_p in baseFo_ps) {
        AIFoNodeBase *baseFo = [SMGUtils searchNode:baseFo_p];
        NSArray *dsPorts = [AINetUtils dsPorts_All:baseFo];
        if (Log4DirecRef) NSLog(@"\n------- baseFo:%@ -------\n已有方案数:%ld 不应期数:%ld 共有方案数:%ld",Fo2FStr(baseFo),demand.actionFoModels.count,except_ps.count,dsPorts.count);
        
        //7. 打出每条解决方案: 查23172此处dsFo经验只有一条的问题 | 查23204取得dsFo的S嵌套太少的问题;
        for (AIPort *dsPort in dsPorts) if (Log4DirecRef) {
            AIFoNodeBase *dsFo = [SMGUtils searchNode:dsPort.target_p];
            NSLog(@"强度:%ld 不应期:%d FRS评价:%d | %@->%@ (%@)",dsPort.strong.value,[except_ps containsObject:dsPort.target_p],[AIScore FRS:[SMGUtils searchNode:dsPort.target_p]],Pit2FStr(dsPort.target_p),Mvp2Str(dsFo.cmvNode_p),ATType2Str(dsPort.target_p.type));
        }
        //8. 从matchFo找dsPorts解决方案;
        for (AIPort *dsPort in dsPorts) {
            //a. 不应期无效,继续找下个;
            if ([except_ps containsObject:dsPort.target_p]) continue;
            
            //b. 未发生理性评价 (空S评价);
            if (![AIScore FRS:[SMGUtils searchNode:dsPort.target_p]]) continue;
            
            //c. 直接提交行为化 (废弃场景判断,因为fo场景一般mIsC会不通过,而alg判断,完全可以放到行为化过程中判断);
            TOFoModel *foModel = [TOFoModel newWithFo_p:dsPort.target_p base:demand];
            AIFoNodeBase *fo = [SMGUtils searchNode:dsPort.target_p];
            NSLog(@"------->>>>>> R- From mvRefs 新增一例解决方案: %@->%@",Pit2FStr(dsPort.target_p),Mvp2Str(fo.cmvNode_p));
            
            //[self commitReasonSub:foModel demand:demand]; //调用: foModel.begin
            
            
            
            return;
        }
    }
    demand.status = TOModelStatus_ActNo;
    NSLog(@"------->>>>>> R-无计可施");
}

/**
 *  MARK:--------------------Fo行为化--------------------
 */
-(void) convert2Out_Fo:(AIFoNodeBase*)fo{
    
}

@end
