//
//  NVModuleView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NVModuleViewDelegate <NSObject>

//获取自定义nodeView
-(UIView *)moduleView_GetCustomSubView:(id)nodeData;

//获取节点描述
-(NSString*)moduleView_GetTipsDesc:(id)nodeData;

//获取节点的抽象序列
-(NSArray*)moduleView_AbsNodeDatas:(id)nodeData;

//获取节点的具象序列
-(NSArray*)moduleView_ConNodeDatas:(id)nodeData;

//获取节点的引用序列(内容)
-(NSArray*)moduleView_ContentNodeDatas:(id)nodeData;

//获取节点的被引用序列
-(NSArray*)moduleView_RefNodeDatas:(id)nodeData;

//获取所有网络中的节点数据 (判定关联)
-(NSArray*)moduleView_GetAllNetDatas;

//获取所有网络中的节点数据 (判定关联)
-(void)moduleView_DrawLine:(NSArray*)lineDatas;

@end

/**
 *  MARK:--------------------模块View--------------------
 *  网络模块View;
 */
@interface NVModuleView : UIView

@property (readonly,strong, nonatomic) NSString *moduleId;
@property (readonly,strong, nonatomic) NSMutableArray *nodeArr;
@property (weak, nonatomic) id<NVModuleViewDelegate> delegate;
-(void) setDataWithModuleId:(NSString*)moduleId;
-(void) setDataWithNodeData:(id)nodeData;

@end
