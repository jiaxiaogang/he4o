//
//  ImgTrainerPreview.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/27.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "ImgTrainerPreview.h"
#import "HSBColor.h"

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
    [self.lab setFont:[UIFont boldSystemFontOfSize:10]];
    [self.lab setBackgroundColor:UIColor.blueColor];
    [self.lab setTextColor:UIColor.whiteColor];
    [self.lab setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.lab];
}

-(void) initData {
    self.lightDic = [NSMutableDictionary new];
    self.hsbDic = [NSMutableDictionary new];
}

-(void) initDisplay {
    
}

-(void) setData:(AIFeatureNode*)tNode contentIndexes:(NSArray*)contentIndexes lab:(NSString*)lab {
    
    //2. 三个单码索引序列。
    NSDictionary *directionDataDic = [AINetIndexUtils searchDataDic:tNode.p.algsType ds:STRFORMAT(@"%@_direction",tNode.p.dataSource) isOut:false];
    NSDictionary *diffDataDic = [AINetIndexUtils searchDataDic:tNode.p.algsType ds:STRFORMAT(@"%@_diff",tNode.p.dataSource) isOut:false];
    NSDictionary *junDataDic = [AINetIndexUtils searchDataDic:tNode.p.algsType ds:STRFORMAT(@"%@_jun",tNode.p.dataSource) isOut:false];
    
    //3. 按level从粗到细排序（因为细粒度优先级更高：粗粒度先显示，细粒度再复写它）（参考34176-TODO2.1）。
    contentIndexes = [SMGUtils sortBig2Small:contentIndexes compareBlock:^double(NSNumber *contentIndex) {
        NSValue *rect = ARR_INDEX(tNode.rects,contentIndex.integerValue);
        return rect.CGRectValue.size.width;
    }];
    
    //11. 每个rect分别可视化。
    for (NSNumber *contentIndex in contentIndexes) {
        AIKVPointer *gv_p = ARR_INDEX(tNode.content_ps, contentIndex.integerValue);
        NSValue *rect = ARR_INDEX(tNode.rects, contentIndex.integerValue);
        
        //12. 三个索引的指针地址：均值、差值、方向。
        AIGroupValueNode *gvNode = [SMGUtils searchNode:gv_p];
        AIKVPointer *directionV_p = [SMGUtils filterSingleFromArr:gvNode.content_ps checkValid:^BOOL(AIKVPointer *item) {
            return [item.dataSource isEqualToString:STRFORMAT(@"%@_direction",tNode.p.dataSource)];
        }];
        AIKVPointer *diffV_p = [SMGUtils filterSingleFromArr:gvNode.content_ps checkValid:^BOOL(AIKVPointer *item) {
            return [item.dataSource isEqualToString:STRFORMAT(@"%@_diff",tNode.p.dataSource)];
        }];
        AIKVPointer *junV_p = [SMGUtils filterSingleFromArr:gvNode.content_ps checkValid:^BOOL(AIKVPointer *item) {
            return [item.dataSource isEqualToString:STRFORMAT(@"%@_jun",tNode.p.dataSource)];
        }];
        double directionData = [NUMTOOK([AINetIndex getData:directionV_p fromDataDic:directionDataDic]) doubleValue];
        double diffData = [NUMTOOK([AINetIndex getData:diffV_p fromDataDic:diffDataDic]) doubleValue];
        double junData = [NUMTOOK([AINetIndex getData:junV_p fromDataDic:junDataDic]) doubleValue];
        
        //13. 用这三个索引值，生成当前特征通道的九宫每像素色值。
        [self createItemLight:rect.CGRectValue directionData:directionData diffData:diffData junData:junData ds:tNode.p.dataSource];
    }
    
    //21. lab
    [self.lab setText:lab];
}

