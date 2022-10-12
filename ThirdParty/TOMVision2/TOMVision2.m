//
//  TOMVision2.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/3/13.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TOMVision2.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "AIKVPointer.h"
#import "TOMVisionItemModel.h"
#import "UIView+Extension.h"
#import "TOMVisionFoView.h"
#import "TOMVisionDemandView.h"
#import "TOMVisionFoView.h"
#import "TOMVisionAlgView.h"
#import "TOModelVisionUtil.h"
#import "UnorderItemModel.h"
#import "TVPanelView.h"
#import "TVLineView.h"
#import "TVTimeLine.h"
#import "TVUtil.h"
#import "TVSettingWindow.h"

@interface TOMVision2 () <TVPanelViewDelegate,UIScrollViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) TVPanelView *panelView;
@property (strong, nonatomic) TVTimeLine *timeLine;
@property (assign, nonatomic) NSInteger changeIndex; //当前显示的index;
@property (weak, nonatomic) IBOutlet UILabel *tipLab;
@property (strong,nonatomic) UITapGestureRecognizer *doubleTap;
@property (strong,nonatomic) UITapGestureRecognizer *singleTap;
@property (strong,nonatomic) UILongPressGestureRecognizer *longTap;

@end

@implementation TOMVision2

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initData];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
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
    [self.scrollView setFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight - 20 - 40)];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = CGFLOAT_MIN;
    self.scrollView.maximumZoomScale = CGFLOAT_MAX;
    self.scrollView.showsHorizontalScrollIndicator = true;
    self.scrollView.showsVerticalScrollIndicator = true;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    //contentView
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 60)];
    
    //panelView
    self.panelView = [[TVPanelView alloc] init];
    self.panelView.delegate = self;
    [self.containerView addSubview:self.panelView];
    
    //timeLine
    self.timeLine = [[TVTimeLine alloc] init];
    self.timeLine.backgroundColor = UIColorWithRGBHexA(0xFFFFFF, 0);
    
    //doubleTap
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    self.doubleTap.numberOfTapsRequired = 2;
    self.doubleTap.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    //singleTap
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    self.singleTap.numberOfTapsRequired = 1;
    self.singleTap.numberOfTouchesRequired = 1;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.scrollView addGestureRecognizer:self.singleTap];
    
    //longTap
    self.longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    self.longTap.minimumPressDuration = 0.2;
    [self.scrollView addGestureRecognizer:self.longTap];
}

-(void) initData{
}

-(void) initDisplay{
    [self close];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) updateFrame{
    [self.panelView updateFrame];
}

/**
 *  MARK:--------------------refreshDisplay--------------------
 *  @version
 *      2022.03.19: 子节点与根节点同尺寸,只是缩放了而已 (如果调小尺寸,缩放就没意义了);
 *      2022.03.22: 每层hSpace间隔为当前层的1.8倍 (避免末枝很小却间距好远);
 *      2022.10.12: 改为先过滤出有效roots,避免排版还是按所有roots算,而导致排版错误BUG;
 */
