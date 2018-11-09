//
//  LightView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LightViewDelegate <NSObject>

-(void) lightView_ChangeToGreen;

@end

@interface LightView : UIView

@property (weak,nonatomic) id<LightViewDelegate> delegate;
@property (assign,nonatomic) BOOL curLightIsGreen;

@end
