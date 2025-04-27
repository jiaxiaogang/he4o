//
//  ImgTrainerPreview.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/27.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "ImgTrainerPreview.h"

@implementation ImgTrainerPreview

-(id) init {
    self = [super init];
    if (self) {
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView {
    //self
    [self setFrame:CGRectMake(0, 0, 100, 115)];
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:UIColor.redColor.CGColor];

    //lab
    self.lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 15)];
    [self.lab setFont:[UIFont systemFontOfSize:6]];
    [self.lab setBackgroundColor:UIColor.grayColor];
    [self addSubview:self.lab];
}

-(void) initData {
    self.lightDic = [NSMutableDictionary new];
}

-(void) initDisplay {
    
}

-(void) setData:(NSArray*)rects logDesc:(NSString*)logDesc {
    //1. 把已显示的去掉。
    [self removeLightDic];
    
    //2. 每个rect分别可视化。
    for (NSValue *rect in rects) {
        [self createItemLight:rect.CGRectValue];
    }
    
    //3. lab
    [self.lab setText:logDesc];
}

-(void) createItemLight:(CGRect)rect {
    //1. 全屏显示的就不显示了，起不到高亮的意义。
    if (rect.size.width == 27 && rect.size.height == 27) return;
    
    //2. xy最大值为27，但每个都是组码，所以要转为9x9。
    rect = CGRectMake(rect.origin.x / 3, rect.origin.y / 3, rect.size.width / 3, rect.size.height / 3);
    
    //3. 高亮颜色。
    UIColor *color = UIColor.greenColor;
    if (rect.size.width == 1) {
        color = UIColor.redColor;
    } else if (rect.size.width == 3) {
        color = UIColor.yellowColor;
    } else if (rect.size.width == 9) {
        color = UIColor.blueColor;
    }
    
    //4. 每点高亮显示。
    for (NSInteger i = 0; i < rect.size.width; i++) {
        for (NSInteger j = 0; j < rect.size.height; j++) {
            CGFloat x = rect.origin.x + i;
            CGFloat y = rect.origin.y + j;
            [self createItemLight:x y:y color:color];
        }
    }
}

-(void) createItemLight:(CGFloat)x y:(CGFloat)y color:(UIColor*)color {
    //xy最大值为27，但每个都是组码，所以要转为9x9。
    CGFloat dotSize = powf(3, VisionMaxLevel - 1);
    
    //当前图片分为9格。
    CGFloat dotWH = self.width / dotSize;
    UIView *lightView = [self.lightDic objectForKey:STRFORMAT(@"%.0f_%.0f",x,y)];
    if (!lightView) {
        lightView = [[UIView alloc] initWithFrame:CGRectMake(x * dotWH, y * dotWH, dotWH, dotWH)];
        [lightView setBackgroundColor:color];
        [lightView setAlpha:0.4f];
        [self addSubview:lightView];
        [self.lightDic setObject:lightView forKey:STRFORMAT(@"%.0f_%.0f",x,y)];
    }
}

-(void) removeLightDic {
    //1. 去掉可视化lightDic。
    for (UIView *itemLight in self.lightDic.allValues) {
        [itemLight removeFromSuperview];
    }
    [self.lightDic removeAllObjects];
}

@end