-(void) refreshDisplay{
    [self refreshDisplay:false];
}
-(void) refreshDisplay:(BOOL)focusMode{
    //1. 数据准备;
    if (self.isHidden) return;
    __block TOMVisionItemModel *frameModel = nil;
    __block TOModelBase *changeModel = nil;
    [self.panelView getModel:self.changeIndex complete:^(TOMVisionItemModel *_frameModel, TOModelBase *_changeModel) {
        frameModel = _frameModel;
        changeModel = _changeModel;
    }];
    
    //2. 取出旧有节点缓存 & 并清空画板;
    NSArray *oldSubViews = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeBase.class];
    [self.contentView removeAllSubviews];
    
    //2. 刷新显示_计算根节点宽度 (参考25182-4);
    //注: 排版为[-NNN--NNN-],其中-为节点间距,NNN为节点宽度,占60%;
    //注: rootGroupW最大宽度为250;
    if (!frameModel) return;
    NSArray *validRoots = [SMGUtils filterArr:frameModel.roots checkValid:^BOOL(DemandModel *demand) {
        //3. 显示设置开关处理;
        if (!self.panelView.settingWindow.finishSwitch) {
            if (demand.status == TOModelStatus_Finish) return false;
        }
        if (!self.panelView.settingWindow.expiredSwitch) {
            if (ISOK(demand, ReasonDemandModel.class) && ((ReasonDemandModel*)demand).isExpired) return false;
        }
        if (!self.panelView.settingWindow.withOutSwitch) {
            if (demand.status == TOModelStatus_WithOut) return false;
        }
        if (!self.panelView.settingWindow.actYesSwitch) {
            if ([TOUtils endHavActYes:demand]) return false;
        }
        return true;
    }];
    
    CGFloat rootGroupW = MIN(ScreenWidth / validRoots.count, 420);
    CGFloat rootNodeW = rootGroupW * 0.6f;
    for (DemandModel *demand in validRoots) {
        //NSLog(@"----------> root下树为:\n%@",[TOModelVision cur2Sub:demand]);
        //3. 从demand根节点递归生长出它的分枝,
        NSMutableArray *unorderModels = [TOModelVisionUtil convertCur2Sub2UnorderModels:demand];
        
        //3. 转为nodeView
        for (UnorderItemModel *unorder in unorderModels) {
            
            //4. 新建根节点;
            TOMVisionNodeBase *nodeView = [self getOrCreateNode:unorder.data oldSubViews:oldSubViews];
            [self.contentView addSubview:nodeView];
            
            if (!nodeView.data.baseOrGroup) {
                
                //4. nodeX = (左侧空白0.2 + 下标) x 组宽;
                NSInteger index = [validRoots indexOfObject:nodeView.data];
                CGFloat nodeX = rootGroupW * (index + 0.2f);
                
                //5. root节点的frame指定;
                [nodeView setFrame:CGRectMake(nodeX, unorder.tabNum * 60, rootNodeW, rootNodeW / 5)];
                
                //6. 缩放比例
                [nodeView scaleContainer:1.0f];
            }else {
                
                //6. 子节点的frame指定;
                TOMVisionNodeBase *baseView = [self getOrCreateNode:nodeView.data.baseOrGroup oldSubViews:oldSubViews];
                NSMutableArray *subModels = [TOUtils getSubOutModels:nodeView.data.baseOrGroup];
                if (baseView && ARRISOK(subModels)) {
                    
                    //7. 子组最左X = 父组X - 左侧空白处(为节点宽的1/3);
                    CGFloat subGroupMinX = baseView.x - baseView.width / 3.0f;
                    
                    //7. 子元素宽度 = base宽度 / 子元素数;
                    CGFloat subGroupW = baseView.width / 0.6f / subModels.count;
                    CGFloat subNodeW = subGroupW * 0.6f;// (不需要了,根据sub/root组宽就能算出缩放比例);
                    
                    //7. nodeX = (左侧空白0.2 + 下标) x 组宽 + groupMinX;
                    NSInteger index = [subModels indexOfObject:nodeView.data];
                    CGFloat nodeX = subGroupW * (0.2f + index) + subGroupMinX;
                    
                    //8. 算出Y坐标 (baseView下方,自身高度的1.8倍);
                    CGFloat nodeY = CGRectGetMaxY(baseView.frame) + subNodeW / 5 * 1.8f;
                    
                    //8. sub节点的frame指定;
                    [nodeView setFrame:CGRectMake(nodeX, nodeY, subNodeW, subNodeW / 5)];
                    
                    //9. 对nodeView进行缩放 (缩放比例 = 子元素宽度 / rootWidth);
                    CGFloat scale = subGroupW / rootGroupW;
                    [nodeView scaleContainer:scale];
                    
                    //10. 连接线
                    TVLineView *line = [[TVLineView alloc] init];
                    [self.contentView insertSubview:line atIndex:0];
                    [line refreshDisplayWithDataA:nodeView nodeB:baseView];
                }
            }
        }
    }
    
    //11. 更新画板;
    [self autoAdjustContentSize];
    
    //12. 更新contentView的变化流数据;
    [self updateContentViewBezier];
    
    //13. 渲染完成_执行聚焦动画;
    if (focusMode) {
        [self focusAnimation:changeModel];
    }
}

-(void) clear{
    
}

-(void) setStop:(BOOL)stop{
    self.panelView.stop = stop;
}

-(void) open{
    [self setHidden:false];
    [self refreshDisplay];
}

