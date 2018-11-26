//
//  Output.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------输出--------------------
 *  1,把OUTPUT有时间的话;融入到神经网络中...(小脑机制)
 */
@protocol OutputDelegate <NSObject>

-(void) output_Text:(char)c;
-(void) output_Reactor:(NSString*)reactorId paramNum:(NSNumber*)paramNum;

@end

@interface Output : NSObject

@property (weak, nonatomic) id<OutputDelegate> delegate;

+(Output*) sharedInstance;
+(void) output_Text:(NSNumber*)charNum;
+(void) output_Face:(AIMoodType)type;
+(void) output_Reactor:(NSString*)rds paramNum:(NSNumber*)paramNum;

@end
