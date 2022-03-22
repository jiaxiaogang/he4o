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
-(void) panelCloseBtnClicked;
-(void) panelScaleChanged:(CGFloat)scale;

@end

@interface TVPanelView : UIView

@property (strong, nonatomic) NSMutableArray *models;   //所有帧数据 List<TOMVisionItemModel>
@property (weak, nonatomic) id<TVPanelViewDelegate> delegate;//notnull

-(void) updateFrame:(BOOL)newLoop;


//TODOTOMORROW20220322:
//1. 此处models因为内存地址一样,导致更新后,旧有model的样子未保留;
//2. 此处要求,即要帧帧更新,双要保证内存地址可判断是否同一个;
//3. 所以加上序列化方法,序列化时,将内存地址也记录下来;

//4. 看能不能自定义序列化,一个字典搞定,每个key都是内存地址;
//5. 每个value都是它的content_p,status,cutIndex,subs等;
//6. 每个sub又是个dic数组,key又为内存地址;

//7. 或者直接用nscoding序列化,只需要序列化roots就行,下面的sub自动跟到里面了;
//8. nscoding时,把内存地址计入其中,反序列化后,equal时,就对比它;





@end
