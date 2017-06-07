//
//  Mood.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/4.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


//将要废弃的类...
/**
 *  MARK:--------------------mind元:"心情"--------------------
 *  受:Hobby,Demand,Mine所影响;三者各有其影响策略;
 */
@interface Mood : NSObject

@property (assign, nonatomic) int happyValue;        //happyValue只是一个值;描述各种

@end
