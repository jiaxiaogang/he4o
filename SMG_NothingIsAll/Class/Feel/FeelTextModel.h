//
//  FeelTextModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/10.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------Input_文字--------------------
 *
 */
@interface FeelTextModel : NSObject

@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) NSMutableDictionary *attributes;   //附加信息

@end
