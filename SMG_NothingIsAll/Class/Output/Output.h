//
//  Output.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutputDelegate.h"




/**
 *  MARK:--------------------输出--------------------
 *  1,把
 */
@interface Output : NSObject

@property (weak, nonatomic) id<OutputDelegate> delegate;

@end
