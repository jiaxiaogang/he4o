//
//  ImgTrainerView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/25.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgTrainerView : UIView

-(void) open;

/**
 *  MARK:--------------------setData--------------------
 *  @param mode 1custom模式 2imageNet模式 3Mnist模式（暂不需要，但也用过人家图库，挂个名）。
 */
-(void) setData:(int)mode;

@end
