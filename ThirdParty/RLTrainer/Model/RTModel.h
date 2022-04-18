//
//  RTModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/31.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTModelDelegate <NSObject>

-(BOOL) RTModel_Playing;

@end

@interface RTModel : NSObject

@property (weak, nonatomic) id<RTModelDelegate> delegate;
-(void) regist:(NSString*)name target:(NSObject*)target selector:(SEL)selector;
-(void) queue:(NSArray*)names count:(NSInteger)count;

@end
