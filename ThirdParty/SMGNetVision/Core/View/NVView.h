//
//  NVView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NVViewDelegate <NSObject>

//获取自定义节点view
-(UIView *)nv_GetCustomSubNodeView:(id)nodeData;

//获取节点描述
-(NSString*)nv_GetNodeTipsDesc:(id)nodeData;

//获取模块Id
-(NSArray*)nv_GetModuleIds;
-(NSString*)nv_GetModuleId:(id)nodeData;

//获取节点的被引用序列
-(NSArray*)nv_GetRefNodeDatas:(id)nodeData;

//获取节点的引用序列(内容)
-(NSArray*)nv_ContentNodeDatas:(id)nodeData;

//获取节点的抽象序列
-(NSArray*)nv_AbsNodeDatas:(id)nodeData;

//获取节点的具象序列
-(NSArray*)nv_ConNodeDatas:(id)nodeData;

@end

/**
 *  MARK:--------------------NetVision主view--------------------
 *  1. 默认为关闭状态,点"放开"时再展开窗口;
 */
@interface NVView : UIView

-(id) initWithDelegate:(id<NVViewDelegate>)delegate;
-(void) setNodeData:(id)nodeData;

@end

