//
//  MemManagerWindow.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/6.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TVideoWindowDelegate <NSObject>

-(void) tvideo_ClearModels;
-(void) tvideo_Save:(NSString*)fileName;
-(void) tvideo_Read:(NSString*)fileName;

@end

@interface TVideoWindow : UIView

@property (weak, nonatomic) id<TVideoWindowDelegate> delegate;
-(void) open;
-(void) close;

@end
