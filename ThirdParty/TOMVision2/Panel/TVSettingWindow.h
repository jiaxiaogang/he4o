//
//  TVSettingWindow.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/10/12.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MARK:--------------------思维可视化设置面板--------------------
 *  @version
 *      2022.10.12: 初版,支持4种root的可视化开关,避免一堆没必要的显示;
 */
@interface TVSettingWindow : UIView

@property (assign, nonatomic) BOOL finishSwitch;
@property (assign, nonatomic) BOOL expiredSwitch;
@property (assign, nonatomic) BOOL actYesSwitch;
@property (assign, nonatomic) BOOL withOutSwitch;

-(void) open;
-(void) close;

@end
