//
//  LongTipWindow.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/8/12.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LongTipWindow : UIView

-(void) setData:(NSString*)moduleTitle data:(AIKVPointer*)data direction:(DirectionType)type;

@end
