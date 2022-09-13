//
//  AIMatchFoModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/23.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIMatchFoModel.h"

@interface AIMatchFoModel ()

/**
 *  MARK:--------------------当前反馈帧的相近度--------------------
 *  @desc 比对feedback输入的protoAlg和当前等待反馈的itemAlg之间相近度,并存到此值下;
 *  @callers
 *      1. 有反馈时,计算并赋值;
 *      2. 跳转下帧时,恢复默认值0;
 */
@property (assign, nonatomic) CGFloat feedbackNear;

@end

@implementation AIMatchFoModel

+(AIMatchFoModel*) newWithMatchFo:(AIKVPointer*)matchFo maskFo:(AIKVPointer*)maskFo sumNear:(CGFloat)sumNear nearCount:(NSInteger)nearCount indexDic:(NSDictionary*)indexDic cutIndex:(NSInteger)cutIndex{
    AIMatchFoModel *model = [[AIMatchFoModel alloc] init];
    model.matchFo = matchFo;
    model.maskFo = maskFo;
    model.sumNear = sumNear;
    model.nearCount = nearCount;
    model.indexDic = indexDic;
    model.cutIndex = cutIndex;
    model.scoreCache = defaultScore; //评分缓存默认值;
    return model;
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

//当前帧有反馈;
-(void) feedbackFrame:(AIKVPointer*)fbProtoAlg {
    //1. 数据准备;
    AIFoNodeBase *matchFo = [SMGUtils searchNode:self.matchFo];
    AIKVPointer *waitAlg_p = ARR_INDEX(matchFo.content_ps, self.cutIndex + 1);
    
    //2. 更新status和near;
    self.status = TIModelStatus_OutBackReason;
    self.feedbackNear = [AIAnalyst compareCansetAlg:waitAlg_p protoAlg:fbProtoAlg];
}

//推进至下一帧;
-(void) forwardFrame {
    //1. 推进到下一帧;
    self.cutIndex ++;
    
    //2. 更新匹配度分子分母值;
    self.sumNear += self.feedbackNear;
    self.nearCount ++;
    
    //3. 状态重置 & 失效重置为false & 反馈相近度重置 & 重置scoreCache(触发重新计算mv评分);
    self.status = TIModelStatus_LastWait;
    self.isExpired = false;
    self.feedbackNear = 0;
    self.scoreCache = defaultScore;
    
    //5. 更新indexDic;
    //[indexDic setObject:@(curIndex) forKey:@(maskFoIndex)];
    
    // > 取到fbProtoAlg的index和当前waitAlg的index(应该就是cutIndex),然后更新indexDic;
    // > 注意: 原来的indexDic是源于时序识别时的,而此时的反馈,未必与原protoFo还是同一个时序,所以这个需要注意并分析下;
    //          > 如果不是同一个时序,这里的indexDic在使用时,就无法取得结果,除非把indexDic改成protoAlg序列 (content_ps?)
    
    //5. 触发器 (非末帧继续R反省,末帧则P反省);
    //[AITime setTimeTrigger:deltaTime trigger:^{
    // > 这里看能不能直接调用forecast_Single();
}

//匹配度计算
-(CGFloat) matchFoValue {
    return self.nearCount > 0 ? self.sumNear / self.nearCount : 1;
}

/**
 *  MARK:--------------------NSCoding--------------------
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.matchFo = [aDecoder decodeObjectForKey:@"matchFo"];
        self.maskFo = [aDecoder decodeObjectForKey:@"maskFo"];
        self.sumNear = [aDecoder decodeFloatForKey:@"sumNear"];
        self.nearCount = [aDecoder decodeIntegerForKey:@"nearCount"];
        self.status = [aDecoder decodeIntegerForKey:@"status"];
        self.indexDic = [aDecoder decodeObjectForKey:@"indexDic"];
        self.cutIndex = [aDecoder decodeIntegerForKey:@"cutIndex"];
        self.matchFoStrong = [aDecoder decodeIntegerForKey:@"matchFoStrong"];
        self.scoreCache = [aDecoder decodeFloatForKey:@"scoreCache"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.matchFo forKey:@"matchFo"];
    [aCoder encodeObject:self.maskFo forKey:@"maskFo"];
    [aCoder encodeFloat:self.sumNear forKey:@"sumNear"];
    [aCoder encodeInteger:self.nearCount forKey:@"nearCount"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeObject:self.indexDic forKey:@"indexDic"];
    [aCoder encodeInteger:self.cutIndex forKey:@"cutIndex"];
    [aCoder encodeInteger:self.matchFoStrong forKey:@"matchFoStrong"];
    [aCoder encodeFloat:self.scoreCache forKey:@"scoreCache"];
}

@end
