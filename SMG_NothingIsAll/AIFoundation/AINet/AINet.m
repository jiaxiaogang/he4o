//
//  AINet.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINet.h"
#import "AINode.h"
#import "AIPointer.h"
#import "NSObject+Extension.h"
#import "AINetIndex.h"
#import "AINetCMV.h"
#import "AIPort.h"
#import "AINetAbs.h"
#import "AINetAbsIndex.h"
#import "AINetDirectionReference.h"
#import "AIOutputReference.h"
#import "AINetOutputIndex.h"
#import "AINetAbsCMV.h"
#import "AIAbsCMVNode.h"
#import "AIKVPointer.h"

@interface AINet () <AINetCMVDelegate,AINetAbsCMVDelegate>

@property (strong, nonatomic) AINetIndex *netIndex; //索引区(皮层/海马)
@property (strong, nonatomic) AINetCMV *netCMV;     //网络树根(杏仁核)
@property (strong, nonatomic) AINetAbs *netAbs;     //抽具象序列
@property (strong, nonatomic) AINetAbsIndex *netAbsIndex;//宏信息索引区(海马)
@property (strong, nonatomic) AINetDirectionReference *netDirectionReference;
@property (strong, nonatomic) AIOutputReference *outputReference;
@property (strong, nonatomic) AINetOutputIndex *outputIndex;
@property (strong, nonatomic) AINetAbsCMV *netAbsCMV;//网络cmv的抽象;

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
    self.netCMV = [[AINetCMV alloc] init];
    self.netCMV.delegate = self;
    self.netAbs = [[AINetAbs alloc] init];
    self.netAbsIndex = [[AINetAbsIndex alloc] init];
    self.netDirectionReference = [[AINetDirectionReference alloc] init];
    self.outputReference = [[AIOutputReference alloc] init];
    self.outputIndex = [[AINetOutputIndex alloc] init];
    self.netAbsCMV = [[AINetAbsCMV alloc] init];
    self.netAbsCMV.delegate = self;
}


//MARK:===============================================================
//MARK:                     < index >
//MARK:===============================================================
-(NSMutableArray*) getAlgsArr:(NSObject*)algsModel {
    if (algsModel) {
        NSDictionary *modelDic = [NSObject getDic:algsModel containParent:true];
        NSMutableArray *algsArr = [[NSMutableArray alloc] init];
        NSString *algsType = NSStringFromClass(algsModel.class);
        
        //1. algsType & dataSource
        for (NSString *dataSource in modelDic.allKeys) {
            //1. 转换AIModel&dataType;//废弃!(参考n12p12)
            //2. 存储索引;
            NSNumber *data = NUMTOOK([modelDic objectForKey:dataSource]);
            AIPointer *pointer = [self.netIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource];
            if (pointer) {
                [algsArr addObject:pointer];
            }
        } 
        return algsArr;
    }
    return nil;
}

//单data装箱
-(AIPointer*) getNetDataPointerWithData:(NSNumber*)data algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    return [self.netIndex getDataPointerWithData:data algsType:algsType dataSource:dataSource];
}

-(void) setItemAlgsReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
    [self.netIndex setIndexReference:indexPointer target_p:target_p difValue:difValue];
}

-(NSArray*) getItemAlgsReference:(AIKVPointer*)pointer limit:(NSInteger)limit {
    return [self.netIndex getIndexReference:pointer limit:limit];
}


//MARK:===============================================================
//MARK:                     < cmv >
//MARK:===============================================================
-(AINetCMVModel*) createCMV:(NSArray*)imvAlgsArr order:(NSArray*)order{
    return [self.netCMV create:imvAlgsArr order:order];
}


/**
 *  MARK:--------------------AINetCMVDelegate--------------------
 */
-(void)aiNetCMV_CreatedNode:(AIKVPointer *)indexPointer nodePointer:(AIKVPointer *)nodePointer{
    if (ISOK(indexPointer, AIKVPointer.class)) {
        if (indexPointer.isOut) {
            //kv_p时,记录node对index的引用;
            [self setItemAlgsReference:(AIKVPointer*)indexPointer target_p:nodePointer difValue:1];
        }else{
            //op时,strong+1 & 记录可输出;
            AIKVPointer *index_op = (AIKVPointer*)indexPointer;
            [self.outputReference setNodePointerToOutputReference:index_op algsType:index_op.algsType dataSource:index_op.dataSource difStrong:1];
        }
    }
}

