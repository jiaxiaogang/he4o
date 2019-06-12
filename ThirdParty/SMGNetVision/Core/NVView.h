//
//  NVView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NVViewDelegate <NSObject>

/**
 *  MARK:--------------------获取自定义节点view--------------------
 */
-(UIView *)nv_GetCustomNodeView:(id)nodeData;

/**
 *  MARK:--------------------获取节点描述--------------------
 */
-(NSString*)nv_GetNodeTipsDesc:(id)nodeData;

/**
 *  MARK:--------------------获取模块Id--------------------
 */
-(NSArray*)nv_GetModuleIds;
-(NSString*)nv_GetModuleId:(id)nodeData;

/**
 *  MARK:--------------------获取节点的引用序列--------------------
 *  注: 点击右角触发
 */
-(NSArray*)nv_GetRefPorts:(id)nodeData;

/**
 *  MARK:--------------------获取节点的内容序列--------------------
 *  注: 点击左角触发
 */
-(NSArray*)nv_Content_ps:(id)nodeData;

/**
 *  MARK:--------------------获取节点的抽象序列--------------------
 *  注: 点击上角触发
 */
-(NSArray*)nv_AbsPorts:(id)nodeData;

/**
 *  MARK:--------------------获取节点的具象序列--------------------
 *  注: 点击下角触发
 */
-(NSArray*)nv_ConPorts:(id)nodeData;

@end

/**
 *  MARK:--------------------NetVision主view--------------------
 *  1. 默认为关闭状态,点"放开"时再展开窗口;
 */
@interface NVView : UIView

-(id) initWithDelegate:(id<NVViewDelegate>)delegate;
-(void) setNodeData:(id)nodeData;

@end

