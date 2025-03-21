//
//  ThinkingUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "ThinkingUtils.h"
#import "ImvGoodModel.h"
#import "ImvBadModel.h"
#import "ImvAlgsHungerModel.h"
#import "ImvAlgsHurtModel.h"

@implementation ThinkingUtils

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (CMV) >
//MARK:===============================================================
@implementation ThinkingUtils (CMV)

+(BOOL) isBadWithAT:(NSString*)algsType{
    algsType = STRTOOK(algsType);
    if ([NSClassFromString(algsType) isSubclassOfClass:ImvBadModel.class]) {//饥饿感等
        return true;
    }else if ([NSClassFromString(algsType) isSubclassOfClass:ImvGoodModel.class]) {//爽感等;
        return false;
    }
    return false;
}

//是否有向下需求 (目标为下,但delta却+) (饿感上升)
+(BOOL) havDownDemand:(NSString*)algsType delta:(NSInteger)delta {
    BOOL isBad = [ThinkingUtils isBadWithAT:algsType];
    return isBad && delta > 0;
}

//是否有向上需求 (目标为上,但delta却-) (快乐下降)
+(BOOL) havUpDemand:(NSString*)algsType delta:(NSInteger)delta {
    BOOL isGood = ![ThinkingUtils isBadWithAT:algsType];
    return isGood && delta < 0;
}

//是否有任意需求 (坏增加 或 好减少);
+(BOOL) havDemand:(NSString*)algsType delta:(NSInteger)delta{
    return [self havDownDemand:algsType delta:delta] || [self havUpDemand:algsType delta:delta];
}
+(BOOL) havDemand:(AIKVPointer*)cmvNode_p{
    if (!cmvNode_p) return false;
    AICMVNodeBase *cmvNode = [SMGUtils searchNode:cmvNode_p];
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    return [self havDemand:cmvNode_p.algsType delta:delta];
}

+(MVDirection) getDemandDirection:(NSString*)algsType delta:(NSInteger)delta {
    BOOL downDemand = [self havDownDemand:algsType delta:delta];
    BOOL upDemand = [self havUpDemand:algsType delta:delta];
    if (downDemand) {
        return MVDirection_Negative;
    }else if(upDemand){
        return MVDirection_Positive;
    }else{
        return MVDirection_None;
    }
}

//获取索引方向 (有了索引方向后,可供目标方向取用)
+(MVDirection) getMvReferenceDirection:(NSInteger)delta {
    //目前的索引就仅是按照delta正负来构建的;
    if (delta < 0) return MVDirection_Negative;
    else if(delta > 0) return MVDirection_Positive;
    else return MVDirection_None;
}

/**
 *  MARK:--------------------解析algsMVArr--------------------
 *  cmvAlgsArr->mvValue
 */
+(void) parserAlgsMVArrWithoutValue:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSString *algsType))success{
    //1. 数据
    AIKVPointer *delta_p = nil;
    AIKVPointer *urgentTo_p = 0;
    NSString *algsType = DefaultAlgsType;
    
    //2. 数据检查
    for (AIKVPointer *pointer in algsArr) {
        if ([NSClassFromString(pointer.algsType) isSubclassOfClass:ImvAlgsModelBase.class]) {
            if ([@"delta" isEqualToString:pointer.dataSource]) {
                delta_p = pointer;
            }else if ([@"urgentTo" isEqualToString:pointer.dataSource]) {
                urgentTo_p = pointer;
            }
        }
        algsType = pointer.algsType;
    }
    
    //3. 逻辑执行
    if (success) success(delta_p,urgentTo_p,algsType);
}

//cmvAlgsArr->mvValue
+(void) parserAlgsMVArr:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSInteger delta,NSInteger urgentTo,NSString *algsType))success{
    //1. 解析
    [self parserAlgsMVArrWithoutValue:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSString *algsType) {
        
        //2. 转换格式
        NSInteger delta = [NUMTOOK([AINetIndex getData:delta_p]) integerValue];
        NSInteger urgentTo = [NUMTOOK([AINetIndex getData:urgentTo_p]) integerValue];
        
        //3. 回调
        if (success) success(delta_p,urgentTo_p,delta,urgentTo,algsType);
    }];
}

//判断mv是否为持续价值 (比如:饥饿是持续性,疼痛是单发的) (参考32041-TODO1);
+(BOOL) isContinuousWithAT:(NSString*)algsType {
    algsType = STRTOOK(algsType);
    if ([NSStringFromClass(ImvAlgsHungerModel.class) isEqualToString:algsType]) {//持续价值:饿感等;
        return true;
    }else if ([NSStringFromClass(ImvAlgsHurtModel.class) isEqualToString:algsType]) {//单发价值:痛感等;
        return false;
    }
    return false;
}

