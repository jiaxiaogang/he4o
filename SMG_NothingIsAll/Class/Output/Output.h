//
//  Output.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol OutputDelegate <NSObject>

-(void) output_Text:(NSString*)text;
-(void) output_Face:(NSString*)faceText;

@end

/**
 *  MARK:--------------------输出--------------------
 *  1,把
 */
@interface Output : NSObject

@property (weak, nonatomic) id<OutputDelegate> delegate;
-(void) output_Text:(NSString*)text;
-(void) output_Face:(MoodType)type value:(int)value;

@end
