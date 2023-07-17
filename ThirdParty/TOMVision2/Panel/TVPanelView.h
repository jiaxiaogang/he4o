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

@class TOMVisionItemModel,TVSettingWindow;
@interface TVPanelView : UIView

@property (strong, nonatomic) NSMutableArray *models;   //所有帧数据 List<TOMVisionItemModel> (2023.07.17: 怀疑此处需要线程安全,等闪退时再来加)
@property (weak, nonatomic) id<TVPanelViewDelegate> delegate;//notnull
@property (assign, nonatomic) BOOL stop;                //功能开关
@property (strong, nonatomic) TVSettingWindow *settingWindow;

-(void) updateFrame;
-(void) getModel:(NSInteger)changeIndex complete:(void(^)(TOMVisionItemModel*,TOModelBase*))complete;
-(CGFloat) getFrameShowTime;

@end
