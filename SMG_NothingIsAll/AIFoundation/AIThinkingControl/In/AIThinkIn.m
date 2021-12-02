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
#import "AIAnalogy.h"

@interface AIThinkIn ()

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
    ISTitleLog(@"皮层输入");
    
    //2. 收集所有具象父概念的value_ps
    NSMutableArray *parentValue_ps = [[NSMutableArray alloc] init];
    NSMutableArray *subValuePsArr = [[NSMutableArray alloc] init];//2维数组
    for (NSDictionary *item in dics) {
        NSArray *item_ps = [theNet algModelConvert2Pointers:item algsType:algsType];
        [parentValue_ps addObjectsFromArray:item_ps];
        [subValuePsArr addObject:item_ps];
    }
    
    //3. 构建父概念 & 将空场景加入瞬时记忆;
    AIAbsAlgNode *parentAlgNode = [theNet createAbsAlg_NoRepeat:parentValue_ps conAlgs:nil isMem:true isOut:false at:nil ds:nil type:ATDefault];
    //if (parentValue_ps.count == 0) [self.delegate aiThinkIn_AddToShortMemory:parentAlgNode.pointer isMatch:false];
    if (Log4TCInput) NSLog(@"---> 构建InputParent节点:%@",Alg2FStr(parentAlgNode));
    
    //4. 收集本组中,所有概念节点;
    NSMutableArray *fromGroup_ps = [[NSMutableArray alloc] init];
    
    //5. 构建子概念 (抽象概念,并嵌套);
    for (NSArray *subValue_ps in subValuePsArr) {
        AIAbsAlgNode *subAlgNode = [theNet createAbsAlg_NoRepeat:subValue_ps conAlgs:@[parentAlgNode] isMem:true at:nil ds:nil type:ATDefault];
        [fromGroup_ps addObject:subAlgNode.pointer];
        
        //6. 将所有子概念添加到瞬时记忆 (2020.08.17: 由短时记忆替代);
        NSLog(@"InputSub:%@",Alg2FStr(subAlgNode));
    }
    
    //6. NoMv处理;
    for (AIKVPointer *alg_p in fromGroup_ps) {
        [TCInput rInput:[SMGUtils searchNode:alg_p] fromGroup_ps:fromGroup_ps];
    }
}

-(void) dataIn:(NSDictionary*)modelDic algsType:(NSString*)algsType{
    //1. 装箱(除mv有两个元素外一般仅有一个元素)
    NSArray *algsArr = [theNet algModelConvert2Pointers:modelDic algsType:algsType];
    
    //2. 检测imv
    BOOL findMV = [ThinkingUtils dataIn_CheckMV:algsArr];
    
    //3. 分流_mv时
    if (findMV) {
        [TCInput pInput:algsArr];
    }else{
        //1. 打包成algTypeNode;
        AIAlgNodeBase *algNode = [theNet createAbsAlg_NoRepeat:algsArr conAlgs:nil isMem:true isOut:false at:nil ds:nil type:ATDefault];
        
        //2. 加入瞬时记忆 & 识别等;
        [TCInput rInput:algNode fromGroup_ps:@[algNode.pointer]];
    }
}

-(void) dataInFromOutput:(NSArray*)outValue_ps{
    //1. 数据检查
    outValue_ps = ARRTOOK(outValue_ps);
    
    //2. 构建概念
    AIAbsAlgNode *outAlg = [theNet createAbsAlg_NoRepeat:outValue_ps conAlgs:nil isMem:false isOut:true at:nil type:ATDefault];
    
    //3. 加瞬时记忆 & 进行识别
    [TCInput rInput:outAlg fromGroup_ps:@[outAlg.pointer]];
}

//MARK:===============================================================
//MARK:                     < FromTOR >
//MARK:===============================================================

/**
 *  MARK:--------------------反思--------------------
 *  @version
 *      2021.04.13: 除了inner外,对其它时序进行全面支持 (4月27号发现,hngl的代码也会执行);
 */
-(AIShortMatchModel*) dataInFromRethink:(TOFoModel*)toFoModel{
    //1. 数据准备;
    AIFoNodeBase *rethinkFo = nil;
    ReasonDemandModel *baseDemand = ARR_INDEX([TOUtils getBaseDemands_AllDeep:toFoModel], 0);
    
    
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
    return [AIThinkInReason TIR_Fo_FromRethink:rethinkFo baseDemand:baseDemand];
}

@end
