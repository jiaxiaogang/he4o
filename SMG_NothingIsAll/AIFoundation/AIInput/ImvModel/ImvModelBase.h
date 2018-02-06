//
//  ImvModelBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/2/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImvModelBase : NSObject

@property (assign, nonatomic)  NSInteger value;

-(CGFloat) duration;
-(NSInteger) tagIdentifier;

@end
