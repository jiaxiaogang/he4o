//
//  TCPlan.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/15.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCPlan.h"

@implementation TCPlan

/**
 *  MARK:--------------------topV2--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  @desc
 *      1. 四种(2x2)TOP模式 (优先取同区工作模式,不行再以不同区工作模式);
 *      2. 调用者只管调用触发,模型生成,参数保留;
 *  @desc P决策模式 (框架: index -> mvNode -> foNode -> algNode -> action);
 *      3. 不指定model (从cmvCache取) (旧注释)
 *      4. 每一轮循环不仅是想下一个singleMvPort;也有可能在当前port上,进行二次思考; (旧注释)
 *      5. 从expCache下,根据可行性,选定一个解决方案; (旧注释)
 *      6. 有需求时,找出outMvModel,尝试决策并解决; (旧注释)
 *  @version
 *      20200430 : v2,四种工作模式版;
 *      20200824 : 将外循环输入推进中循环,改到上一步aiThinkIn_CommitNoMv2TC()中;
 *  @todo
 *      1. 集成活跃度的判断和消耗;
 *      2. 集成outModel;
 *      3. TODOTOMORROW: 下面传给四模式的代码,用bool方式直接返回finish的判断不妥,改之;
 *      2021.01.22: 对ActYes或者OutBack的Demand进行不应期处理 (未完成);
 *  @status
 *      1. R+模式: 废弃状态,此模式暂时用不着;
 *      2. R-模式: 启用状态;
 *      3. P+模式: 废弃状态,此模式暂时用不着;
 *      4. P-模式: 启用状态;
 */
+(void) plan{
    //1. 数据准备
    DemandModel *demand = [theTC.outModelManager getCanDecisionDemand];
    [self plan:demand];
    
    
    //----------TODOTOMORROW20211208: solution代码规划 (参考24192);
    //1. 从root出发,逐层综评;
    //2. 综评之: 理性淘汰的判断;
    //3. 综评之: 感性pk,并继续向sub深入;
    //4. 逐层综评pk,深入到最终节点 (当最终枝点S超过3条时,向前1节,取nextSolution);
    //5. 最终所有层全取完3条solution后,可以做感性淘汰;
    //6. 最终未淘汰且竞争在首位的枝点: 继续solution推进行为化: 取解决方案或输出行为;
    
    
    //后续solution行为化处理:
    //1. 根据>cutIndex筛选 (参考24185-方案1-代码);
    //2. ...
    
    
    
    
    
    
    
    
    
    
}

/**
 *  MARK:--------------------对toModel综合评分--------------------
 *  @desc 对解决方案S进行综合评分;
 *  @result 将rootModel及其下分枝评分全部计算,并存为字典返回 <K=foModel,V=score>;
 */
+(NSDictionary*) score4Solution:(TOFoModel*)model{
    //1. 数据准备;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 从model向下取subModels,遇到R就求和,遇到S就竞争;
    
    model.subDemands
    
    //RDemand在FoModel.subDemands下; (R求和);
    //HDemand在AlgModel.subDemands下; (H必须有解决方案,否则理性淘汰);
    
    
    
    return result;
}

+(void) plan:(DemandModel*)demand{
    
    //2. 同区两个模式之R-;
    if (ISOK(demand, ReasonDemandModel.class)) {
        //a. R-
        ReasonDemandModel *rDemand = (ReasonDemandModel*)demand;
        
        //1. 数据检查
        if (!Switch4RS) return;
        AIFoNodeBase *matchFo = rDemand.mModel.matchFo;
        OFTitleLog(@"TOP.R-", @"\n任务:%@->%@,发生%ld",Fo2FStr(matchFo),Mvp2Str(matchFo.cmvNode_p),(long)rDemand.mModel.cutIndex2);
        
        //2. ActYes等待 或 OutBack反省等待 中时,不进行决策;
        NSArray *waitFos = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
            return item.status == TOModelStatus_ActYes || item.status == TOModelStatus_OuterBack;
        }];
        if (ARRISOK(waitFos)) return;
        
        //3. 行为化;
        [TCSolution rSolution:rDemand];
    }else if(ISOK(demand, PerceptDemandModel.class)){
        
        //TODOTOMORROW20211201: 此处改为和R模式一样,全套从短时记忆树来触发和工作;
        //  a. 此处的mModels循环没啥用,后看该删就删了;
        
        //3. 不同区两个模式 (以最近的识别优先);
        for (NSInteger i = 0; i < theTC.inModelManager.models.count; i++) {
            AIShortMatchModel *mModel = ARR_INDEX_REVERSE(theTC.inModelManager.models, i);
            AIAlgNodeBase *matchAlg = mModel.matchAlg;
            
            //a. 识别有效性判断 (优先直接mv+,不行再mv-迂回);
            if (matchAlg) {
                //b. P-
                [TCSolution pSolution:demand];
            }
        }
    }else if(ISOK(demand, HDemandModel.class)){
        [TCSolution hSolution:demand];
    }
}

@end
