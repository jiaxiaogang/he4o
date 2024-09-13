//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "AIPointer.h"
#import "AINetIndex.h"
#import "AIMvFoManager.h"
#import "AIPort.h"
#import "AIAbsFoManager.h"
#import "AINetDirectionReference.h"
#import "AIAbsCMVManager.h"
#import "AIAbsCMVNode.h"
#import "AIKVPointer.h"
#import "AIFrontOrderNode.h"
#import "AINetUtils.h"
#import "AIAlgNodeManager.h"
#import "Output.h"
#import "AIAlgNode.h"
#import "NSString+Extension.h"
#import "AIAbsAlgNode.h"
#import "ThinkingUtils.h"

@interface AINet ()

//@property (strong, nonatomic) AINetIndex *netIndex; //索引区(皮层/海马)
@property (strong, nonatomic) AIMvFoManager *mvFoManager;     //网络树根(杏仁核)
@property (strong, nonatomic) AIAbsFoManager *absFoManager; //抽象时序管理器
@property (strong, nonatomic) AINetDirectionReference *netDirectionReference;
@property (strong, nonatomic) AIAbsCMVManager *absCmvManager;//抽象mv管理器;

@end


@implementation AINet

static AINet *_instance;
+(AINet*) sharedInstance{
    if (_instance == nil) {
        _instance = [[AINet alloc] init];
    }
    return _instance;
}


-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    //self.netIndex = [[AINetIndex alloc] init];
    self.mvFoManager = [[AIMvFoManager alloc] init];
    self.absFoManager = [[AIAbsFoManager alloc] init];
    self.netDirectionReference = [[AINetDirectionReference alloc] init];
    self.absCmvManager = [[AIAbsCMVManager alloc] init];
}


//MARK:===============================================================
//MARK:                     < index >
//MARK:===============================================================
-(NSMutableArray*) algModelConvert2Pointers:(NSDictionary*)modelDic algsType:(NSString*)algsType{
    //1. 数据准备
    NSMutableArray *algsArr = [[NSMutableArray alloc] init];
    modelDic = DICTOOK(modelDic);

    //2. 循环装箱
    for (NSString *dataSource in modelDic.allKeys) {

        //3. 存储索引 & data;
        NSNumber *data = NUMTOOK([modelDic objectForKey:dataSource]);
        AIPointer *pointer = [AINetIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource isOut:false];
        if (pointer) {
            [algsArr addObject:pointer];
        }
    }
    return algsArr;
}

//单data装箱
-(AIKVPointer*) getNetDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource isOut:(BOOL)isOut{
    return [AINetIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource isOut:isOut];
}

//小脑索引
-(AIKVPointer*) getOutputIndex:(NSString*)algsType outputObj:(NSNumber*)outputObj {
    if (outputObj) {
        return [AINetIndex getDataPointerWithData:outputObj algsType:algsType dataSource:DefaultDataSource isOut:true];
    }
    return nil;
}


//MARK:===============================================================
//MARK:                     < cmv >
//MARK:===============================================================
-(AIFoNodeBase*) createCMVFo:(NSTimeInterval)inputTime order:(NSArray*)order mv:(AICMVNodeBase*)mv{
    return [self.mvFoManager create:inputTime order:order mv:mv];
}
-(AICMVNodeBase*) createConMv:(NSArray*)imvAlgsArr{
    return [self.mvFoManager createConMv:imvAlgsArr];
}
-(AICMVNodeBase*) createConMv:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p at:(NSString*)at {
    return [self.mvFoManager createConMv:urgentTo_p delta_p:delta_p at:at];
}


//MARK:===============================================================
//MARK:                     < conFo >
//MARK:===============================================================
/**
 *  MARK:--------------------构建conFo--------------------
 *  @result notnull
 */
-(AIFoNodeBase*) createConFo_NoRepeat:(NSArray*)order{
    return [AIMvFoManager createConFo_NoRepeat:order noRepeatArea_ps:nil difStrong:1];
}

