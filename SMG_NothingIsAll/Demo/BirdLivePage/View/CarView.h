//
//  CarView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CarViewDelegate <NSObject>

-(BOOL) carView_CanRun;
-(NSArray*) carView_GetFoodInLoad;  //获取在路上的坚果;

@end

@interface CarView : UIView

@property (weak,nonatomic) id<CarViewDelegate> delegate;
-(void) run;

@end
