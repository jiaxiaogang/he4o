//
//  HEView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/8/6.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "HEView.h"

@implementation HEView

-(id) init {
    //现在新版UIView的super.init也会调用initWithFrame:zero，所以干脆改成调用它算了，直白些。
    self = [self initWithFrame:CGRectZero];
    return self;
}

/**
 *  MARK:--------------------用于xib文件中的HEView能被视觉看到--------------------
 *  @desc 比如要让智能体看到Road道路,只要在xib中将其改成HEView类型即可;
 */
-(id) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self != nil) {
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{}

-(void) initData {
    self.tag = visibleTag;
    self.initTime = [[NSDate date] timeIntervalSince1970];
}

-(void) initDisplay{}

@end
