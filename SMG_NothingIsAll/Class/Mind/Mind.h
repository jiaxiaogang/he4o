//
//  Mind.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------精神(七情六欲)--------------------
 *  喜,怒,哀,乐
 *  喜怒主外;
 *  哀乐主内;
 *  注:目前只写喜怒哀乐;主要是用于人工智能的交流和学习功能;
 */
@interface Mind : NSObject

@property (assign, nonatomic) int joyAngerValue;    //喜怒值(-10到10)


/**
 *  MARK:--------------------哀乐值--------------------
 *  value:(-10到10)
 *  探索行为+1,反馈怒-2;
 *
 */
@property (assign, nonatomic) int sadHappyValue;

@property (assign, nonatomic) double lastChangeTime;

@end
