//
//  MemModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ObjModel,DoModel,CharModel;
@interface MemModel : NSObject

@property (assign, nonatomic) NSInteger groupId;//当前分组id;

@property (assign, nonatomic) NSInteger charRowId;
@property (assign, nonatomic) NSInteger  objRowId;
@property (assign, nonatomic) NSInteger  doRowId;
//@property (assign, nonatomic) NSInteger groupModel;//记忆间的互相引用;如:(A看到B在看着A)

@end
