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
#import "AINetIndexReference.h"
#import "AIFrontOrderNode.h"
#import "AINetUtils.h"
#import "AIAlgNodeManager.h"
#import "Output.h"
#import "AIAlgNode.h"
#import "NSString+Extension.h"
#import "AINetIndexUtils.h"
#import "AIAbsAlgNode.h"

@interface AINet ()

@property (strong, nonatomic) AINetIndex *netIndex; //索引区(皮层/海马)
@property (strong, nonatomic) AIMvFoManager *mvFoManager;     //网络树根(杏仁核)
@property (strong, nonatomic) AIAbsFoManager *absFoManager; //抽象时序管理器
@property (strong, nonatomic) AINetDirectionReference *netDirectionReference;
@property (strong, nonatomic) AIAbsCMVManager *absCmvManager;//抽象mv管理器;
@property (strong, nonatomic) AINetIndexReference *reference;

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
    self.netIndex = [[AINetIndex alloc] init];
    self.mvFoManager = [[AIMvFoManager alloc] init];
    self.absFoManager = [[AIAbsFoManager alloc] init];
    self.netDirectionReference = [[AINetDirectionReference alloc] init];
    self.reference = [[AINetIndexReference alloc] init];
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
        AIPointer *pointer = [self.netIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource isOut:false];
        if (pointer) {
            [algsArr addObject:pointer];
        }
    }
    return algsArr;
}

//单data装箱
-(AIKVPointer*) getNetDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    return [self.netIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource isOut:false];
}

//小脑索引
-(AIKVPointer*) getOutputIndex:(NSString*)algsType outputObj:(NSNumber*)outputObj {
    if (outputObj) {
        return [self.netIndex getDataPointerWithData:outputObj algsType:algsType dataSource:DefaultDataSource isOut:true];
    }
    return nil;
}


//MARK:===============================================================
//MARK:                     < reference >
//MARK:===============================================================

//-(void) setNetReference:(AIKVPointer*)value_p target_p:(AIKVPointer*)target_p difValue:(int)difValue{
//    if (!target_p.isMem) {
//        [self.reference setReference:value_p target_p:target_p difStrong:difValue];
//    }else{
//        [AINetUtils insertRefPorts_MemNode:target_p passiveRef_p:value_p];
//    }
//}

-(NSArray*) getNetReference:(AIKVPointer*)pointer limit:(NSInteger)limit {
    return [self.reference getReference:pointer limit:limit];
}


//MARK:===============================================================
//MARK:                     < cmv >
//MARK:===============================================================
-(AIFrontOrderNode*) createCMV:(NSArray*)imvAlgsArr order:(NSArray*)order{
    return [self.mvFoManager create:imvAlgsArr order:order];
}
-(AICMVNode*) createConMv:(NSArray*)imvAlgsArr{
    return [self.mvFoManager createConMv:imvAlgsArr];
}
-(AICMVNode*) createConMv:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p at:(NSString*)at isMem:(BOOL)isMem{
    return [self.mvFoManager createConMv:urgentTo_p delta_p:delta_p at:at isMem:isMem];
}


//MARK:===============================================================
//MARK:                     < conFo >
//MARK:===============================================================
-(AIFrontOrderNode*) createConFo:(NSArray*)order_ps isMem:(BOOL)isMem{
    return [AIMvFoManager createConFo:order_ps isMem:isMem];
}


//MARK:===============================================================
//MARK:                     < absFo >
//MARK:===============================================================
-(AINetAbsFoNode*) createAbsFo_Outside:(AIFoNodeBase*)foA foB:(AIFoNodeBase*)foB orderSames:(NSArray*)orderSames{
    if (ISOK(foA, AIFoNodeBase.class) && ISOK(foB, AIFoNodeBase.class)) {
        return [self.absFoManager create:@[foA,foB] orderSames:orderSames];
    }
    return nil;
}
-(AINetAbsFoNode*) createAbsFo_Inner:(AIFoNodeBase*)conFo orderSames:(NSArray*)orderSames{
    if (ISOK(conFo, AIFoNodeBase.class)) {
        return [self.absFoManager create:@[conFo] orderSames:orderSames];
    }
    return nil;
}
-(AINetAbsFoNode*) createAbsFo_General:(NSArray*)conFos content_ps:(NSArray*)content_ps{
    if (ARRISOK(conFos)) {
        return [self.absFoManager create:conFos orderSames:content_ps];
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < directionReference >
//MARK:===============================================================
//-(AIPort*) getNetNodePointersFromDirectionReference_Single:(NSString*)mvAlgsType direction:(MVDirection)direction {
//    return ARR_INDEX([self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction limit:1], 0);
//}

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem limit:(int)limit {
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction isMem:isMem limit:limit];
}

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction isMem:(BOOL)isMem filter:(NSArray*(^)(NSArray *protoArr))filter{
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction isMem:isMem filter:filter];
}

