//
//  StringAlgs.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------String算法--------------------
 */
@interface AIStringAlgs : NSObject

+(void) commitInput:(NSString*)input;

@end



//MARK:===============================================================
//MARK:                     < String算法结果模型 >
//MARK:===============================================================
@interface AIStringAlgsModel : NSObject

@property (strong,nonatomic) NSString *str;
@property (assign, nonatomic) NSUInteger length;
@property (strong,nonatomic) NSArray *spell;

@end



//MARK:===============================================================
//MARK:                     < char算法结果模型 >
//MARK:===============================================================
@interface AICharAlgsModel : NSObject

@property (assign,nonatomic) char c;

@end
