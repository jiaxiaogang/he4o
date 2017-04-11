//
//  FeelImgModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/10.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FeelImgModel : NSObject

@property (strong,nonatomic) UIImage *img;                      //图片
@property (assign, nonatomic) CGRect frame;                     //坐标及大小
@property (strong,nonatomic) NSMutableDictionary *attributes;   //附加信息

@end




static NSString *FeelImgModelAttributesKey_Line     = @"line";  //抽象线的path
static NSString *FeelImgModelAttributesKey_Area     = @"area";  //抽象面的外形