-(void) close{
    [self setHidden:true];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================
-(BOOL) isOpen{
    return !self.isHidden;
}

/**
 *  MARK:--------------------聚焦动画--------------------
 *  @version
 *      2022.03.27: 改变anchor0会导致整个contentView坐标系变成中间0点,subView的xy都得跟着改,所以取消它并重调动画;
 */
-(void) focusAnimation:(TOModelBase*)focusModel{
    //1. 取单帧展示时长;
    CGFloat time = self.panelView.getFrameShowTime;
    if (time == 0) return;
    
    //2. 取focusView
    NSArray *subs = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeBase.class];
    TOMVisionNodeBase *focusView = nil;
    for (TOMVisionNodeBase *view in subs) {
        if ([view.data isEqual:focusModel]) {
            focusView = view;
            break;
        }
    }
    if (!focusView) return;
    self.tipLab.text = STRFORMAT(@"聚焦: %@",focusView.getNodeDesc);
    
    //3. scale只放大(至少100宽),不缩小;
    CGFloat scale = MAX(100.0f / focusView.width, 1.0f);
    
    //4. 第1动画: 重置大小,位置;
    [UIView animateWithDuration:time / 4.0f animations:^{
        self.scrollView.zoomScale = 1.0f;
        self.scrollView.contentOffset = CGPointZero;
    } completion:^(BOOL finished) {
        //4. 流程线粗;
        [self.timeLine setData:self.scrollView.zoomScale];
        
        //5. 第2动画: 焦点view显示在屏幕中心;
        [self animation4Scale:scale focusPoint:focusView.center time:time / 2.0f];
    }];
}

/**
 *  MARK:--------------------创建新节点--------------------
 *  @version
 *      2022.03.19: 将newSubViews和oldSubViews都参与复用 (本帧生成的node也需要复用,否则会找不到刚生成的父枝);
 *  @result notnull
 */
-(TOMVisionNodeBase*) getOrCreateNode:(id)data oldSubViews:(NSArray*)oldSubViews{
    //1. 数据准备 (原有和现有子views全用于复用);
    NSArray *newSubViews = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeBase.class];
    NSMutableArray *allSubViews = [SMGUtils collectArrA:oldSubViews arrB:newSubViews];
    
    //2. 优先找复用;
    TOMVisionNodeBase *result = ARR_INDEX([SMGUtils filterArr:allSubViews checkValid:^BOOL(TOMVisionNodeBase *subView) {
        return [subView isEqualByData:data];
    } limit:1], 0);
    
    //3. 没复用则新建;
    if (!result) {
        
        //4. demand节点;
        if (ISOK(data, DemandModel.class)) {
            result = [[TOMVisionDemandView alloc] init];
        }else if(ISOK(data, TOFoModel.class)){
            result = [[TOMVisionFoView alloc] init];
        }else if(ISOK(data, TOAlgModel.class)){
            result = [[TOMVisionAlgView alloc] init];
        }else{
            //还没支持的类型,就先返回baseView;
            result = [[TOMVisionNodeBase alloc] init];
            [result setBackgroundColor:UIColor.redColor];
        }
    }
    
    //4. 无论是复用,还是新建,都更新data (复用时,每帧同一个data也在更新);
    [result setData:data];
    return result;
}

//更新画板大小 (避免出屏的拖不到等问题);
-(void) autoAdjustContentSize{
    //1. 取最小尺寸;
    CGFloat contentW = ScreenWidth,contentH = ScreenHeight - 60;
    
    //2. 根据subView自动计算尺寸;
    for (UIView *subV in self.contentView.subviews) {
        contentW = MAX(contentW, CGRectGetMaxX(subV.frame) + 10.0f);
        contentH = MAX(contentH, CGRectGetMaxY(subV.frame) + 10.0f);
    }
    
    //3. 更新contentSize;
    [self.contentView setSize:CGSizeMake(contentW, contentH)];
    [self.scrollView setContentSize:CGSizeMake(contentW * self.scrollView.zoomScale, contentH * self.scrollView.zoomScale)];
}

//更新树生长时间线;
-(void) updateContentViewBezier {
    //1. 数据准备;
    __block NSMutableArray *points = [[NSMutableArray alloc] init];
    
    //2. 取出nodes
    NSArray *subViews = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeBase.class];
    
    //3. 对变化过程,分别收集坐标;
    for (NSInteger i = 0; i <= self.changeIndex; i++) {
        
        //4. 判断当前changeIndex有没有变化点;
        [self.panelView getModel:i complete:^(TOMVisionItemModel *_frameModel, TOModelBase *_changeModel) {
            if (_changeModel) {
                
                //5. 有的话,收集它的中心坐标;
                for (TOMVisionNodeBase *view in subViews) {
                    if ([view.data isEqual:_changeModel]) {
                        [points addObject:[NSValue valueWithCGPoint:view.center]];
                        break;
                    }
                }
            }
        }];
    }
    
    //6. 将坐标流更新到contentView;
    self.timeLine.bezierPoints = points;
    
    //7. 更新树生长时间线;
    [self.contentView insertSubview:self.timeLine atIndex:0];
    [self.timeLine setFrame:self.contentView.frame];
    [self.timeLine setData:self.scrollView.zoomScale];
}

