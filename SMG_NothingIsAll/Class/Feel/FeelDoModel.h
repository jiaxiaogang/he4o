//
//  UnderstandModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------行为输入item模型--------------------
 *  1,行为
 *  2,属性
 *  3,逻辑
 *      3.1,行为中包含逻辑
 *      3.2,行为间总结逻辑
 *  4,目前没有双目系统,所以这里使用"行为模型",以后有了双目后,这里费弃;
 */
@interface FeelDoModel : NSObject<NSCoding>

@property (strong,nonatomic) NSString *fromMKId;
@property (strong,nonatomic) NSString *doType;
@property (strong,nonatomic) NSString *toMKId;
@property (strong,nonatomic) NSString *value;   //值(颜色为FFFFFF 高度为xxcm)


@end
