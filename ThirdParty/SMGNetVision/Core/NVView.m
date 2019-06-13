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
#import "ModuleView.h"

@interface NVView () <ModuleViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIScrollView *scrollView;
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
        ModuleView *mView = [self getModuleView:nodeData];
        if (mView) {
            [mView setDataWithNodeData:nodeData];
        }
    }
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

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)openCloseBtnOnClick:(id)sender {
    self.isOpen = !self.isOpen;
    self.height = self.isOpen ? 300 : 20;
    [self.openCloseBtn setTitle:(self.isOpen ? @"收起" : @"放开") forState:UIControlStateNormal];
}

/**
 *  MARK:--------------------ModuleViewDelegate--------------------
 */
-(UIView *)moduleView_GetCustomSubView:(id)nodeData{
    return [self nv_GetCustomNodeView:nodeData];
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

