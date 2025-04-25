//
//  ImgTrainerItemModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/25.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgTrainerItemModel : NSObject

+(ImgTrainerItemModel*) new:(NSString*)imgId imgName:(NSString*)imgName;

@property (strong, nonatomic) NSString *imgId;
@property (strong, nonatomic) NSString *imgName;
@property (assign, nonatomic) NSInteger imgIndex;//这张图训练的进度

@end
