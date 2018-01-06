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
@interface Output : NSObject

-(void) output_Text:(NSString*)text;
-(void) output_Face:(MoodType)type value:(int)value;

@end
