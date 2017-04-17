//
//  UnderstandModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------理解item模型--------------------
 */
@interface UnderstandModel : NSObject

@property (strong,nonatomic) NSString *fromMKId;
@property (strong,nonatomic) NSString *doType;
@property (strong,nonatomic) NSString *toMKId;
@property (strong,nonatomic) NSString *value;   //值(颜色为FFFFFF 高度为xxcm)


@end
