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
#import "NodeView.h"
#import "ModuleView.h"

@interface NVView () <NodeViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *nodeArr;
@property (assign, nonatomic) BOOL isOpen;
@property (weak, nonatomic) IBOutlet UIButton *openCloseBtn;
@property (weak, nonatomic) id<NVViewDelegate> delegate;

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
        CGFloat moduleW = 150;
        CGFloat moduleH = 276;
        [self.scrollView removeAllSubviews];
        for (NSString *moduleId in moduleIds) {
            ModuleView *moduleView = [[ModuleView alloc] init];
            [moduleView setData:moduleId];
            [moduleView setFrame:CGRectMake(curModuleX, 2, moduleW, moduleH)];
            [self.scrollView addSubview:moduleView];
            curModuleX += (moduleW + 2);
        }
        [self.scrollView setContentSize:CGSizeMake(curModuleX, 276)];
    }
}

-(void) initData{
    self.nodeArr = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setNodeData:(id)nodeData{
    if (nodeData) {
        if (![self.nodeArr containsObject:nodeData]) {
            [self.nodeArr addObject:nodeData];
            [self refreshDisplay];
        }
    }
}

-(void) refreshDisplay{
    //1. 显示所有node
    for (id nodeData in self.nodeArr) {
        ModuleView *mView = [self getModuleView:nodeData];
        if (mView) {
            NodeView *nodeView = [[NodeView alloc] init];
            nodeView.delegate = self;
            [nodeView setDataWithNodeData:nodeData];
            [mView addSubview:nodeView];
        }
    }
    
    //2. 显示所有line
    
    //3. 排版,重置计算所有坐标;
}

/**
 *  MARK:--------------------获取nodeData所属的模块--------------------
 */
-(ModuleView*) getModuleView:(id)nodeData{
    NSString *moduleId = STRTOOK([self nv_GetModuleId:nodeData]);
    for (ModuleView *mView in self.scrollView.subviews) {
        if (ISOK(mView, ModuleView.class) && [moduleId isEqualToString:mView.moduleId]) {
            return mView;
        }
    }
    return nil;
}


/**
 *  MARK:--------------------NodeViewDelegate--------------------
 */
-(UIView *)nodeView_GetCustomSubView:(id)nodeData{
    return [self nv_GetCustomNodeView:nodeData];
}
-(NSString*) nodeView_GetTipsDesc:(id)nodeData{
    return [self nv_GetNodeTipsDesc:nodeData];
}
-(void) nodeView_TopClick:(id)nodeData{
    NSArray *absPorts = [self nv_AbsPorts:nodeData];
    NSLog(@"%@",absPorts);
}
-(void) nodeView_BottomClick:(id)nodeData{
    NSArray *conPorts = [self nv_ConPorts:nodeData];
    NSLog(@"%@",conPorts);
}
-(void) nodeView_LeftClick:(id)nodeData{
    NSArray *content_ps = [self nv_Content_ps:nodeData];
    NSLog(@"%@",content_ps);
}
-(void) nodeView_RightClick:(id)nodeData{
    NSArray *refPorts = [self nv_GetRefPorts:nodeData];
    NSLog(@"%@",refPorts);
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)openCloseBtnOnClick:(id)sender {
    self.isOpen = !self.isOpen;
    self.height = self.isOpen ? 300 : 20;
    [self.openCloseBtn setTitle:(self.isOpen ? @"收起" : @"放开") forState:UIControlStateNormal];
}

//MARK:===============================================================
//MARK:                     < SelfDelegate >
//MARK:===============================================================
-(UIView *)nv_GetCustomNodeView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetCustomNodeView:)]) {
        return [self.delegate nv_GetCustomNodeView:nodeData];
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
-(NSArray*)nv_GetRefPorts:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetRefPorts:)]) {
        return [self.delegate nv_GetRefPorts:nodeData];
    }
    return nil;
}
-(NSArray*)nv_Content_ps:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_Content_ps:)]) {
        return [self.delegate nv_Content_ps:nodeData];
    }
    return nil;
}
-(NSArray*)nv_AbsPorts:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_AbsPorts:)]) {
        return [self.delegate nv_AbsPorts:nodeData];
    }
    return nil;
}
-(NSArray*)nv_ConPorts:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_ConPorts:)]) {
        return [self.delegate nv_ConPorts:nodeData];
    }
    return nil;
}

@end

