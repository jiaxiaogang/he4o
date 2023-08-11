//
//  NVView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NVModuleView;
@protocol NVViewDelegate <NSObject>

//获取自定义节点view
-(UIView *)nv_GetCustomSubNodeView:(id)nodeData;

//获取节点颜色
-(UIColor *)nv_GetNodeColor:(id)nodeData;
-(UIColor *)nv_GetRightColor:(id)nodeData;

//获取节点透明度
-(CGFloat)nv_GetNodeAlpha:(id)nodeData;

//获取节点描述
-(NSString*)nv_NodeOnClick:(id)nodeData;

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

//追加节点
-(void)nv_AddNodeOnClick;

//报名
-(NSString*)nv_ShowName:(id)data;

//获取节点指向target的强度
-(NSInteger)nv_GetPortStrong:(id)mainNodeData target:(id)targetNodeData;

//directionClick
-(void)nv_DirectionClick:(int)type mView:(NVModuleView*)mView nData:(id)nData targetDatas:(NSArray*)targetDatas;

//longClick
-(void)nv_LongClick:(int)type mView:(NVModuleView*)mView nData:(id)nData;

@end

/**
 *  MARK:--------------------NetVision主view--------------------
 *  1. 默认为关闭状态,点"放开"时再展开窗口;
 */
@interface NVView : UIView

@property (assign, nonatomic) BOOL forceMode; //强力模式 (在此模式下,即使UI未展示,也会强行加入node);
-(id) initWithDelegate:(id<NVViewDelegate>)delegate;

/**
 *  MARK:--------------------设置内容--------------------
 */
-(void) setNodeData:(id)nodeData;
-(void) setNodeDatas:(NSArray*)nodeDatas;
-(void) setNodeData:(id)nodeData lightStr:(NSString*)lightStr;
-(void) setNodeData:(id)nodeData appendLightStr:(NSString*)appendLightStr;

/**
 *  MARK:--------------------移除内容--------------------
 */
-(void) removeNodeDatas:(NSArray*)nodeDatas;

/**
 *  MARK:--------------------清空网络--------------------
 */
-(void) clear;

/**
 *  MARK:--------------------节点描述--------------------
 */
-(void) lightNode:(id)nodeData str:(NSString*)str;

/**
 *  MARK:--------------------线描述--------------------
 */
-(void) lightLine:(id)nodeDataA nodeDataB:(id)nodeDataB str:(NSString*)str;
-(void) lightLineStrong:(id)nodeDataA nodeDataB:(id)nodeDataB;

/**
 *  MARK:--------------------清空节点描述--------------------
 */
-(void) clearLight;
-(void) clearLight:(NSString*)moduleId;

/**
 *  MARK:--------------------获取节点描述--------------------
 */
-(NSString*) getLightStr:(id)nodeData;

/**
 *  MARK:--------------------在强行工作模式下执行block--------------------
 */
-(void) invokeForceMode:(void(^)())block;
+(void) invokeForceMode:(void(^)())block;

@end

