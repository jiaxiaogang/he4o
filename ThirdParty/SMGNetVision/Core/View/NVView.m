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
    [self setFrame:CGRectMake(0, 20, ScreenWidth, 20)];
    
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
    
    //moduleViews
    NSArray *moduleIds = [self nv_GetModuleIds];
    if (ARRISOK(moduleIds)) {
        CGFloat curModuleX = 2;
        CGFloat moduleW = 300;
        CGFloat moduleH = 276;
        [self.scrollView removeAllSubviews];
        for (NSString *moduleId in moduleIds) {
            NVModuleView *moduleView = [[NVModuleView alloc] init];
            moduleView.delegate = self;
            [moduleView setDataWithModuleId:moduleId];
            [moduleView setFrame:CGRectMake(curModuleX, 2, moduleW, moduleH)];
            [self.scrollView addSubview:moduleView];
            curModuleX += (moduleW + 2);
        }
        [self.scrollView setContentSize:CGSizeMake(curModuleX, 276)];
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
        NVModuleView *mView = [self getNVModuleView:nodeData];
        if (mView) {
            [mView setDataWithNodeData:nodeData];
        }
    }
}

/**
 *  MARK:--------------------获取nodeData所属的模块--------------------
 */
-(NVModuleView*) getNVModuleView:(id)nodeData{
    NSString *moduleId = STRTOOK([self nv_GetModuleId:nodeData]);
    for (NVModuleView *mView in self.scrollView.subviews) {
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
    [self.openCloseBtn setTitle:(self.isOpen ? @"收起" : @"放开") forState:UIControlStateNormal];
}

/**
 *  MARK:--------------------NVModuleViewDelegate--------------------
 */
-(UIView *)moduleView_GetCustomSubView:(id)nodeData{
    return [self nv_GetCustomSubNodeView:nodeData];
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
                    pointA = [nView.superview convertPoint:nView.center toView:self.scrollView];
                }else if([dataB isEqual:nView.data]){
                    pointB = [nView.superview convertPoint:nView.center toView:self.scrollView];
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
                [self.scrollView addSubview:lView];
                //[self.scrollView sendSubviewToBack:lView];
                //NSLog(@"drawLine A坐标:%f,%f B坐标:%f,%f line坐标:%f,%f line长度:%f line角度:%f",pointA.x,pointA.y,pointB.x,pointB.y,lView.x,lView.y,lView.width,angle * 180.0f / M_PI);
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

@end