/**
 *  MARK:--------------------缩放动画--------------------
 *  @param focusPoint : contentView上的点,此动画可将此点移到屏幕中心显示;
 */
-(void) animation4Scale:(CGFloat)newScale focusPoint:(CGPoint)focusPoint time:(CGFloat)time{
    //6. 坐标计算;
    CGFloat offsetX = newScale * focusPoint.x;
    CGFloat offsetY = newScale * focusPoint.y;
    
    //7. 坐标计算2: 减半屏,使之从左上角移到屏正中 (无论缩放比例多少,左上角中心到屏幕中心,都是半屏距离);
    CGFloat svW = self.scrollView.width;
    CGFloat svH = self.scrollView.height;
    offsetX -= svW / 2;
    offsetY -= svH / 2;
    
    //8. 坐标计算3: 当不缩放 且 offsetXY在左上区间时,则保持原位不居中;
    if (newScale <= 1.0f) {
        if (focusPoint.x < svW / 2) offsetX = 0;
        if (focusPoint.y < svH / 2) offsetY = 0;
    }
    
    //9. 流程线粗
    [self.timeLine setData:newScale];
    
    //9. 动画_执行动画 (居中 & 缩放);
    [UIView animateWithDuration:time animations:^{
        self.scrollView.zoomScale = newScale;
        self.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    }];
}

//返回手势选中的节点;
-(TOMVisionNodeBase*) tapedNode:(CGPoint)contentPoint{
    NSArray *nodes = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeBase.class];
    for (TOMVisionNodeBase *node in nodes) {
        if ([TVUtil inRect:node.frame point:contentPoint]) {
            return node;
        }
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (void)longTap:(UILongPressGestureRecognizer*)sender{
    //1. 防止重复触发
    if (sender.state != UIGestureRecognizerStateBegan) return;
    
    //2. 取点击坐标和默认缩放值;
    CGPoint scrollPoint = [sender locationInView:sender.view];
    CGPoint contentPoint = [sender.view convertPoint:scrollPoint toView:self.contentView];
    CGFloat newScale = self.scrollView.zoomScale / 1.5f;
    
    //3. 执行动画;
    [self animation4Scale:newScale focusPoint:contentPoint time:0.5f];
}

- (void)doubleTap:(UITapGestureRecognizer *)sender{
    //1. 取点击坐标和默认缩放值;
    CGPoint scrollPoint = [sender locationInView:sender.view];
    CGPoint contentPoint = [sender.view convertPoint:scrollPoint toView:self.contentView];
    CGFloat newScale = self.scrollView.zoomScale * 1.5f;
    
    //2. 点中节点时,强行: 缩放200宽 & 坐标居中;
    UIView *tapedNode = [self tapedNode:contentPoint];
    if (tapedNode) {
        newScale = 200 / tapedNode.width;
        contentPoint = tapedNode.center;
    }
    
    //3. 执行动画;
    [self animation4Scale:newScale focusPoint:contentPoint time:0.5f];
}

- (void)singleTap:(UITapGestureRecognizer *)sender{
    //1. 取点击坐标;
    CGPoint scrollPoint = [sender locationInView:sender.view];
    CGPoint contentPoint = [sender.view convertPoint:scrollPoint toView:self.contentView];
    
    //2. 点中节点;
    TOMVisionNodeBase *tapedNode = [self tapedNode:contentPoint];
    if (tapedNode) {
        [self.tipLab setText:tapedNode.getNodeDesc];
    }
}

//MARK:===============================================================
//MARK:                     < TVPanelViewDelegate >
//MARK:===============================================================
-(void) panelPlay:(NSInteger)changeIndex{
    BOOL focusMode = changeIndex - self.changeIndex == 1;
    self.changeIndex = changeIndex;
    [self refreshDisplay:focusMode];
}

-(void) panelCloseBtnClicked{
    [self close];
}

-(void) panelScaleChanged:(CGFloat)scale{
    self.scrollView.zoomScale = scale;
    [self autoAdjustContentSize];
    
    //流程线粗
    [self.timeLine setData:self.scrollView.zoomScale];
}

//MARK:===============================================================
//MARK:                     < UIScrollViewDelegate >
//MARK:===============================================================
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.contentView;
}

@end
