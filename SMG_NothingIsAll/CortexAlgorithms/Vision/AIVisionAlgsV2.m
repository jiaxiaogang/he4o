//
//  AIVisionAlgsV2.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIVisionAlgsV2.h"

@implementation AIVisionAlgsV2

+ (NSDictionary*)getRGBValuesFromImage:(UIImage *)image {
    // 1. 创建返回字典
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    // 2. 获取图片的CGImage
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    //3. 求出共分多少点，以及每点的尺寸。
    NSInteger dotNum = [self convert2DotNum:MAX(width, height)];
    CGFloat dotW = width / dotNum;
    CGFloat dotH = height / dotNum;
    
    // 3. 创建颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 4. 创建原始数据
    unsigned char *rawData = (unsigned char *)calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    // 5. 创建上下文
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                               bitsPerComponent, bytesPerRow, colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 6. 绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // 7. 遍历像素
    for(NSUInteger y = 0; y < dotNum; y++) {
        NSInteger pixelY = [self convertDot2PixelIndex:y dotSize:dotH];//求出像素Y值
        for(NSUInteger x = 0; x < dotNum; x++) {
            NSInteger pixelX = [self convertDot2PixelIndex:x dotSize:dotW];//求出像素X值
            
            //8. 取出像素pixelX,pixelY的RGB值。
            NSUInteger byteIndex = (bytesPerRow * pixelY) + pixelX * bytesPerPixel;
            CGFloat red   = (CGFloat)rawData[byteIndex] / 255.0f;
            CGFloat green = (CGFloat)rawData[byteIndex + 1] / 255.0f;
            CGFloat blue  = (CGFloat)rawData[byteIndex + 2] / 255.0f;
            
            //9. 保存结果
            NSString *key = [NSString stringWithFormat:@"%ld_%ld", x, y];
            result[key] = @{@"r": @(red),@"g": @(green),@"b": @(blue)};
        }
    }
    
    // 10. 清理内存
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    
    return result;
}

/**
 *  MARK:--------------------获取当前图片能拆分成多少个点（比如100像素的图，按/3分隔，最后拆分成81点，每点=1.23457像素)--------------------
 */
+(NSInteger) convert2DotNum:(CGFloat)imageWHNum {
    NSInteger dotNum = 1;
    while (imageWHNum / dotNum > 1.5f) {
        dotNum *= 3;
    }
    return dotNum;
}

/**
 *  MARK:--------------------把点下标转成像素下标--------------------
 */
+(NSInteger) convertDot2PixelIndex:(NSInteger)dotIndex dotSize:(CGFloat)dotSize {
    CGFloat pixelStart = dotIndex * dotSize;
    CGFloat pixelEnd = pixelStart + dotSize;
    if (dotSize > 1) {//中间有空像素时，直接取中间像素。
        return (NSInteger)pixelStart + 1;
    } else if (fmodf(pixelStart, 1) > fmodf(pixelEnd, 1)) {//如果start向下到整数更远，则start向上到整数更近，则返回pixelEnd（因为它占更大像素空间）。
        return (NSInteger)pixelEnd;
    } else {
        return (NSInteger)pixelStart;//否则相反。
    }
}

/**
 *  MARK:--------------------把HSB字典，转成粒度字典（粒度字典是每层级横纵各三格，最粗粒度共9格，细粒度下再拆分嵌套各9格，以此类推）--------------------
 */
+(NSDictionary*) convertProtoColorDic2SplitDic:(NSDictionary*)protoColorDic {
    //1. 先搞最细粒度，然后一级级向粗粒度层做，其中：KEY=level_row_column value=色值。
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    int protoDotSize = sqrtf(protoColorDic.count);//通过总点数求平方根获取边长（因为横纵点数是一致的）。
    
    //2. 计算81是3的几次方 (log3(81) = 4) (level的取值范围是1234...从1开始，其中1表示最粗粒度层）。
    double levelNum = log(protoDotSize) / log(3);
    for (NSInteger curLevel = levelNum; curLevel > 0; curLevel--) {
        
        //3. 每个粒度层都要把每格处理下：第1粒度宽3。第2粒度宽9。第3粒度宽27。第4粒度宽81。（row和column的取值范围是0123...从0开始，它表示每一个粒度层的行列下标）。
        int curLevelSize = powf(3, curLevel);
        for (NSInteger curRow = 0; curRow < curLevelSize; curRow++) {
            for (NSInteger curColumn = 0; curColumn < curLevelSize; curColumn++) {
                
                //4. 每一格平均色处理（最细粒度从原始数据取，别的粗粒度层都从细一级9格累求其平均算）。
                NSString *curKey = [NSString stringWithFormat:@"%ld_%ld_%ld", curLevel, curRow, curColumn];
                if (curLevel == levelNum) {
                    //4.1 当前为最细粒度时，直接从hsbDic取值。
                    [result setObject:[protoColorDic objectForKey:STRFORMAT(@"%ld_%ld",curRow,curColumn)] forKey:curKey];
                } else {
                    //4.2 别的粗粒度，都从result的细一级粒度取值（把lastLevel取到的9个值取平均值=做为当前Level的HSB值）。
                    NSDictionary *subDotDics = [self getSubDotDics:curLevel curRow:curRow curColumn:curColumn nextLevelSplitDic:result];//取出子层9格色值。
                    [result setObject:[self getAverageColorFromSubDotDics:subDotDics] forKey:curKey];//取平均值并存到result。
                }
            }
        }
    }
    return result;
}