-(void) setMvNodeToDirectionReference:(AICMVNodeBase*)cmvNode difStrong:(NSInteger)difStrong {
    //1. 数据检查
    if (cmvNode) {

        //2. 取方向(delta的正负)
        NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
        MVDirection direction = delta < 0 ? MVDirection_Negative : MVDirection_Positive;

        //3. 取mv方向索引;
        AIKVPointer *mvReference_p = [SMGUtils createPointerForDirection:cmvNode.pointer.algsType direction:direction];

        //4. 将mvNode地址,插入到强度序列,并存储;
        [AINetUtils insertRefPorts_AllMvNode:cmvNode.pointer value_p:mvReference_p difStrong:difStrong];
    }
}


//MARK:===============================================================
//MARK:                     < absCmv >
//MARK:===============================================================
-(AIAbsCMVNode*) createAbsCMVNode_Outside:(AIKVPointer*)absFo_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p{
    return [self.absCmvManager create:absFo_p aMv_p:aMv_p bMv_p:bMv_p];
}

-(AIAbsCMVNode*) createAbsCMVNode_Inner:(AIKVPointer*)absFo_p conMv_p:(AIKVPointer*)conMv_p{
    if (POINTERISOK(conMv_p)) {
        return [self.absCmvManager create:absFo_p conMvPs:@[conMv_p]];
    }
    return nil;
}
-(AIAbsCMVNode*) createAbsMv:(AIKVPointer*)absFo_p conMvs:(NSArray*)conMvs at:(NSString*)at ds:(NSString*)ds urgentTo_p:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p{
    return [self.absCmvManager create_General:absFo_p conMvs:conMvs at:at ds:ds urgentTo_p:urgentTo_p delta_p:delta_p];
}


//MARK:===============================================================
//MARK:                     < algNode >
//MARK:===============================================================
//-(AIAlgNode*) createAlgNode:(NSArray*)algsArr isOut:(BOOL)isOut isMem:(BOOL)isMem{
//    return [AIAlgNodeManager createAlgNode:algsArr isOut:isOut isMem:isMem];
//}
//-(AIAlgNode*) createAlgNode:(NSArray*)algsArr dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem{
//    return [AIAlgNodeManager createAlgNode:algsArr dataSource:dataSource isOut:isOut isMem:isMem];
//}
//
//-(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs dataSource:(NSString*)dataSource isMem:(BOOL)isMem{
//    if (ARRISOK(conAlgs)) {
//        return [AIAlgNodeManager createAbsAlgNode:value_ps conAlgs:conAlgs dataSource:dataSource isMem:isMem];
//    }
//    return nil;
//}

/**
 *  MARK:--------------------构建抽象概念_防重--------------------
 */
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs isMem:isMem dsBlock:nil isOutBlock:nil];
}
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem ds:(NSString*)ds{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs isMem:isMem dsBlock:^NSString *{
        return ds;
    } isOutBlock:nil];
}
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem isOut:(BOOL)isOut{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs isMem:isMem dsBlock:nil isOutBlock:^BOOL{
        return isOut;
    }];
}
-(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem isOut:(BOOL)isOut ds:(NSString*)ds{
    return [AIAlgNodeManager createAbsAlg_NoRepeat:value_ps conAlgs:conAlgs isMem:isMem dsBlock:^NSString *{
        return ds;
    } isOutBlock:^BOOL{
        return isOut;
    }];
}

@end
