//
//  AINetCMV.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK:===============================================================
//MARK:                     < cmv基本模型 >
//MARK:===============================================================
@class AIKVPointer;
@interface AINetCMV : NSObject

-(void) setCMV:(AIKVPointer*)imv order:(NSArray*)order;

@end