//判断当前节点的父RDemand任务是不是持续性价值;
+(BOOL) baseRDemandIsContinuousWithAT:(TOModelBase*)subModel {
    ReasonDemandModel *baseRDemand = [SMGUtils filterSingleFromArr:[TOUtils getBaseOutModels_AllDeep:subModel] checkValid:^BOOL(id item) {
        return ISOK(item, ReasonDemandModel.class);
    }];
    if (!baseRDemand) return false;
    return [ThinkingUtils isContinuousWithAT:baseRDemand.algsType];
}

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (In) >
//MARK:===============================================================
@implementation ThinkingUtils (In)

+(BOOL) dataIn_CheckMV:(NSArray*)algResult_ps{
    for (AIKVPointer *pointer in ARRTOOK(algResult_ps)) {
        if ([NSClassFromString(pointer.algsType) isSubclassOfClass:ImvAlgsModelBase.class]) {
            return true;
        }
    }
    return false;
}

/**
 *  MARK:--------------------在主线程跑act--------------------
 */
+(void) runAtTiThread:(Act0)act {
    [self runAtThread:theTC.tiQueue act:act];
}
+(void) runAtToThread:(Act0)act {
    [self runAtThread:theTC.toQueue act:act];
}
+(void) runAtMainThread:(Act0)act {
    [self runAtThread:dispatch_get_main_queue() act:act];
}
+(void) runAtThread:(dispatch_queue_t)queue act:(Act0)act {
    __block Act0 weakAct = act;
    dispatch_async(queue, ^{
        weakAct();
    });
}

+(NSMutableDictionary*) copySPDic:(NSDictionary*)protoSPDic {
    protoSPDic = DICTOOK(protoSPDic);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (id key in protoSPDic.allKeys) {
        AISPStrong *value = [protoSPDic objectForKey:key];
        [result setObject:value.copy forKey:key];
    }
    return result;
}

/**
 *  MARK:--------------------按绝对xy坐标对InputGroupValueModels进行排序--------------------
 */
+(NSArray*) sortInputGroupValueModels:(NSArray*)models levelNum:(NSInteger)levelNum {
    //1. 数据检查：当levelNum未知时，传-1，此时默认为最大层级。
    if (levelNum < 0) levelNum = VisionMaxLevel;
    
    //2. 分别按x/y排序，然后转成排好的index数组返回。
    return [SMGUtils sortSmall2Big:models compareBlock1:^double(InputGroupValueModel *obj) {
        NSInteger radio = powf(3, levelNum - obj.level);//差几层，就乘3的几次方。
        return obj.y * radio;//把x,y都换算到maxLevel层，因为同层的位置才是等价的。
    } compareBlock2:^double(InputGroupValueModel *obj) {
        NSInteger radio = powf(3, levelNum - obj.level);//差几层，就乘3的几次方。
        return obj.x * radio;//把x,y都换算到maxLevel层，因为同层的位置才是等价的。
    } compareBlock3:^double(InputGroupValueModel *obj) {
        return obj.level;
    }];
}

/**
 *  MARK:--------------------计算assTo是否在其该出现的位置（返回符合度）--------------------
 *  @desc 公式：推测下一组码的xy位置 : 与真实assTo的xy位置比较 = 得出位置符合预期程度（参考34053-新方案）。
 *  @result 为保证精度准确，结果以最大粒度层的绝对坐标进行返回。
 */
+(CGRect) getAssToRect:(CGPoint)protoFrom protoTo:(CGPoint)protoTo protoLevel:(NSInteger)protoLevel assFrom:(CGPoint)assFrom assTo:(CGPoint)assTo assLevel:(NSInteger)assLevel {
    //1. 求出proto在最大粒度层的xy差值。
    NSInteger protoRadio = powf(3, VisionMaxLevel - protoLevel);
    CGFloat deltaX = (protoTo.x - protoFrom.x) * protoRadio;
    CGFloat deltaY = (protoTo.y - protoFrom.y) * protoRadio;
    
    //2. 根据assFrom的坐标，和上面求出的差值，推测assTo应该出现的位置范围。
    NSInteger assRadio = powf(3, VisionMaxLevel - assLevel);
    CGFloat assFromX = assFrom.x * assRadio;
    CGFloat assFromY = assFrom.y * assRadio;
    
    //3. 求出assTo应该出现的合理范围（移一倍deltaXY相当于从assFrom到精准推测的assTo中心点，再延伸了一倍deltaXY距离，相当于围绕精准推测位置，画一个deltaXY的范围矩形）。
    //> 所以真实的assTo出现在这个范围矩形的：中心准确=100%，边缘为0%）。
    CGRect targetRect = CGRectMake(assFromX, assFromY, deltaX * 2, deltaY * 2);
    
    //4. 真实assTo的位置。
    CGFloat assToX = assTo.x * assRadio;
    CGFloat assToY = assTo.y * assRadio;
    CGPoint assToPoint = CGPointMake(assToX, assToY);
    
    //5. 判断下是否在合理范围内，并算出符合度。
    
}

@end
