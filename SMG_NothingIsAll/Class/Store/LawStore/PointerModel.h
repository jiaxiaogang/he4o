//
//  PointerModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/20.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------一个指针,可以指向任何表的一项;--------------------
 */
@interface PointerModel : NSObject

@property (assign,nonatomic) Class pointerClass;    //指针类型
@property (assign, nonatomic) NSInteger pointerId;  //指针地址(Id)

@end