-(void) createItemLight:(CGRect)rect directionData:(double)directionData diffData:(double)diffData junData:(double)junData ds:(NSString*)ds {
    //0. 数据检查（无差别时，直接全显示均值）。
    if (diffData == 0) {
        for (NSInteger i = 0; i < rect.size.width; i++) {
            for (NSInteger j = 0; j < rect.size.height; j++) {
                [self createItemLight:i y:j ds:ds hsbValue:junData];
            }
        }
        return;
    }
    
    //1. ========== 先上下各阔一半值，然后各分布一半格子 ==========
    //A、如果不越界，直接输出结果（如差值为4，均值为7，则Max=9，Min=5 各4.5格）。
    //B、如果上越界，下移，重新计算二元方程（如差值为8，均值为7，因7+4>9取Max=9，Min=1：然后Max*A+Min*B=63 A+B=9 得出：A=6.75格 B=2.25格）。
    //C、如果下越界，上移，重新计算二元方程（如差值为8，均值为3，因3-4<0取Min=0，Max=8：然后Max*A+Min*B=63 A+B=9 得出：A=3.375格 B=5.625格）。
    double max = junData + diffData * 0.5f;
    double min = junData - diffData * 0.5f;
    if (max > 1) {
        min -= max - 1;
        max = 1;
    } else if (min < 0) {
        max += 0 - min;
        min = 0;
    }
    double sumData = junData * 9;

    //2. ==========设min有A格，max有B格，解二元一次方程组 ==========
    // min * A + max * B = sumData
    // A + B = 9格
    // 解得: B = 9 - A
    // 代入: min * A + max * (9 - A) = sumData
    //      min * A + 9 * max - max * A = sumData
    //      (min - max) * A = sumData - 9 * max
    //      A = (sumData - 9 * max) / (min - max)
    double minNumA = (sumData - 9 * max) / (min - max);
    double maxNumB = 9 - minNumA;
    
    //3. ========== 根据方向索引 和 线经过A点 => 计算分界线 ==========
    double rad = (directionData * 2 - 1) * M_PI;//将距离转成角度-PI -> PI (从左逆时针一圈为-3.14到3.14)。
    rad += M_PI_2;//分界线为逆时针转90度（分界线的右侧为明，左侧为暗）。
    if (rad > M_PI) rad -= M_PI * 2;//循环值处理（避免越界）。
    double dx = cos(rad);//方向向量
    double dy = sin(rad);//方向向量
    
    //4. ========== 按分界线方向 及 Max区Min区大小比例 => 把分界线画到九宫格上 ==========
    double ax = rect.size.width * maxNumB / 9;//A点坐标为在方向上，找出Max和Min的比例，用分界线划出分区（根据minNumA和maxNumB来计算一个比例）。
    double ay = [self convertIosYToMathY:rect.size.height * maxNumB / 9 height:rect.size.height];
    
    //5. ========== 按方向分界线：判断九宫每格在左还是右 ==========
    for (NSInteger row = 0; row < 3; row++) {
        for (NSInteger column = 0; column < 3; column++) {
            CGFloat dotW = rect.size.width / 3.0f;
            CGFloat dotH = rect.size.height / 3.0f;
            CGFloat centerX = row * dotW + dotW * 0.5f;
            CGFloat centerY = column * dotH + dotH * 0.5f;
            double bx = centerX;//B点坐标为格子中心点
            double by = [self convertIosYToMathY:centerY height:rect.size.height];//B点坐标为格子中心点
            double abx = bx - ax;//计算向量AB
            double aby = by - ay;//计算向量AB
            //51. 叉乘判断（计算B点在A点的哪一侧（分界线的左侧还是右侧）
            double cross = dx * aby - dy * abx;
            CGFloat hsbValue = 0;
            if (cross > 0.01) {
                //52. B点在方向线左侧;
                hsbValue = min;
            } else if (cross < -0.01) {
                //53. B点在方向线右侧;
                hsbValue = max;
            } else {
                //54、B点在方向线上: 根据分界线两边占比 & 和两边的色值 = 计算平均值。
                hsbValue = (max + min) / 2;
            }
            
            //61. 对九宫每格中的每个像素分别高亮显示。
            for (NSInteger i = 0; i < dotW; i++) {
                for (NSInteger j = 0; j < dotH; j++) {
                    CGFloat x = rect.origin.x + row * dotW + i;
                    CGFloat y = rect.origin.y + column * dotH + j;
                    
                    //62. 每次收集一个通道，三次识别后可以把全部通道累计下来，还原最终显示颜色。
                    [self createItemLight:x y:y ds:ds hsbValue:hsbValue];
                }
            }
        }
    }
}

// x,y传绝对坐标。
-(void) createItemLight:(CGFloat)x y:(CGFloat)y ds:(NSString*)ds hsbValue:(CGFloat)hsbValue {
    //xy最大值为27，但每个都是组码，所以要转为9x9。
    CGFloat dotSize = powf(3, VisionMaxLevel);
    NSString *key = STRFORMAT(@"%.0f_%.0f",x,y);
    
    //收集HSB颜色
    HSBColor *color =  [self.hsbDic objectForKey:key];
    if (!color) {
        color = [HSBColor new];
        [self.hsbDic setObject:color forKey:key];
    }
    [color setData:ds value:hsbValue];
    
    //当前图片分为9格。
    CGFloat dotWH = self.width / dotSize;
    UIView *lightView = [self.lightDic objectForKey:key];
    if (!lightView) {
        lightView = [[UIView alloc] initWithFrame:CGRectMake(x * dotWH, y * dotWH, dotWH, dotWH)];
        [lightView setAlpha:1.0f];
        [self addSubview:lightView];
        [self.lightDic setObject:lightView forKey:key];
    }
    [lightView setBackgroundColor:color.getColor];
}

-(void) removeLightDic {
    //1. 去掉可视化lightDic。
    for (UIView *itemLight in self.lightDic.allValues) {
        [itemLight removeFromSuperview];
    }
    [self.lightDic removeAllObjects];
    [self.hsbDic removeAllObjects];
}

//方向的坐标是左下角为0，而ios坐标是左上角为0，要先转换下，再参与叉乘判断等。
//把ios的左上角为y=0 改成 数学方向判断里的左下角y=0。
-(CGFloat) convertIosYToMathY:(CGFloat)iosY height:(CGFloat)height {
    return height - iosY;//用总高减iosY即可。
}

@end
