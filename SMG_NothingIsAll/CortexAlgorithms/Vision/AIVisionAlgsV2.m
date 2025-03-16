//
//  AIVisionAlgsV2.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIVisionAlgsV2.h"

@implementation AIVisionAlgsV2

+ (NSDictionary*)getHSBValuesFromImage:(UIImage *)image {
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
            
            // 8. 转换RGB到HSB
            CGFloat hue, saturation, brightness;
            [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
            
            //TODOTOMORROW20250316: 此处要把每个点，转成InputDotModel，或者分析下，用while来实现，dotNum/3向特征处理一次，再/3再一次，再/3再一次，直到达到拆完的最后。
            
            
            // 9. 保存结果，将坐标系原点移到中心
            NSInteger centerX = x - (width / 2);
            NSInteger centerY = y - (height / 2);
            NSString *key = [NSString stringWithFormat:@"%ld_%ld", (long)centerX, (long)centerY];
            result[key] = @{
                @"h": @(hue),
                @"s": @(saturation), 
                @"b": @(brightness)
            };
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

#pragma mark - Test Methods

+ (void)testVisionAlgs {
    // 1. 创建测试图片
    UIImage *testImage = [self createTestImage];
    
    // 2. 测试getHSBValuesInNineGrids方法
//    AIVisionAlgsModelV2 *result = [self getHSBGridsFromImage:testImage];
//    NSLog(@"hColors count: %lu", (unsigned long)result.hColors.count);
//    NSLog(@"sColors count: %lu", (unsigned long)result.sColors.count);
//    NSLog(@"bColors count: %lu", (unsigned long)result.bColors.count);
}

// 创建测试用的100x100像素图片
+ (UIImage *)createTestImage {
    CGSize size = CGSizeMake(100, 100);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 左上角像素 - 红色
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(0, 0, 50, 50));
    
    // 右上角像素 - 绿色
    CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(50, 0, 50, 50));

    // 左下角像素 - 蓝色
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextFillRect(context, CGRectMake(0, 50, 50, 50));

    // 右下角像素 - 黄色
    CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(50, 50, 50, 50));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
