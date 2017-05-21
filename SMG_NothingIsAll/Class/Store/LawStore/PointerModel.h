//
//  PointerModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------"数据指针"--------------------
 *  可以指向任何表的任一项;
 */
@interface PointerModel : NSObject

+(PointerModel*) initWithClass:(Class)c withId:(NSInteger)i ;

@property (strong,nonatomic) NSString *pointerClass;    //指针类型
@property (assign, nonatomic) NSInteger pointerId;  //指针地址(Id)

@end
