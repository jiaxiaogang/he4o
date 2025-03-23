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
 *  MARK:--------------------commitInput--------------------
 */
+ (void) commitInput:(UIImage*)image;

#pragma mark - Test Methods

// 创建测试用的100x100像素图片
+ (UIImage *) createTest4ColorImage;
// 从ProtoMnistImage取图
+ (UIImage *) createImageFromProtoMnistImageWithIndex:(NSInteger)imgIndex;
+ (UIImage *) createImageFromProtoMnistImageWithName:(NSString*)imgName;

@end
