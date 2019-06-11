//
//  NVView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NVViewDelegate <NSObject>

-(UIView *)nv_GetCustomNodeView:(id)nodeData;
-(NSString*)nv_GetNodeDesc:(id)nodeData;

@end

/**
 *  MARK:--------------------NetVision主view--------------------
 *  1. 默认为关闭状态,点"放开"时再展开窗口;
 */
@interface NVView : UIView

@property (weak, nonatomic) id<NVViewDelegate> delegate;

@end

