//
//  AIChar.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIObject.h"

@interface AIChar : AIObject

+(AIChar *) newWithContent:(unichar)content;
+(AIChar *) newWithContentByString:(NSString *)str;
@property (assign, nonatomic) unichar content;

@end


/**
 *  MARK:--------------------本地存储--------------------
 */
@interface AIChar (Store)



@end
