//
//  NEElement.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEElement : NSObject

@property (assign,nonatomic) NSInteger eId;

-(void) refreshNet;


/**
 *  MARK:--------------------nodePointer--------------------
 *  @return element对应的nodePointer的指针;
 *  注:如果element未refresh到Net;则先调用refreshNet再返回指针;
 */
-(AIPointer*) nodePointer;

@end
