//
//  LanguageStoreLogModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------文字交流(回复记录)模型--------------------
 */
@interface LanguageStoreLogModel : NSObject

@property (strong,nonatomic) NSString *text;
@property (assign, nonatomic) int sadHappyValue;    //反馈值(一般为-1,0,1)

@end
