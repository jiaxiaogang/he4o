//
//  Mood.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/4.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------心情--------------------
 *  受:Hobby,Demand,Mine所影响;三者各有其影响策略;
 */
@interface Mood : NSObject

@property (assign, nonatomic) int happyValue;        //哀乐值(-10到10) 探索行为+1,反馈怒-2;
-(void) refreshDecisionByOutputTask:(id)outputTask;

@end
