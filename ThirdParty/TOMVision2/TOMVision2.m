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

@interface TOMVision2 () <TVPanelViewDelegate,UIScrollViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) TVPanelView *panelView;
@property (strong, nonatomic) TOMVisionItemModel *model;

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
    //[self.scrollView setContentSize:CGSizeMake(ScreenWidth, ScreenHeight - 60)];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.1f;    //设置最小缩放倍数
    self.scrollView.maximumZoomScale = 20.0f;   //设置最大缩放倍数
    
    //contentView
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 60)];
    
    //panelView
    self.panelView = [[TVPanelView alloc] init];
    self.panelView.delegate = self;
    [self.containerView addSubview:self.panelView];
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
    [self.panelView updateFrame:false];
}

-(void) updateFrame:(BOOL)newLoop{
    [self.panelView updateFrame:newLoop];
}

/**
 *  MARK:--------------------refreshDisplay--------------------
 *  @version
 *      2022.03.19: 子节点与根节点同尺寸,只是缩放了而已 (如果调小尺寸,缩放就没意义了);
 *      2022.03.22: 每层hSpace间隔为当前层的1.8倍 (避免末枝很小却间距好远);
 */
-(void) refreshDisplay{
    //1. 数据检查;
    if (self.isHidden) return;
    
    //2. 取出旧有节点缓存 & 并清空画板;
    NSArray *oldSubViews = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeBase.class];
    [self.contentView removeAllSubviews];
    
    //2. 刷新显示_计算根节点宽度 (参考25182-4);
    //注: 排版为[-NNN--NNN-],其中-为节点间距,NNN为节点宽度,占60%;
    //注: rootGroupW最大宽度为250;
    if (!self.model) return;
    CGFloat rootGroupW = MIN(ScreenWidth / self.model.roots.count, 420);
    CGFloat rootNodeW = rootGroupW * 0.6f;
    for (DemandModel *demand in self.model.roots) {
        NSLog(@"----------> root下树为:\n%@",[TOModelVision cur2Sub:demand]);
        
        //3. 从demand根节点递归生长出它的分枝,
        NSMutableArray *unorderModels = [TOModelVisionUtil convertCur2Sub2UnorderModels:demand];
        
        //3. 转为nodeView
        for (UnorderItemModel *unorder in unorderModels) {
            
            //4. 新建根节点;
            TOMVisionNodeBase *nodeView = [self getOrCreateNode:unorder.data oldSubViews:oldSubViews];
            [self.contentView addSubview:nodeView];
            
            if (!nodeView.data.baseOrGroup) {
                
                //4. nodeX = (左侧空白0.2 + 下标) x 组宽;
                NSInteger index = [self.model.roots indexOfObject:nodeView.data];
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
                    NSLog(@"%@ X:%f Y:%f W:%f H:%f S:%f",Pit2FStr(nodeView.data.content_p),nodeView.x,nodeView.y,nodeView.width,nodeView.height,scale);
                    
                    //10. 连接线
                    TVLineView *line = [[TVLineView alloc] init];
                    [self.contentView insertSubview:line atIndex:0];
                    [line refreshDisplayWithDataA:nodeView nodeB:baseView];
                }
            }
        }
    }
    
    //11. 更新画板大小 (避免出屏的拖不到);
    CGFloat contentW = ScreenWidth,contentH = ScreenHeight - 60;
    for (UIView *subV in self.contentView.subviews) {
        contentW = MAX(contentW, CGRectGetMaxX(subV.frame) + 10.0f);
        contentH = MAX(contentH, CGRectGetMaxY(subV.frame) + 10.0f);
    }
    [self.contentView setSize:CGSizeMake(contentW, contentH)];
}

-(void) clear{
    
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

//MARK:===============================================================
//MARK:                     < TVPanelViewDelegate >
//MARK:===============================================================
-(void) panelPlay:(TOMVisionItemModel*)model{
    if (model && [model isEqual:self.model]) {
        return;
    }
    self.model = model;
    [self refreshDisplay];
}

-(void) panelCloseBtnClicked{
    [self close];
}

-(void) panelScaleChanged:(CGFloat)scale{
    self.scrollView.zoomScale = scale;
}

//MARK:===============================================================
//MARK:                     < UIScrollViewDelegate >
//MARK:===============================================================
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.contentView;
}

@end
