//
//  ImgTrainerItemModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/25.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgTrainerItemModel : NSObject

+(ImgTrainerItemModel*) new:(NSString*)folderPath imgId:(NSString*)imgId imgName:(NSString*)imgName;

@property (strong, nonatomic) NSString *folderPath; //图片所在文件夹绝对地址
@property (strong, nonatomic) NSString *imgId;      //图片名称的前辍（imageNet是一段编码，custom是图片物品名称）
@property (strong, nonatomic) NSString *imgName;    //图片物品真名
@property (assign, nonatomic) NSInteger imgIndex;   //这张图训练的进度

@end
