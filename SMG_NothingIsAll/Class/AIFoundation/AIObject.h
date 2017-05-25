//
//  AIObject.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIObject : NSObject

+(id) initWithContent:(id)content;
@property (strong,nonatomic) PointerModel *pointer; //数据指针
-(void) print;

@end