/**
 *  MARK:--------------------从更细粒度一层（下一层）取当前层curRow,curColumn的平均色值--------------------
 *  @nextLevelSplitDic 要求下一层的splitDic已经初始化，存在这个字典里（这样才能取到值）。
 */
+(NSDictionary*) getSubDotDics:(NSInteger)curLevel curRow:(NSInteger)curRow curColumn:(NSInteger)curColumn nextLevelSplitDic:(NSDictionary*)nextLevelSplitDic {
    //1. 别的粗粒度，都从result的细一级粒度取值（把lastLevel取到的9个值取平均值=做为当前Level的HSB值）。
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 找到下层，的9个row,column格。
    NSInteger nextLevel = curLevel + 1;
    for (NSInteger i = 0; i < 3; i++) {
        NSInteger nextRow = curRow * 3 + i;
        for (NSInteger j = 0; j < 3; j++) {
            NSInteger nextColumn = curColumn * 3 + j;
            
            //3. 把这九个格的色值分别取出来，求平均值收集。
            NSString *nextKey = STRFORMAT(@"%ld_%ld_%ld",nextLevel,nextRow,nextColumn);
            NSDictionary *nextItemColorDic = [nextLevelSplitDic objectForKey:nextKey];
            [result setObject:nextItemColorDic forKey:nextKey];
        }
    }
    return result;
}

/**
 *  MARK:--------------------根据子粒度层的9格色值，计算出平均色值--------------------
 */
+(NSDictionary*) getAverageColorFromSubDotDics:(NSDictionary*)subDotDics {
    //1. 别的粗粒度，都从result的细一级粒度取值（把lastLevel取到的9个值取平均值=做为当前Level的HSB值）。
    CGFloat sumR = 0,sumG = 0,sumB = 0;
    for (NSString *subDotKey in subDotDics) {
        NSDictionary *subDotDic = [subDotDics objectForKey:subDotKey];
        
        //3. 把这九个格的色值分别取出来，求平均值收集。
        sumR += NUMTOOK([subDotDic objectForKey:@"r"]).floatValue;
        sumG += NUMTOOK([subDotDic objectForKey:@"g"]).floatValue;
        sumB += NUMTOOK([subDotDic objectForKey:@"b"]).floatValue;
    }
    return @{@"r": @(sumR / 9),@"g": @(sumG / 9),@"b": @(sumB / 9)};
}

#pragma mark - Test Methods

+ (void)testVisionAlgs {
    // 1. 创建测试图片
    UIImage *testImage = [self createTestImage];
    NSDictionary *protoColorDic = [self getRGBValuesFromImage:testImage];
    NSDictionary *splitDic = [self convertProtoColorDic2SplitDic:protoColorDic];
    
    for (NSString *key in splitDic) {
        NSString *begin = [key substringToIndex:2];
        NSDictionary *value = [splitDic objectForKey:key];
        if ([begin isEqualToString:@"1_"]) {
            NSLog(@"第1层位置：%@ 颜色：%@",[key substringFromIndex:2],CLEANSTR(value));
        }
    }
    /*
     第1层位置：0_0 颜色：{r = 1;g = 0;b = 0;}
     第1层位置：0_1 颜色：{r = 0.3703704;g = 0;b = 0.6296296;}
     第1层位置：0_2 颜色：{r = 0;g = 0;b = 0.5185185;}
     第1层位置：1_0 颜色：{r = 0.3703704;g = 0.6296296;b = 0;}
     第1层位置：1_1 颜色：{r = 1;g = 0.6296296;b = 0;}
     第1层位置：1_2 颜色：{r = 0.1481482;g = 0.1481482;b = 0.3703704;}
     第1层位置：2_0 颜色：{r = 0;g = 0.5185185;b = 0;}
     第1层位置：2_1 颜色：{r = 0.1481482;g = 0.5185185;b = 0;}
     第1层位置：2_2 颜色：{r = 0.5185185;g = 0.5185185;b = 0;}
     这个颜色不对，比如0_1应该是R和B各0.5才对。。。
     //TODOTOMORROW20250316: 得把3和4层的，边缘中间位置的点打出来看下。第1层时，已经离最细层太远了，调试不直观。。。
     */
    NSLog(@"");
    
    // 2. 测试getHSBValuesInNineGrids方法
//    AIVisionAlgsModelV2 *result = [self getHSBGridsFromImage:testImage];
//    NSLog(@"hColors count: %lu", (unsigned long)result.hColors.count);
//    NSLog(@"sColors count: %lu", (unsigned long)result.sColors.count);
//    NSLog(@"bColors count: %lu", (unsigned long)result.bColors.count);
}

// 创建测试用的100x100像素图片
+ (UIImage *)createTestImage {
    CGFloat size = 100;
    CGFloat half = size / 2;
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 左上角像素 - 红色
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(0, 0, half, half));
    
    // 右上角像素 - 绿色
    CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(half, 0, half, half));

    // 左下角像素 - 蓝色
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextFillRect(context, CGRectMake(0, half, half, half));

    // 右下角像素 - 黄色
    CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(half, half, half, half));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
