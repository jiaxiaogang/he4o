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
#import "AIFrontOrderNode.h"
#import "AIShortMatchModel_Simple.h"
#import "TOUtils.h"
#import "TOFoModel.h"
//temp
#import "NVHeUtil.h"

@interface AIThinkIn () <AIThinkInPerceptDelegate>

@property (strong, nonatomic) AIThinkInPercept *tip;

@end

@implementation AIThinkIn

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.tip = [[AIThinkInPercept alloc] init];
    self.tip.delegate = self;
}

//MARK:===============================================================
//MARK:                     < FromInput >
//MARK:===============================================================
/**
 *  MARK:--------------------数据输入--------------------
 *  @version
 *      2020.07.19: 空场景时,不将空场景概念加到瞬时记忆序列中 (因为现在的内类比HN已经不再使用空场景做任何参考,所以其存在无意义,反而会影响到时序全含判断,因为记忆时序中的空场景,往往无法被新的时序包含);
 */
-(void) dataInWithModels:(NSArray*)dics algsType:(NSString*)algsType{
    //1. 数据检查 (小鸟不能仅传入foodView,而要传入整个视角场景)
    dics = ARRTOOK(dics);
    NSLog(@"\n\n------------------------------- 皮层输入 -------------------------------");
    
    //2. 收集所有具象父概念的value_ps
    NSMutableArray *parentValue_ps = [[NSMutableArray alloc] init];
    NSMutableArray *subValuePsArr = [[NSMutableArray alloc] init];//2维数组
    for (NSDictionary *item in dics) {
        NSArray *item_ps = [theNet algModelConvert2Pointers:item algsType:algsType];
        [parentValue_ps addObjectsFromArray:item_ps];
        [subValuePsArr addObject:item_ps];
    }
    
    //3. 构建父概念 & 将空场景加入瞬时记忆;
    AIAbsAlgNode *parentAlgNode = [theNet createAbsAlg_NoRepeat:parentValue_ps conAlgs:nil isMem:true isOut:false ds:algsType];
    //if (parentValue_ps.count == 0) [self.delegate aiThinkIn_AddToShortMemory:parentAlgNode.pointer isMatch:false];
    if (Log4TCInput) NSLog(@"---> 构建InputParent节点:%@",Alg2FStr(parentAlgNode));
    
    //4. 收集本组中,所有概念节点;
    NSMutableArray *fromGroup_ps = [[NSMutableArray alloc] init];
    
    //5. 构建子概念 (抽象概念,并嵌套);
    for (NSArray *subValue_ps in subValuePsArr) {
        AIAbsAlgNode *subAlgNode = [theNet createAbsAlg_NoRepeat:subValue_ps conAlgs:@[parentAlgNode] isMem:true ds:algsType];
        [fromGroup_ps addObject:subAlgNode.pointer];
        
        //6. 将所有子概念添加到瞬时记忆 (2020.08.17: 由短时记忆替代);
        NSLog(@"InputSub:%@",Alg2FStr(subAlgNode));
    }
    
    //6. NoMv处理;
    for (AIKVPointer *alg_p in fromGroup_ps) {
        [self dataIn_NoMV:[SMGUtils searchNode:alg_p] fromGroup_ps:fromGroup_ps];
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
        AIAlgNodeBase *algNode = [theNet createAbsAlg_NoRepeat:algsArr conAlgs:nil isMem:true isOut:false ds:algsType];
        
        //2. 加入瞬时记忆 & 识别等;
        [self dataIn_NoMV:algNode fromGroup_ps:@[algNode.pointer]];
    }
}

-(void) dataInFromOutput:(NSArray*)outValue_ps{
    //1. 数据检查
    outValue_ps = ARRTOOK(outValue_ps);
    
    //2. 构建概念
    AIAbsAlgNode *outAlg = [theNet createAbsAlg_NoRepeat:outValue_ps conAlgs:nil isMem:false isOut:true];
    
    //3. 加瞬时记忆 & 进行识别
    [self dataIn_NoMV:outAlg fromGroup_ps:@[outAlg.pointer]];
}

