//
//  AIThinkIn.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkIn.h"
#import "ThinkingUtils.h"
#import "AINet.h"
#import "AIAlgNode.h"
#import "AIAbsAlgNode.h"
#import "AIThinkInReason.h"
#import "AIThinkInPercept.h"
#import "AICMVNode.h"
#import "AIShortMatchModel.h"

@implementation AIThinkIn

//MARK:===============================================================
//MARK:                     < FromInput >
//MARK:===============================================================
-(void) dataInWithModels:(NSArray*)dics algsType:(NSString*)algsType{
    //1. 数据检查 (小鸟不能仅传入foodView,而要传入整个视角场景)
    dics = ARRTOOK(dics);
    
    //2. 收集所有具象父概念的value_ps
    NSMutableArray *parentValue_ps = [[NSMutableArray alloc] init];
    NSMutableArray *subValuePsArr = [[NSMutableArray alloc] init];//2维数组
    for (NSDictionary *item in dics) {
        NSArray *item_ps = [theNet algModelConvert2Pointers:item algsType:algsType];
        [parentValue_ps addObjectsFromArray:item_ps];
        [subValuePsArr addObject:item_ps];
    }
    
    //3. 构建父概念 & 将父概念加入瞬时记忆;
    AIAlgNode *parentAlgNode = [theNet createAlgNode:parentValue_ps dataSource:algsType isOut:false isMem:true];
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_AddToShortMemory:)]) {
        [self.delegate aiThinkIn_AddToShortMemory:@[parentAlgNode.pointer]];
    }
    
    //4. 收集本组中,所有概念节点;
    NSMutableArray *fromGroup_ps = [[NSMutableArray alloc] init];
    [fromGroup_ps addObject:parentAlgNode.pointer];
    
    //5. 构建子概念 (抽象概念,并嵌套);
    for (NSArray *subValue_ps in subValuePsArr) {
        AIAbsAlgNode *subAlgNode = [theNet createAbsAlgNode:subValue_ps conAlgs:@[parentAlgNode] dataSource:algsType isMem:true];
        //if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_AddToShortMemory:)]) {
        //    [self.delegate aiThinkIn_AddToShortMemory:@[subAlgNode.pointer]];
        //}
        [fromGroup_ps addObject:subAlgNode.pointer];
        [theNV setNodeData:subAlgNode.pointer];
    }
    
    //6. NoMv处理;
    for (AIKVPointer *alg_p in fromGroup_ps) {
        [self dataIn_NoMV:alg_p fromGroup_ps:fromGroup_ps];
    }
}

-(void) dataIn:(NSDictionary*)modelDic algsType:(NSString*)algsType{
    //1. 装箱(除mv有两个元素外一般仅有一个元素)
    NSArray *algsArr = [theNet algModelConvert2Pointers:modelDic algsType:algsType];
    
    //2. 检测imv
    BOOL findMV = [ThinkingUtils dataIn_CheckMV:algsArr];
    
    //3. 分流_mv时
    if (findMV) {
        [self dataIn_FindMV:algsArr];
    }else{
        //1. 打包成algTypeNode;
        AIAlgNodeBase *algNode = [theNet createAlgNode:algsArr dataSource:algsType isOut:false isMem:true];
        
        //2. 加入瞬时记忆
        if (algNode && self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_AddToShortMemory:)]) {
            [self.delegate aiThinkIn_AddToShortMemory:@[algNode.pointer]];
        }
        
        [theNV setNodeData:algNode.pointer];
        [self dataIn_NoMV:algNode.pointer fromGroup_ps:@[algNode.pointer]];
    }
}

//MARK:===============================================================
//MARK:                     < FromTOR >
//MARK:===============================================================
-(AIShortMatchModel*) dataInFromTORLSPRethink:(AIAlgNodeBase*)rtAlg rtFoContent_ps:(NSArray*)rtFoContent_ps{
    //1. 数据准备
    __block AIShortMatchModel *mModel = nil;
    if (rtAlg && ARRISOK(rtFoContent_ps)) {
        
        //2. 识别时序;
        [AIThinkInReason TIR_Fo:rtFoContent_ps finishBlock:^(AIFoNodeBase *curNode, AIFoNodeBase *matchFo, CGFloat matchValue) {
            mModel.protoFo = curNode;
            mModel.matchFo = matchFo;
            mModel.matchFoValue = matchValue;
        }];
    }
    return mModel;
}

//MARK:===============================================================
//MARK:                     < NoMV >
//MARK:===============================================================
/**
 *  MARK:--------------------输入非mv信息时--------------------
 *  1. 看到西瓜会开心 : TODO: 对自身状态的判断, (比如,看到西瓜,想吃,那么当前状态是否饿)
 *  @param fromGroup_ps : 当前输入批次的整组概念指针;
 */
-(void) dataIn_NoMV:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps{
    //1. 数据准备 (瞬时记忆,理性匹配出的模型);
    __block AIShortMatchModel *mModel = nil;
    mModel.protoAlg_p = algNode_p;
    
    //2. 识别概念;
    [AIThinkInReason dataIn_NoMV:algNode_p fromGroup_ps:fromGroup_ps finishBlock:^(AIAlgNodeBase *isNode, AICMVNodeBase *useNode) {
        mModel.matchAlg = isNode;
        mModel.useNode = useNode;
    }];
    
    //3. 识别时序;
    NSArray *shortMemory = [self.delegate aiThinkIn_GetShortMemory];
    [AIThinkInReason TIR_Fo:shortMemory finishBlock:^(AIFoNodeBase *curNode, AIFoNodeBase *matchFo, CGFloat matchValue) {
        mModel.protoFo = curNode;
        mModel.matchFo = matchFo;
        mModel.matchFoValue = matchValue;
    }];
    
    //4. 传给TOR,做下一步处理;
    [self.delegate aiThinkIn_Commit2TC:mModel];
}


//MARK:===============================================================
//MARK:                     < FindMV >
//MARK:===============================================================

-(void) dataIn_FindMV:(NSArray*)algsArr{
    //1. 联想到mv时,创建CmvModel取到FoNode;
    [AIThinkInPercept dataIn_FindMV:algsArr createMvModelBlock:^AIFrontOrderNode *(NSArray *algsArr) {
        //2. 创建CmvModel取到FoNode;
        AIFrontOrderNode *foNode = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_CreateCMVModel:)]) {
            foNode = [self.delegate aiThinkIn_CreateCMVModel:algsArr];
        }
        return foNode;
    } finishBlock:^(AICMVNode *commitMvNode) {
        //3. 思考mv,需求处理
        if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_CommitPercept:)]) {
            [self.delegate aiThinkIn_CommitPercept:commitMvNode];
        }
    } canAss:^BOOL{
        return [self canAss];
    } updateEnergy:^(CGFloat delta) {
        [self updateEnergy:delta];
    }];
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

//联想前判断;
-(BOOL) canAss{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_EnergyValid)]) {
        return [self.delegate aiThinkIn_EnergyValid];
    }
    return false;
}

//消耗能量值 (目前仅在构建后);
-(void) updateEnergy:(CGFloat)delta{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkIn_UpdateEnergy:)]) {
        [self.delegate aiThinkIn_UpdateEnergy:delta];
    }
}

@end
