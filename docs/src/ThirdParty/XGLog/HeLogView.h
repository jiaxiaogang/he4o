//
//  HeLogView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeLogView : UIView

@property (assign, nonatomic) BOOL stop;//停止工作;

-(void) addLog:(NSString*)log;
-(void) addDemoLog:(NSString*)log;
-(void) open;
-(void) close;
-(void) clear;
-(NSInteger) count;
-(void) reloadData:(BOOL)reloadHd;

@end
