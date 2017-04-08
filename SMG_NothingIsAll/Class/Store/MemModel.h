//
//  MemModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemModel : NSObject

@property (strong,nonatomic) NSString *allText;
@property (strong,nonatomic) NSArray *wordArr;  //分词组
@property (strong,nonatomic) NSArray *doArr;    //行为组

@end
