//
//  TextModel.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextModel : NSObject
//*      (DIC | Key:word Value:str | Key:itemId Value:NSInteger | Key:doId Value:NSInteger | Key:objId Value:NSInteger )注:itemId为主键;

@property (strong,nonatomic) NSString *text;
@property (assign,nonatomic) NSInteger itemId;
@property (assign, nonatomic) NSInteger doId;
@property (assign, nonatomic) NSInteger objId;
@property (assign, nonatomic) NSInteger referenceCount; //引用数

@end
