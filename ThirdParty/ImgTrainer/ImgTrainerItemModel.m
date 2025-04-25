//
//  ImgTrainerItemModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/25.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "ImgTrainerItemModel.h"

@implementation ImgTrainerItemModel

+(ImgTrainerItemModel*) new:(NSString*)imgId imgName:(NSString*)imgName {
    ImgTrainerItemModel *result = [ImgTrainerItemModel new];
    result.imgId = imgId;
    result.imgName = imgName;
    return result;
}

@end
