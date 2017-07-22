//
//  AIPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------"数据指针"--------------------
 *  1,可以指向任何表的任一项;
 */
@interface AIPointer : NSObject 

+(AIPointer*) initWithClass:(Class)pC withId:(NSInteger)pI ;

@property (strong,nonatomic) NSString *pClass;    //指针类型
@property (assign, nonatomic) NSInteger pId;  //指针地址(Id)

/**
 *  MARK:-------------------取指向的数据--------------------
 */
-(id) content;

@end