-(AIFoNodeBase*) createConFoForCanset:(NSArray*)order sceneFo:(AIFoNodeBase*)sceneFo sceneTargetIndex:(NSInteger)sceneTargetIndex {
    return [AIMvFoManager createConFoForCanset:order sceneFo:sceneFo sceneTargetIndex:sceneTargetIndex];
}


//MARK:===============================================================
//MARK:                     < absFo >
//MARK:===============================================================
//-(AINetAbsFoNode*) createAbsFo_General:(NSArray*)conFos content_ps:(NSArray*)content_ps difStrong:(NSInteger)difStrong ds:(NSString*)ds{
//    return [self.absFoManager create:conFos orderSames:content_ps difStrong:difStrong dsBlock:^NSString *{
//        return ds;
//    }];
//}
-(HEResult*) createAbsFo_NoRepeat:(NSArray*)content_ps protoFo:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo difStrong:(NSInteger)difStrong type:(AnalogyType)type protoIndexDic:(NSDictionary*)protoIndexDic assIndexDic:(NSDictionary*)assIndexDic outConAbsIsRelate:(BOOL*)outConAbsIsRelate noRepeatArea_ps:(NSArray*)noRepeatArea_ps{
    return [self.absFoManager create_NoRepeat:content_ps protoFo:protoFo assFo:assFo difStrong:difStrong type:type protoIndexDic:protoIndexDic assIndexDic:assIndexDic outConAbsIsRelate:outConAbsIsRelate noRepeatArea_ps:noRepeatArea_ps];
}

//MARK:===============================================================
//MARK:                     < directionReference >
//MARK:===============================================================

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(int)limit {
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction limit:limit];
}

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction filter:(NSArray*(^)(NSArray *protoArr))filter{
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction filter:filter];
}

-(void) setMvNodeToDirectionReference:(AICMVNodeBase*)cmvNode difStrong:(NSInteger)difStrong {
    //1. 数据检查
    if (cmvNode) {

        //2. 取方向(delta的正负)
        NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
        MVDirection direction = [ThinkingUtils getMvReferenceDirection:delta];
        
        //3. 取mv方向索引;
        AIKVPointer *mvReference_p = [SMGUtils createPointerForDirection:cmvNode.pointer.algsType direction:direction];

        //4. 将mvNode地址,插入到强度序列,并存储;
        [AINetUtils insertRefPorts_AllMvNode:cmvNode value_p:mvReference_p difStrong:difStrong];
    }
}


//MARK:===============================================================
//MARK:                     < absCmv >
//MARK:===============================================================
-(AIAbsCMVNode*) createAbsCMVNode_Outside:(AIKVPointer*)absFo_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p{
    return [self.absCmvManager create:absFo_p aMv_p:aMv_p bMv_p:bMv_p];
}


//MARK:===============================================================
//MARK:                     < algNode >
//MARK:===============================================================

/**
 *  MARK:--------------------构建抽象概念_防重--------------------
 */
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs {
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs at:nil ds:nil isOutBlock:nil type:ATDefault];
}
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs at:(NSString*)at type:(AnalogyType)type{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs at:at ds:nil isOutBlock:nil type:type];
}
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs at:at ds:ds isOutBlock:nil type:type];
}
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isOut:(BOOL)isOut at:(NSString*)at type:(AnalogyType)type{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs at:at ds:nil isOutBlock:^BOOL{
        return isOut;
    } type:type];
}
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isOut:(BOOL)isOut at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs at:at ds:ds isOutBlock:^BOOL{
        return isOut;
    } type:type];
}

/**
 *  MARK:--------------------构建空概念_防重 (参考29031-todo1)--------------------
 */
//-(AIAlgNodeBase*)createEmptyAlg_NoRepeat:(NSArray*)conAlgs {
//    return [AIAlgNodeManager createEmptyAlg_NoRepeat:conAlgs];
//}

@end
