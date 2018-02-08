//
//  AIAlgsPointer.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/1/28.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

/**
 *  MARK:--------------------算法指针--------------------
 *  随后删掉(由AINode.dataSource标记AIInputModel.PropertyName替代,并且algs的pointer不应出现在存储层)
 */
@interface AIAlgsPointer : AIPointer

+(AIAlgsPointer*) initWithAlgsClass:(Class)algsClass algsName:(NSString*)algsName;
@property (strong,nonatomic) NSString *algsClass;   //算法所在类
@property (strong,nonatomic) NSString *algsName;    //算法名

@end
