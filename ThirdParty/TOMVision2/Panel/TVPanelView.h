//
//  TVPanelView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/18.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MARK:--------------------播放控制面板--------------------
 */
@protocol TVPanelViewDelegate <NSObject>

-(void) panelSubBtnClicked;
-(void) panelPlusBtnClicked;

@end

@interface TVPanelView : UIView

@property (weak, nonatomic) id<TVPanelViewDelegate> delegate;//notnull

@end
