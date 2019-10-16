//
//  AIThinkOutReason.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AIThinkOutReasonDelegate <NSObject>

//更新理性mv到demandManager
-(void) aiThinkOutReason_CommitDemand:(NSInteger)delta algsType:(NSString*)algsType urgentTo:(NSInteger)urgentTo;

//更新理性mv到激活缓存
-(void) aiThinkOutReason_CommitActive:(AIKVPointer*)act_p;

//更新思维活跃度
-(void) aiThinkOutReason_UpdateEnergy:(CGFloat)delta;

@end

/**
 *  MARK:--------------------理性ThinkOut部分--------------------
 */
@class AICMVNodeBase,AIAlgNodeBase,AIFoNodeBase;
@interface AIThinkOutReason : NSObject

@property (weak, nonatomic) id<AIThinkOutReasonDelegate> delegate;


/**
 *  MARK:--------------------TOR方法主入口--------------------
 *  @param useNode      : 旧有useNode (先保留,没什么用再删掉);
 *  @param matchValue   : 匹配度
 *  @param protoAlg_p   : 输入的原始概念
 *  @param matchAlg     : 识别的匹配概念
 *  @param protoFo      : 输入的原始时序
 *  @param matchFo      : 识别的匹配时序
 */
-(void) dataOut:(AICMVNodeBase *)useNode
     matchValue:(CGFloat)matchValue
     protoAlg_p:(AIKVPointer *)protoAlg_p
       matchAlg:(AIAlgNodeBase *)matchAlg
        protoFo:(AIFoNodeBase *)protoFo
        matchFo:(AIFoNodeBase *)matchFo;

@end
