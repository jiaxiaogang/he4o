//
//  ModuleView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModuleViewDelegate <NSObject>

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

@end

/**
 *  MARK:--------------------模块View--------------------
 *  网络模块View;
 */
@interface ModuleView : UIView

@property (readonly,strong, nonatomic) NSString *moduleId;
@property (weak, nonatomic) id<ModuleViewDelegate> delegate;
-(void) setDataWithModuleId:(NSString*)moduleId;
-(void) setDataWithNodeData:(id)nodeData;

@end