//MARK:===============================================================
//MARK:                     < FromTOR >
//MARK:===============================================================

/**
 *  MARK:--------------------反思--------------------
 *  @version
 *      2021.04.13: 除了inner外,对其它时序进行全面支持;
 */
-(AIShortMatchModel*) dataInFromRethink:(TOFoModel*)toFoModel{
    //1. 数据准备;
    AIFoNodeBase *rethinkFo = nil;
    
    //2. 反思_HNGL类型;
    if ([TOUtils isHNGL_toModel:toFoModel]) {
        
        //3. 数据准备 (收集除末位外的content为order);
        AIFoNodeBase *fo = [SMGUtils searchNode:toFoModel.content_p];
        NSMutableArray *order = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < fo.content_ps.count - 1; i++) {
            AIShortMatchModel_Simple *simple = [[AIShortMatchModel_Simple alloc] init];
            simple.alg_p = ARR_INDEX(fo.content_ps, i);
            simple.inputTime = [NUMTOOK(ARR_INDEX(fo.deltaTimes, i)) longLongValue];
            [order addObject:simple];
        }
        if (ARRISOK(order)) {
            rethinkFo = [theNet createConFo:order isMem:true]; //将protoAlg_ps构建成时序;
        }
    }else{
        //4. 其它类型,直接取outModel下的时序;
        rethinkFo = [SMGUtils searchNode:toFoModel.content_p];
    }
    
    //5. 反思时序;
    return [AIThinkInReason TIR_Fo_FromRethink:rethinkFo];
}

//MARK:===============================================================
//MARK:                     < NoMV >
//MARK:===============================================================
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
 *      20210413 - TIRFoFromShortMem的参数由matchAFo改为protoFo (参考23014-分析2);
 */
-(void) dataIn_NoMV:(AIAlgNodeBase*)algNode fromGroup_ps:(NSArray*)fromGroup_ps{
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
    [self.delegate aiThinkIn_addShortMatchModel:mModel];
    
    //3. 构建时序 (把每次dic输入,都作为一个新的内存时序);
    NSArray *matchAShortMem = [self.delegate aiThinkIn_GetShortMemory:true];
    mModel.matchAFo = [theNet createConFo:matchAShortMem isMem:false];
    NSArray *protoAShortMem = [self.delegate aiThinkIn_GetShortMemory:false];
    mModel.protoFo = [theNet createConFo:protoAShortMem isMem:false];
    
    //4. 识别时序;
    [AIThinkInReason TIR_Fo_FromShortMem:mModel.protoFo except_ps:@[mModel.protoFo.pointer,mModel.matchAFo.pointer] decoratorInModel:mModel];
    
    //4. 预测;
    [AIThinkInReason tir_Forecast:mModel];
    
    //5. 内类比
    [AIThinkInReason analogyInner:mModel];
    
    //6. 传给TOR,做下一步处理;
    [self.delegate aiThinkIn_Commit2TC:mModel];
    
    //7. 传给TIR,做下一步处理;
    [AIThinkInReason tir_OPushM:mModel];
}


//MARK:===============================================================
//MARK:                     < FindMV >
//MARK:===============================================================

-(void) dataIn_FindMV:(NSArray*)algsArr{
    //1. 联想到mv时,创建CmvModel取到FoNode;
    NSTimeInterval inputTime = [[NSDate date] timeIntervalSince1970];
    [self.tip dataIn_FindMV:algsArr createMvModelBlock:^AIFrontOrderNode *(NSArray *algsArr,BOOL isMatch) {
        //2. 创建CmvModel取到FoNode;
        return [self.delegate aiThinkIn_CreateCMVModel:algsArr inputTime:inputTime isMatch:isMatch];
    } finishBlock:^(AICMVNode *commitMvNode) {
        //3. 思考mv,需求处理
        [self.delegate aiThinkIn_CommitPercept:commitMvNode];
    }];
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

/**
 *  MARK:--------------------AIThinkInPerceptDelegate--------------------
 */
-(NSArray *)tir_getShortMatchModel{
    return [self.delegate aiThinkIn_getShortMatchModel];
}

@end
