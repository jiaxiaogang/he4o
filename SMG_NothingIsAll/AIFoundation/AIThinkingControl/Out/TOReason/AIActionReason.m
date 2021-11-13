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

@implementation AIActionReason

/**
 *  MARK:--------------------RDemand行为化--------------------
 *  @version
 *      2021.11.13: 初版,废弃dsFo,并将reasonSubV5由TOR迁移至此RAction中 (参考24101-第3阶段);
 */
-(void) convert2Out_Demand:(ReasonDemandModel*)demand{
    
    
    //TODOTOMORROW20211111-废弃dsFo;
    //1. 根据demand取抽具象路径rs;
    //2. 对所有fo进行FRS-SP稳定性竞争评价;
    
    //3. 不用束波求和,仅对场景直接做稳定性竞争,并以场景为目标修正A和V (注: A有可能不必管,只需要修正V);
    //4. 理清此处,是直接对负mv的RDemand.Fo;
    //          a. 之间做稳定性竞争 (本来就是负mv的fo,它的SP经历肯定是S,不大好吧?);
    //          b. 还是对它下面的SPFo之间做竞争 (即找出其中P的部分,并做竞争);
    //          c. 需结合此处习得的数据,对比下,看怎样更合适;
    
    
    
    
    
    
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

@end
