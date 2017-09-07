//
//  AISqlPointer.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIPointer.h"

@interface AISqlPointer : AIPointer

+(AISqlPointer*) initWithClass:(Class)pC withId:(NSInteger)pI ;
-(id) initWithPId:(NSInteger)pId;

@property (strong,nonatomic) NSString *pClass;    //指针类型
@property (assign, nonatomic) NSInteger pId;  //指针地址(Id)

@end
