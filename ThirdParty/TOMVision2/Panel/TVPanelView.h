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
@class TOMVisionItemModel;
@protocol TVPanelViewDelegate <NSObject>

-(void) panelPlay:(TOMVisionItemModel*)model;

@end

@interface TVPanelView : UIView

@property (strong, nonatomic) NSMutableArray *models;   //所有帧数据 List<TOMVisionItemModel>
@property (weak, nonatomic) id<TVPanelViewDelegate> delegate;//notnull

-(void) updateFrame:(BOOL)newLoop;

@end
