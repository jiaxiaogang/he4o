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
    for(NSUInteger y = 0; y < height; y++) {
        for(NSUInteger x = 0; x < width; x++) {
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            
            CGFloat red   = (CGFloat)rawData[byteIndex] / 255.0f;
            CGFloat green = (CGFloat)rawData[byteIndex + 1] / 255.0f;
            CGFloat blue  = (CGFloat)rawData[byteIndex + 2] / 255.0f;
            
            // 8. 转换RGB到HSB
            CGFloat hue, saturation, brightness;
            [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] getHue:&hue
                                                                  saturation:&saturation 
                                                                  brightness:&brightness 
                                                                     alpha:NULL];
            
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
+(CGFloat) convert2DotNum:(CGFloat)imageWHNum {
    CGFloat dotNum = 1;
    while (imageWHNum / dotNum > 3) {
        dotNum *= 3;
    }
    return dotNum;
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
    CGContextFillRect(context, CGRectMake(0, 0, 100, 100));
    
    // 右上角像素 - 绿色
    CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(1, 0, 100, 100));
    
    // 左下角像素 - 蓝色
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextFillRect(context, CGRectMake(0, 1, 100, 100));
    
    // 右下角像素 - 黄色
    CGContextSetRGBFillColor(context, 1.0, 1.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(1, 1, 100, 100));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
