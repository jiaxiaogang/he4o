//
//  NVNodeView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  MARK:--------------------NodeView代理--------------------
 *  @desc : 运行在nv.core内部,nodeView的每个方法必须被实现;
 */
@protocol NVNodeViewDelegate <NSObject>

-(UIView*) nodeView_GetCustomSubView:(id)nodeData;
-(UIColor *)nodeView_GetNodeColor:(id)nodeData;
-(CGFloat)nodeView_GetNodeAlpha:(id)nodeData;
-(NSString*) nodeView_OnClick:(id)nodeData;
-(void) nodeView_TopClick:(id)nodeData;
-(void) nodeView_BottomClick:(id)nodeData;
-(void) nodeView_LeftClick:(id)nodeData;
-(void) nodeView_RightClick:(id)nodeData;

@end

/**
 *  MARK:--------------------节点view--------------------
 */
@interface NVNodeView : UIView

@property (readonly,strong, nonatomic) id data;//一般为一个指针
@property (weak, nonatomic) id<NVNodeViewDelegate> delegate;
-(void) setDataWithNodeData:(id)nodeData;

/**
 *  MARK:--------------------闪烁--------------------
 */
-(void) light:(NSString*)lightStr;
-(void) clearLight;

-(void) setTitle:(NSString*)titleStr showTime:(CGFloat)showTime;

@end
