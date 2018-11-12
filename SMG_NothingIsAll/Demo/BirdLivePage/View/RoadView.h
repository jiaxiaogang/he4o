//
//  RoadView.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RoadViewDelegate <NSObject>

-(NSArray*) roadView_GetFoodInLoad;

@end

@interface RoadView : UIView

@property (weak,nonatomic) id<RoadViewDelegate> delegate;

@end
