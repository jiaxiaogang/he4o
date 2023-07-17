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

//TODOTOMORROW20230717: 怀疑此处需要线程安全 (也不一定,也许这里全是主线程,没此问题,可以加个开关试下先);


@property (strong, nonatomic) NSMutableArray *models;   //所有帧数据 List<TOMVisionItemModel>
@property (weak, nonatomic) id<TVPanelViewDelegate> delegate;//notnull
@property (assign, nonatomic) BOOL stop;                //功能开关
@property (strong, nonatomic) TVSettingWindow *settingWindow;

-(void) updateFrame;
-(void) getModel:(NSInteger)changeIndex complete:(void(^)(TOMVisionItemModel*,TOModelBase*))complete;
-(CGFloat) getFrameShowTime;

@end
