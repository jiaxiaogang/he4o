//
//  AIVisionAlgsV2.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/3/15.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AIVisionAlgsV2 : NSObject

/**
 获取图片中每个像素的HSB值
 @param image 输入图片
 @return 返回一个数组，包含每个像素的HSB值，格式为 @[@{@"h": @(h), @"s": @(s), @"b": @(b), @"x": @(x), @"y": @(y)}]
 */
+ (NSDictionary*)getHSBValuesFromImage:(UIImage *)image;
+ (void)testVisionAlgs;

+(CGFloat) convert2DotNum:(CGFloat)imageWHNum;
@end
