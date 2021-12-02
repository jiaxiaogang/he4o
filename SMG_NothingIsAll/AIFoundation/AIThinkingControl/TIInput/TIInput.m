//
//  TIInput.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TIInput.h"

@implementation TIInput

/**
 *  MARK:--------------------输入非mv信息时--------------------
 *  @param fromGroup_ps : 当前输入批次的整组概念指针;
 *  @todo
 *      1. 远古TODO: 看到西瓜会开心 : 对自身状态的判断, (比如,看到西瓜,想吃,那么当前状态是否饿)
 *          > 已解决,废弃了useNode,并由mModel替代,且会交由demandManager做此处理;
 *      2. TODOWAIT: TIR_Alg识别后,要进行类比,并构建网络关联; (参考n16p7)
 *      3. 点击饥饿,再点击乱投,此处返回了matchFo:nil matchValue:0;
 *          > 已解决,因为fromMemShort是4层alg,而fromRethink是两层;
 *  @version
 *      20200416 - 修复时序识别的bug: 因概念节点去重不够,导致即使概念内容一致,在时序识别时,也会无法匹配 (参考n19p5-A组BUG4);
 *      20200731 - 将protoFo和matchAFo的构建改为isMem=false (因为构建到内存的话,在内类比构建时序具象指向为空,参考20151-BUG);
 *      20200817 - 赋值protoAlg和matchAlg即是存瞬时记忆,因为瞬时与短时整合了;
 *      20201019 - 将mModel更提前保留至mModelManager中;
 *      20201112 - TIR_Fo支持不应其except_ps,将protoF和matchAF都设为不应期,避免AF识别P回来 (参考21144);
 *      20201113 - 构建matchAFo时,MatchA为空时,兼容取part首条,否则会导致时序识别失败 (参考21144);
 *      20210118 - 支持生物钟触发器 (未完成) (参考22052-1);
 *      20210119 - 支持TIR_OPushM (参考22052-2);
 *      20211016 - 将预测调整到R决策之后,因为R决策总会卡住,而预测中将来的UI变化迟迟不来 (参考24058-方案1);
 *      20211017 - 在执行决策前,先到OPushM将TIModel.status更新了,因为有些IRT触发器已经失效了 (参考24061);
 */
+(void) rInput:(AIAlgNodeBase*)algNode fromGroup_ps:(NSArray*)fromGroup_ps{
    //1. 数据准备 (瞬时记忆,理性匹配出的模型);
    __block AIShortMatchModel *mModel = [[AIShortMatchModel alloc] init];
    mModel.protoAlg = algNode;
    mModel.inputTime = [[NSDate date] timeIntervalSince1970];
    
    //2. 识别概念;
    [AIThinkInReason TIR_Alg:algNode.pointer fromGroup_ps:fromGroup_ps complete:^(NSArray *_matchAlgs, NSArray *_partAlg_ps) {
        mModel.matchAlgs = _matchAlgs;
        mModel.partAlg_ps = _partAlg_ps;
    }];
    
    //3. 将mModel保留 (只有先保留后,构建时序时,才会含新帧概念);
    [theTC.inModelManager add:mModel];
    
    //4. 转regroup
    [TIRegroup rRegroup:mModel];
}

+(void) pInput:(NSArray*)algsArr{
    [TIRegroup pRegroup:algsArr];
}

+(void) jump:(TOAlgModel*)algModel{
    [TODemand hDemand:algModel];
}

@end
