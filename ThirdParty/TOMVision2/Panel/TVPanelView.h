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

-(void) panelPlay:(NSInteger)changeIndex;
-(void) panelCloseBtnClicked;
-(void) panelScaleChanged:(CGFloat)scale;

@end

@class TOMVisionItemModel;
@interface TVPanelView : UIView

@property (strong, nonatomic) NSMutableArray *models;   //所有帧数据 List<TOMVisionItemModel>
@property (weak, nonatomic) id<TVPanelViewDelegate> delegate;//notnull

-(void) updateFrame:(BOOL)newLoop;
-(void) getModel:(NSInteger)changeIndex complete:(void(^)(TOMVisionItemModel*,TOModelBase*))complete;

@end
