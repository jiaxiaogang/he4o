//
//  TOMVisionNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/16.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOMVisionNodeBase : UIView

-(void) initView;
-(void) initData;
-(void) initDisplay;
-(void) refreshDisplay;

-(void) setData:(TOModelBase*)value;
-(TOModelBase *)data;
-(BOOL) isEqualByData:(TOModelBase*)checkData;

@end
