//
//  TOOut.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TOOut.h"

@implementation TOOut


-(void) out:(TOAlgModel*)algModel{
    //1. 无论是P-模式的Alg,还是R-中非S的Alg,都要走以下第1,第2,第3级流程;
    //1. 第0级: 本身即是cHav节点,不用行为化,即成功 (但不用递归,等外循环返回行为结果);
    if ([TOUtils isHNGL_toModel:algModel]) {
        
        //TODOTOMORROW20211126: actYes转feedback;
        algModel.status = TOModelStatus_ActYes;//只需要等
        [self.delegate toAction_SubModelActYes:algModel];
    }else if (algModel.content_p.isOut) {
        
        //TODOTOMORROW20211126: isOut转input;
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        OFTitleLog(@"行为输出", @"\n%@",AlgP2FStr(algModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        algModel.status = TOModelStatus_ActYes;
        
        //2. 消耗活跃度并输出
        [theTC updateEnergy:-1.0f];
        [self.delegate toAction_Output:@[algModel.content_p]];
    }else{
        
        //TODOTOMORROW20211125: dsFo废弃
        //1. 此处dsFo已废弃,但arsTime评价还是有必要的,看看迭代下支持新架构;
        //2. 做arsTime评价: (判断solutionFo.alg在demand.fo里是否有抽具象关联);
        //  a. 失败时,转为actYes状态;
        //  b. 通过时,转至chav();
        
        
        //R-模式理性静默成功迭代: R-模式_Hav首先是为了避免forecastAlg,其次才是为了达成curFo解决方案 (参考22153);
        //1. 判断当前是R-模式,则进行ARS_Time评价;
        
        ReasonDemandModel *rDemand = (ReasonDemandModel*)algModel.baseOrGroup.baseOrGroup;//改为取最近R任务rDemand,而不管取几个base.base.base...;
        TOFoModel *dsFo = (TOFoModel*)algModel.baseOrGroup;
        BOOL arsTime = [AIScore ARS_Time:dsFo demand:rDemand];
        if (!arsTime) {
            //2. 评价不通过,则直接ActYes,等待其自然出现 (参考22153-A2);
            NSLog(@"==> arsTime评价不急,子弹再飞一会儿");
            algModel.status = TOModelStatus_ActYes;
            [self.delegate toAction_SubModelActYes:algModel];
            return;
        }
        
        //TODOTOMORROW20211126: notOut转jump;
        [self chav:algModel];
    }
}

-(void) chav:(TOAlgModel*)algModel{
    //跳转后转到TIR里作为输入;
    
    //3. 数据检查curAlg
    AIAlgNodeBase *curAlg = [SMGUtils searchNode:algModel.content_p];
    OFTitleLog(@"行为化_Hav", @"\nC:%@",Alg2FStr(curAlg));
    
    
    
    
    //TODOTOMORROW20211125: PM废弃 & HN暂不废弃;
    //1. 此处废除mIsC判断,因为PM废除,mIsC不再需要,而短时记忆树里的任何cutIndex已发生的部分,都可用于帮助cHav取解决方案;
    //2. cHav取到的结果sulutionFo做为理性子任务,然后将HNFo的末位,传到TO.regroup(),然后inReflect...
    //3. 此处HN内类比先不废弃,先这么写,等后面再考虑废弃之 (参考24171-3);
    
    
    
    //5. 去掉不应期 (以下两种用哪个留哪个);
    NSArray *except_ps = TOModels2Pits([SMGUtils filterArr:algModel.subModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActNo;
    }]);
    NSArray *except_ps2 = [TOUtils convertPointersFromTOModels:algModel.actionFoModels];
    
    //4. 第3级: 数据检查hAlg_根据type和value_p找ATHav
    AIKVPointer *relativeFo_p = [AINetService getInnerV3_HN:curAlg aAT:algModel.content_p.algsType aDS:algModel.content_p.dataSource type:ATHav except_ps:except_ps];
    if (Log4ActHav) NSLog(@"getInnerAlg(有): 根据:%@ 找:%@_%@ \n联想结果:%@ %@",Alg2FStr(curAlg),algModel.content_p.algsType,algModel.content_p.dataSource,Pit2FStr(relativeFo_p),relativeFo_p ? @"↓↓↓↓↓↓↓↓" : @"无计可施");
    
    //6. 只要有善可尝试的方式,即从首条开始尝试;
    if (relativeFo_p) {
        TOFoModel *foModel = [TOFoModel newWithFo_p:relativeFo_p base:algModel];
        [self.delegate toAction_SubModelBegin:foModel];
        
        //TODOTOMORROW20211125: 将jump跳转到TI中做为新的输入流程 (并进行识别in反思);
        //1. jump通过后,此处转action();
        
        
        [theTI jump];
        
        
        
        return;
    }
    
    //10. 所有mModel都没成功行为化一条,则失败 (无计可施);
    algModel.status = TOModelStatus_ActNo;
    [self.delegate toAction_SubModelFailure:algModel];
    
    
}

@end
