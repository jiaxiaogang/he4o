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

-(void) setData:(AIFeatureNode*)tNode contentIndexes:(NSArray*)contentIndexes logDesc:(NSString*)logDesc {
    //1. 把已显示的去掉。
    [self removeLightDic];
    
    //2. 三个单码索引序列。
    NSDictionary *directionDataDic = [AINetIndexUtils searchDataDic:tNode.p.algsType ds:STRFORMAT(@"%@_direction",tNode.p.dataSource) isOut:false];
    NSDictionary *diffDataDic = [AINetIndexUtils searchDataDic:tNode.p.algsType ds:STRFORMAT(@"%@_diff",tNode.p.dataSource) isOut:false];
    NSDictionary *junDataDic = [AINetIndexUtils searchDataDic:tNode.p.algsType ds:STRFORMAT(@"%@_jun",tNode.p.dataSource) isOut:false];
    
    //3. 按level从粗到细排序（因为细粒度优先级更高：粗粒度先显示，细粒度再复写它）（参考34176-TODO2.1）。
    contentIndexes = [SMGUtils sortSmall2Big:contentIndexes compareBlock:^double(NSNumber *contentIndex) {
        NSValue *rect = ARR_INDEX(tNode.rects,contentIndex.integerValue);
        return rect.CGRectValue.size.width;
    }];
    
    //11. 每个rect分别可视化。
    for (NSNumber *contentIndex in contentIndexes) {
        AIKVPointer *gv_p = ARR_INDEX(tNode.content_ps, contentIndex.integerValue);
        NSValue *rect = ARR_INDEX(tNode.rects, contentIndex.integerValue);
        
        //12. 三个索引的指针地址：均值、差值、方向。
        AIGroupValueNode *gvNode = [SMGUtils searchNode:gv_p];
        AIKVPointer *directionV_p = ARR_INDEX(gvNode.content_ps, 0);
        AIKVPointer *diffV_p = ARR_INDEX(gvNode.content_ps, 1);
        AIKVPointer *junV_p = ARR_INDEX(gvNode.content_ps, 2);
        double directionData = [NUMTOOK([AINetIndex getData:directionV_p fromDataDic:directionDataDic]) doubleValue];
        double diffData = [NUMTOOK([AINetIndex getData:diffV_p fromDataDic:diffDataDic]) doubleValue];
        double junData = [NUMTOOK([AINetIndex getData:junV_p fromDataDic:junDataDic]) doubleValue];
        
        //13. 用这三个索引值，生成当前特征通道的九宫每像素色值。
        [self createItemLight:rect.CGRectValue directionData:directionData diffData:diffData junData:junData];
    }
    
    //21. lab
    [self.lab setText:logDesc];
}

-(void) createItemLight:(CGRect)rect directionData:(double)directionData diffData:(double)diffData junData:(double)junData {
    //1. 先上下各阔一半值，然后各分布一半格子。
    //A、如果不越界，直接输出结果（如差值为4，均值为7，则Max=9，Min=5 各4.5格）。
    //B、如果上越界，下移，重新计算二元方程（如差值为8，均值为7，因7+4>9取Max=9，Min=1：然后Max*A+Min*B=63 A+B=9 得出：A=6.75格 B=2.25格）。
    //C、如果下越界，上移，重新计算二元方程（如差值为8，均值为3，因3-4<0取Min=0，Max=8：然后Max*A+Min*B=63 A+B=9 得出：A=3.375格 B=5.625格）。
    double max = junData + diffData * 0.5f;
    double min = junData - diffData * 0.5f;
    if (max > 9) {
        min -= max - 9;
        max = 9;
    } else if (min < 0) {
        max += 0 - min;
        min = 0;
    }
    double sumData = junData * 9;

    //2. 设min有A格，max有B格，解二元一次方程组:
    // min * A + max * B = sumData
    // A + B = 9格
    // 解得: B = 9 - A
    // 代入: min * A + max * (9 - A) = sumData
    //      min * A + 9 * max - max * A = sumData
    //      (min - max) * A = sumData - 9 * max
    //      A = (sumData - 9 * max) / (min - max)
    double minNumA = (sumData - 9 * max) / (min - max);
    double maxNumB = 9 - minNumA;
    
    //3. 九宫按方向分界线：求出每一个宫格的中心点在哪一边。
    //D、根据分界线两边占比 & 和两边的色值 = 计算平均值。
    
    //TODOTOMORROW20250427: 用三索引值和rect，生成每宫的色值。
    
    
    // 已知方向directionData（角度，单位度），A点(ax, ay)，B点(bx, by)
    // 计算B点在A点的哪一侧（方向线的左侧还是右侧）
    // 1. 先将directionData转为弧度
    double rad = directionData * M_PI / 180.0;
    // 2. 方向向量
    double dx = cos(rad);
    double dy = sin(rad);
    // 3. AB向量
    // 假设A点(ax, ay)，B点(bx, by)
    // 这里以rect中心为A点，B点为九宫格内的某点
    double ax = rect.origin.x + rect.size.width / 2.0;
    double ay = rect.origin.y + rect.size.height / 2.0;
    // 例如，B点为(bx, by)
    for (NSInteger row = 0; row < 3; row++) {
        for (NSInteger column = 0; column < 3; column++) {
            CGFloat dotW = rect.size.width / 3.0f;
            CGFloat dotH = rect.size.height / 3.0f;
            CGFloat centerX = row * dotW + dotW * 0.5f;
            CGFloat centerY = row * dotH + dotH * 0.5f;
            
            double bx = centerX;
            double by = centerY;
            // 4. 计算向量AB
            double abx = bx - ax;
            double aby = by - ay;
            // 5. 叉乘判断
            double cross = dx * aby - dy * abx;
            if (cross > 0) {
                NSLog(@"B点在方向线左侧");
            } else if (cross < 0) {
                NSLog(@"B点在方向线右侧");
            } else {
                NSLog(@"B点在方向线上");
            }
        }
    }
   
    
    
    
    //1. 全屏显示的就不显示了，起不到高亮的意义（但很多子级是压缩掉的，所以父级必须要）。
    if (rect.size.width == 27 && rect.size.height == 27) return;
    
    //2025.04.27: BUG-可能色值信息不符的情况（当父级六格白，三格黑，子级如果认为纯白纯黑都不存，那么就都都会继承灰色）。
    //TODO: 色值推断：子级由父级三索引计算得来，而不根据父级平均值来显示（这样的话，此处就不用改，只需要改显示时实时计算出来即可）。
    //TODOTOMORROW20250427: 即此处要把GV解析出来显示，不能9格合一只显示一个色块了（颜色也不能再只显示单调的几色了）。
    //1、从父级GV开始推断9宫色值。
    //2、再子级GV推断色值，如果子级有新色值，则覆盖掉父级的。
    
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
