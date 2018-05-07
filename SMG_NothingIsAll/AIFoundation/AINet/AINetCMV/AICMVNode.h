//
//  AICMVNode.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 杏仁核 >
//MARK:===============================================================
@class AIKVPointer;
@interface AICMVNode : NSObject

@property (strong, nonatomic) NSMutableArray *oorder;
@property (strong, nonatomic) AIKVPointer *cmvPointer;

@end