-(void) aiNetCMV_CreatedCMVNode:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(NSInteger)difStrong{
    [self.netDirectionReference setNodePointerToDirectionReference:cmvNode_p mvAlgsType:mvAlgsType direction:direction difStrong:difStrong];
}

//MARK:===============================================================
//MARK:                     < abs >
//MARK:===============================================================
-(AINetAbsNode*) createAbs:(NSArray*)foNodes refs_p:(NSArray*)refs_p{
    return [self.netAbs create:foNodes refs_p:refs_p];
}


//MARK:===============================================================
//MARK:                     < absIndex >
//MARK:===============================================================
-(AIKVPointer*) getNetAbsIndex_AbsPointer:(NSArray*)refs_p{
    return [self.netAbsIndex getAbsValuePointer:refs_p];
}
-(void) setAbsIndexReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue{
    [self.netAbsIndex setIndexReference:indexPointer target_p:target_p difValue:difValue];
}
-(AIKVPointer*) getItemAbsNodePointer:(AIKVPointer*)absValue_p{
    return [self.netAbsIndex getAbsNodePointer:absValue_p];
}


//MARK:===============================================================
//MARK:                     < directionReference >
//MARK:===============================================================
-(AIPort*) getNetNodePointersFromDirectionReference_Single:(NSString*)mvAlgsType direction:(MVDirection)direction {
    return ARR_INDEX([self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction limit:1], 0);
}

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction limit:(int)limit{
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction limit:limit];
}

-(NSArray*) getNetNodePointersFromDirectionReference:(NSString*)mvAlgsType direction:(MVDirection)direction filter:(NSArray*(^)(NSArray *protoArr))filter{
    return [self.netDirectionReference getNodePointersFromDirectionReference:mvAlgsType direction:direction filter:filter];
}

-(void) setNetNodePointerToDirectionReference:(AIKVPointer*)cmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(int)difStrong{
    [self.netDirectionReference setNodePointerToDirectionReference:cmvNode_p mvAlgsType:mvAlgsType direction:direction difStrong:difStrong];
}

//MARK:===============================================================
//MARK:                     < AIOutputReference >
//MARK:===============================================================
-(void) setNetNodePointerToOutputReference:(AIKVPointer*)outputNode_p algsType:(NSString*)algsType dataSource:(NSString*)dataSource difStrong:(NSInteger)difStrong{
    [self.outputReference setNodePointerToOutputReference:outputNode_p algsType:algsType dataSource:dataSource difStrong:difStrong];
}

-(AIPort*) getNetNodePointersFromOutputReference_Single:(NSString*)algsType dataSource:(NSString*)dataSource limit:(NSInteger)limit{
    return ARR_INDEX([self getNetNodePointersFromOutputReference:algsType dataSource:dataSource limit:1], 0);
}

-(NSArray*) getNetNodePointersFromOutputReference:(NSString*)algsType dataSource:(NSString*)dataSource limit:(NSInteger)limit{
    return [self.outputReference getNodePointersFromOutputReference:algsType dataSource:dataSource limit:limit];
}


//MARK:===============================================================
//MARK:                     < AINetOutputIndex >
//MARK:===============================================================

//小脑索引
-(AIKVPointer*) getOutputIndex:(NSString*)algsType dataSource:(NSString*)dataSource outputObj:(NSNumber*)outputObj {
    if (outputObj) {
        return [self.outputIndex getDataPointerWithData:outputObj algsType:algsType dataSource:dataSource];
    }
    return nil;
}


//MARK:===============================================================
//MARK:                     < absCmv >
//MARK:===============================================================
-(AIAbsCMVNode*) createAbsCMVNode:(AIKVPointer*)absNode_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p{
    return [self.netAbsCMV create:absNode_p aMv_p:aMv_p bMv_p:bMv_p];
}

/**
 *  MARK:--------------------AINetAbsCMVDelegate--------------------
 */
-(void) aiNetCMVNode_createdAbsCMVNode:(AIKVPointer*)absCmvNode_p mvAlgsType:(NSString*)mvAlgsType direction:(MVDirection)direction difStrong:(NSInteger)difStrong{
    [self.netDirectionReference setNodePointerToDirectionReference:absCmvNode_p mvAlgsType:mvAlgsType direction:direction difStrong:difStrong];
}

@end
