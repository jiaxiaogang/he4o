//
//  NVView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "NVModuleView.h"
#import "NVNodeView.h"
#import "NVLineView.h"
#import "NVViewUtil.h"

@interface NVView () <NVModuleViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) BOOL isOpen;
@property (weak, nonatomic) IBOutlet UIButton *openCloseBtn;
@property (strong, nonatomic) id<NVViewDelegate> delegate;
@property (strong, nonatomic) UIView *contentView;

@end

@implementation NVView

-(id) initWithDelegate:(id<NVViewDelegate>)delegate {
    self = [super init];
    if(self != nil){
        self.delegate = delegate;
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setFrame:CGRectMake(ScreenWidth - 40, 20, 40, 20)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    //scrollView
    self.scrollView = [[UIScrollView alloc] init];
    [self.containerView addSubview:self.scrollView];
    [self.scrollView setFrame:CGRectMake(0, 20, ScreenWidth, 280)];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    
    //contentView
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    //moduleViews
    NSArray *moduleIds = [self nv_GetModuleIds];
    if (ARRISOK(moduleIds)) {
        CGFloat curModuleX = 2;
        CGFloat moduleW = 300;
        CGFloat moduleH = 276;
        for (NSString *moduleId in moduleIds) {
            NVModuleView *moduleView = [[NVModuleView alloc] init];
            moduleView.delegate = self;
            [moduleView setDataWithModuleId:moduleId];
            [moduleView setFrame:CGRectMake(curModuleX, 2, moduleW, moduleH)];
            [self.contentView addSubview:moduleView];
            curModuleX += (moduleW + 2);
        }
        [self.scrollView setContentSize:CGSizeMake(curModuleX, 276)];
        [self.contentView setFrame:CGRectMake(0, 0, curModuleX, 276)];
    }
}

-(void) initData{
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setNodeData:(id)nodeData{
    if (nodeData) {
        [self setNodeDatas:@[nodeData]];
    }
}

-(void) setNodeDatas:(NSArray*)nodeDatas{
    //1. 数据准备
    nodeDatas = ARRTOOK(nodeDatas);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    //2. 分组
    for (id data in nodeDatas) {
        NSString *mId = STRTOOK([self nv_GetModuleId:data]);
        NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[dic objectForKey:mId]];
        [mArr addObject:data];
        [dic setObject:mArr forKey:mId];
    }
    
    //3. 显示
    for (NSString *mId in dic.allKeys) {
        NVModuleView *mView = [self getNVModuleViewWithModuleId:mId];
        if (mView) {
            [mView setDataWithNodeDatas:[dic objectForKey:mId]];
        }
    }
}

-(void) clear{
    //1. 清模块
    NSArray *mViews = ARRTOOK([self subViews_AllDeepWithClass:NVModuleView.class]);
    for (NVModuleView *mView in mViews) {
        [mView clear];
    }
    
    //2. 清线
    NSArray *lViews = ARRTOOK([self subViews_AllDeepWithClass:NVLineView.class]);
    for (NVLineView *lView in lViews) {
        [lView removeFromSuperview];
    }
}

/**
 *  MARK:--------------------获取nodeData所属的模块--------------------
 */
-(NVModuleView*) getNVModuleViewWithModuleId:(NSString*)moduleId{
    moduleId = STRTOOK(moduleId);
    for (NVModuleView *mView in self.contentView.subviews) {
        if (ISOK(mView, NVModuleView.class) && [moduleId isEqualToString:mView.moduleId]) {
            return mView;
        }
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)openCloseBtnOnClick:(id)sender {
    self.isOpen = !self.isOpen;
    self.height = self.isOpen ? 300 : 20;
    self.x = self.isOpen ? 0 : ScreenWidth - 40;
    self.width = self.isOpen ? ScreenWidth : 40;
    [self.openCloseBtn setTitle:(self.isOpen ? @"一" : @"口") forState:UIControlStateNormal];
}
- (IBAction)clearBtnOnClick:(id)sender {
    [self clear];
}
- (IBAction)addBtnOnClick:(id)sender {
    [self nv_AddNodeOnClick];
}

/**
 *  MARK:--------------------NVModuleViewDelegate--------------------
 */
-(UIView *)moduleView_GetCustomSubView:(id)nodeData{
    return [self nv_GetCustomSubNodeView:nodeData];
}

-(UIColor *)moduleView_GetNodeColor:(id)nodeData{
    return [self nv_GetNodeColor:nodeData];
}

-(NSString*)moduleView_GetTipsDesc:(id)nodeData{
    return [self nv_GetNodeTipsDesc:nodeData];
}

-(NSArray*)moduleView_AbsNodeDatas:(id)nodeData{
    return [self nv_AbsNodeDatas:nodeData];
}

-(NSArray*)moduleView_ConNodeDatas:(id)nodeData{
    return [self nv_ConNodeDatas:nodeData];
}

-(NSArray*)moduleView_ContentNodeDatas:(id)nodeData{
    return [self nv_ContentNodeDatas:nodeData];
}

-(NSArray*)moduleView_RefNodeDatas:(id)nodeData{
    return [self nv_GetRefNodeDatas:nodeData];
}

-(NSArray*)moduleView_GetAllNetDatas{
    NSMutableArray *netDatas = [[NSMutableArray alloc] init];
    NSArray *moduleViews = ARRTOOK([self subViews_AllDeepWithClass:NVModuleView.class]);
    for (NVModuleView *mView in moduleViews) {
        [netDatas addObjectsFromArray:mView.nodeArr];
    }
    return netDatas;
}

-(void)moduleView_SetNetDatas:(NSArray*)datas{
    [self setNodeDatas:datas];
}

-(void)moduleView_DrawLine:(NSArray*)lineDatas{
    //1. 数据准备
    lineDatas = ARRTOOK(lineDatas);
    NSArray *nodeViews = ARRTOOK([self subViews_AllDeepWithClass:NVNodeView.class]);
    NSArray *lineViews = ARRTOOK([self subViews_AllDeepWithClass:NVLineView.class]);
    
    //2. 逐根画线
    for (NSArray *lineData in lineDatas) {
        
        //3. 准备两端的数据
        id dataA = ARR_INDEX(lineData, 0);
        id dataB = ARR_INDEX(lineData, 1);
        if (dataA && dataB) {
            
            //4. 去掉旧有线
            for (NVLineView *lView in lineViews) {
                if ([lView.data containsObject:dataA] && [lView.data containsObject:dataB]) {
                    [lView removeFromSuperview];
                }
            }
            
            //5. 获取两端的坐标
            CGPoint pointA = CGPointZero;
            CGPoint pointB = CGPointZero;
            for (NVNodeView *nView in nodeViews) {
                if ([dataA isEqual:nView.data]) {
                    pointA = [nView.superview convertPoint:nView.center toView:self.contentView];
                }else if([dataB isEqual:nView.data]){
                    pointB = [nView.superview convertPoint:nView.center toView:self.contentView];
                }
            }
            
            //6. 画线
            if (!CGPointEqualToPoint(pointA, CGPointZero) && !CGPointEqualToPoint(pointB, CGPointZero)) {
                //7. 计算线长度
                float width = [NVViewUtil distancePoint:pointA second:pointB];
                
                //8. 计算线中心位置
                float centerX = (pointA.x + pointB.x) / 2.0f;
                float centerY = (pointA.y + pointB.y) / 2.0f;
                
                //9. 旋转角度
                CGFloat angle = [NVViewUtil anglePoint:pointA second:pointB];
                
                //10. draw
                NVLineView *lView = [[NVLineView alloc] init];
                lView.width = width;
                [lView.layer setTransform:CATransform3DMakeRotation(angle, 0, 0, 1)];
                lView.center = CGPointMake(centerX, centerY);
                [lView setDataWithDataA:dataA dataB:dataB];
                [self.contentView addSubview:lView];
            }
        }
    }
}

-(void)moduleView_ClearLine:(NSArray*)datas{
    //1. 数据准备
    datas = ARRTOOK(datas);
    NSArray *lineViews = ARRTOOK([self subViews_AllDeepWithClass:NVLineView.class]);
    
    //2. 遍历找到含有nodeData的线,并清除
    for (NSArray *nodeData in datas) {
        for (NVLineView *lView in lineViews) {
            if ([lView.data containsObject:nodeData]) {
                [lView removeFromSuperview];
            }
        }
    }
}

//MARK:===============================================================
//MARK:                     < SelfDelegate >
//MARK:===============================================================
-(UIView *)nv_GetCustomSubNodeView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetCustomSubNodeView:)]) {
        return [self.delegate nv_GetCustomSubNodeView:nodeData];
    }
    return nil;
}
- (UIColor *)nv_GetNodeColor:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetNodeColor:)]) {
        return [self.delegate nv_GetNodeColor:nodeData];
    }
    return nil;
}
-(NSString*)nv_GetNodeTipsDesc:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetNodeTipsDesc:)]) {
        return [self.delegate nv_GetNodeTipsDesc:nodeData];
    }
    return nil;
}
-(NSArray*)nv_GetModuleIds{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetModuleIds)]) {
        return [self.delegate nv_GetModuleIds];
    }
    return nil;
}
-(NSString*)nv_GetModuleId:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetModuleId:)]) {
        return [self.delegate nv_GetModuleId:nodeData];
    }
    return nil;
}
-(NSArray*)nv_GetRefNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetRefNodeDatas:)]) {
        return [self.delegate nv_GetRefNodeDatas:nodeData];
    }
    return nil;
}
-(NSArray*)nv_ContentNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_ContentNodeDatas:)]) {
        return [self.delegate nv_ContentNodeDatas:nodeData];
    }
    return nil;
}
-(NSArray*)nv_AbsNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_AbsNodeDatas:)]) {
        return [self.delegate nv_AbsNodeDatas:nodeData];
    }
    return nil;
}
-(NSArray*)nv_ConNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_ConNodeDatas:)]) {
        return [self.delegate nv_ConNodeDatas:nodeData];
    }
    return nil;
}
-(void)nv_AddNodeOnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_AddNodeOnClick)]) {
        return [self.delegate nv_AddNodeOnClick];
    }
}

@end
