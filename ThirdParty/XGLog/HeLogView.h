//
//  HeLogView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/3/12.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeLogView : UIView

-(void) addLog:(NSString*)log;
-(void) reloadData;
-(void) open;
-(void) close;

@end
