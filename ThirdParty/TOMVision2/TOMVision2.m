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

@interface TOMVision2 () <TVPanelViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) TVPanelView *panelView;
@property (strong, nonatomic) TOMVisionItemModel *model;
@property (assign, nonatomic) CGFloat contentViewScale;

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
    [self.scrollView setContentSize:CGSizeMake(ScreenWidth, ScreenHeight - 60)];
    
    //contentView
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 60)];
    
    //panelView
    self.panelView = [[TVPanelView alloc] init];
    self.panelView.delegate = self;
    [self.containerView addSubview:self.panelView];
    
    //scaleGes
    UIPinchGestureRecognizer *scaleGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleGesAction:)];
    [self.contentView addGestureRecognizer:scaleGes];
}

-(void) initData{
    self.contentViewScale = 1.0f;
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
 */
-(void) refreshDisplay{
    //1. 数据检查;
    if (!self.model) return;
    
    //2. 取出旧有节点缓存 & 并清空画板;
    NSArray *oldSubViews = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeBase.class];
    [self.contentView removeAllSubviews];
    
    //2. 刷新显示_计算根节点宽度 (参考25182-4);
    //注: 排版为[-NNN--NNN-],其中-为节点间距,NNN为节点宽度,占60%;
    //注: rootGroupW最大宽度为250;
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
                    
                    //8. sub节点的frame指定;
                    [nodeView setFrame:CGRectMake(nodeX, unorder.tabNum * 60, subNodeW, subNodeW / 5)];
                    
                    //9. 对nodeView进行缩放 (缩放比例 = 子元素宽度 / rootWidth);
                    CGFloat scale = subGroupW / rootGroupW;
                    [nodeView scaleContainer:scale];
                    NSLog(@"%@ X:%f Y:%f W:%f H:%f S:%f",Pit2FStr(nodeView.data.content_p),nodeView.x,nodeView.y,nodeView.width,nodeView.height,scale);
                }
            }
        }
    }
}

-(void) clear{
    
}

-(void) invokeForceMode:(void(^)())block{
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL bakForceMode = self.forceMode;
            [self setForceMode:true];
            block();
            [self setForceMode:bakForceMode];
        });
    }
}

-(void) open{
    [self setHidden:false];
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
            [result setData:data];
        }else if(ISOK(data, TOFoModel.class)){
            result = [[TOMVisionFoView alloc] init];
            [result setData:data];
        }else if(ISOK(data, TOAlgModel.class)){
            result = [[TOMVisionAlgView alloc] init];
            [result setData:data];
        }else{
            //TODOTOMORROW20220317: 别的类型还没支持,就先返回baseView;
            result = [[TOMVisionNodeBase alloc] init];
            [result setData:data];
            [result setBackgroundColor:UIColor.redColor];
        }
    }
    
    return result;
}

-(void) refreshDisplay_ContentView{
    //1. 缩放显示;
    [self.contentView setTransform:CGAffineTransformMakeScale(self.contentViewScale, self.contentViewScale)];
    
    //2. 中间对齐 (避免显示内容出界);
    self.contentView.center = CGPointMake(self.contentView.width / 2, self.contentView.height / 2);
    
    //3. 更新scrollView滑动内容尺寸;
    [self.scrollView setContentSize:self.contentView.size];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
-(void) scaleGesAction:(UIPinchGestureRecognizer*)ges{
    if (ges.state == UIGestureRecognizerStateChanged) {
        self.contentViewScale *= ges.scale;
        [self refreshDisplay_ContentView];
    }
}

//MARK:===============================================================
//MARK:                     < TVPanelViewDelegate >
//MARK:===============================================================
-(void) panelPlay:(TOMVisionItemModel*)model{
    if (![model isEqual:self.model]) {
        self.model = model;
        [self refreshDisplay];
    }
}

-(void) panelCloseBtnClicked{
    [self close];
}

-(void) panelScaleChanged:(CGFloat)scale{
    self.contentViewScale = scale;
    [self refreshDisplay_ContentView];
}

@end
