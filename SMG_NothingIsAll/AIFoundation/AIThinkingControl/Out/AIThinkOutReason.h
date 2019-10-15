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

@end

/**
 *  MARK:--------------------理性ThinkOut部分--------------------
 */
@class AICMVNodeBase,AIAlgNodeBase,AIFoNodeBase;
@interface AIThinkOutReason : NSObject

@property (weak, nonatomic) id<AIThinkOutReasonDelegate> delegate;

-(void) dataOut:(AIKVPointer *)targetAlg_p matchAlg:(AIAlgNodeBase *)matchAlg useNode:(AICMVNodeBase *)useNode matchFo:(AIFoNodeBase *)matchFo matchValue:(CGFloat)matchValue shortMemFo:(AIFoNodeBase *)shortMemFo;

@end
