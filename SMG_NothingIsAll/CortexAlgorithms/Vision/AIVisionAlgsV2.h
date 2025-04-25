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
+ (void) commitInput:(UIImage*)image logDesc:(NSString*)logDesc;

#pragma mark - Test Methods

+ (UIImage *) createTest4ColorImage;
+ (UIImage *) createImageFromMnistImageWithName:(NSString*)imgName forTest:(BOOL)forTest;
+ (UIImage *) createImageFromCustomImageWithName:(NSString*)imgName;

@end
