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
 *
 *  喜,怒,哀,乐
 *  喜怒主外;
 *  哀乐主内;
 *  注:目前只写喜怒哀乐;主要是用于人工智能的交流和学习功能;
 *
 */
@interface Mood : NSObject


@property (assign, nonatomic) int sadHappyValue;        //哀乐值(-10到10) 探索行为+1,反馈怒-2;
@property (assign, nonatomic) double lastChangeTime;    //最后心情变化时间


/**
 *  MARK:--------------------心情变化--------------------
 */
-(void) changeSadHappyValue:(int)value;
//@property (assign, nonatomic) int joyAngerValue;    //喜怒值(-10到10)



-(void) refreshDecisionByOutputTask:(id)outputTask;





@end
