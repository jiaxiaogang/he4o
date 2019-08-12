//
//  NVNodeView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVNodeView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "BorderLabel.h"
#import "NVConfig.h"

@interface NVNodeView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIControl *contentView;
@property (strong, nonatomic) UIView *customSubView;
@property (strong, nonatomic) UIButton *topBtn;
@property (strong, nonatomic) UIButton *bottomBtn;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet BorderLabel *lightLab;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end

@implementation NVNodeView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setBackgroundColor:[UIColor clearColor]];
    [self setFrame:CGRectMake(0, 0, cNodeSize, cNodeSize)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    //contentView
    [self.contentView.layer setMasksToBounds:true];
    [self.contentView.layer setCornerRadius:cNodeSize * 0.5f];
    [self.contentView.layer setBorderColor:UIColorWithRGBHex(0xAAAAAA).CGColor];
    [self.contentView.layer setBorderWidth:1];
    
    //edgeBtnSize
    CGFloat btnW = cNodeSize * 0.6f;
    CGFloat btnL = cNodeSize * 0.8f;
    CGFloat btnMargin = (cNodeSize - btnL) * 0.5f;
    CGRect leftF = CGRectMake(btnW * -0.5f, btnMargin, btnW, btnL);
    CGRect rightF = CGRectMake(cNodeSize + btnW * -0.5f,btnMargin, btnW, btnL);
    CGRect topF = CGRectMake(btnMargin,btnW * -0.5f,btnL,btnW);
    CGRect bottomF = CGRectMake(btnMargin,btnW * -0.5f + cNodeSize,btnL,btnW);
    
    //createEdgeBtn
    self.leftBtn = [self createEdgeBtn:leftF onClick:@selector(leftBtnOnClick:)];
    self.rightBtn = [self createEdgeBtn:rightF onClick:@selector(rightBtnOnClick:)];
    self.topBtn = [self createEdgeBtn:topF onClick:@selector(topBtnOnClick:)];
    self.bottomBtn = [self createEdgeBtn:bottomF onClick:@selector(bottomBtnOnClick:)];
    
    //ligthLab
    [self.lightLab setUserInteractionEnabled:false];
    self.lightLab.borderColor = [UIColor whiteColor];
    self.lightLab.borderWidth = 3.0f / [UIScreen mainScreen].scale;
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setDataWithNodeData:(id)nodeData{
    _data = nodeData;
    [self refreshDisplay];
}

-(void) refreshDisplay{
    //1. 移除旧的subView
    if (self.customSubView) {
        [self.customSubView removeFromSuperview];
    }
    
    //2. 优先取自定义subView (默认时不显示)
    self.customSubView = [self nodeView_GetCustomSubView:self.data];
    
    //4. 显示
    if (self.customSubView) {
        [self.containerView addSubview:self.customSubView];
        [self.containerView sendSubviewToBack:self.customSubView];
        [self.customSubView setUserInteractionEnabled:false];
    }
    
    //5. nodeColor
    UIColor *nodeColor = [self nodeView_GetNodeColor:self.data];
    if (nodeColor) {
        [self.contentView setBackgroundColor:nodeColor];
    }
    
    //6. nodeAlpha
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetNodeAlpha:)]) {
        CGFloat alpha = [self.delegate nodeView_GetNodeAlpha:self.data];
        [self.contentView setAlpha:alpha];
    }
}

-(void) light:(NSString*)lightStr{
    [self.lightLab setText:lightStr];
}

-(void) clearLight{
    [self.lightLab setText:@""];
}

-(void) setTitle:(NSString*)titleStr showTime:(CGFloat)showTime {
    [self.titleLab setText:titleStr];
    if (showTime > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(showTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.titleLab setText:@""];
        });
    }
}

-(UIButton*) createEdgeBtn:(CGRect)frame onClick:(SEL)onClick{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setBackgroundColor:[UIColor blackColor]];
    [btn addTarget:self action:onClick forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    [btn.layer setCornerRadius:MAX(frame.size.width,frame.size.height) * 0.5f];
    [btn.layer setBorderWidth:1.0f / UIScreen.mainScreen.scale];
    [btn.layer setBorderColor:[UIColor grayColor].CGColor];
    return btn;
}

//MARK:===============================================================
//MARK:                     < onClick >
//MARK:===============================================================
- (IBAction)contentViewTouchDown:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_OnClick:)]) {
        NSString *desc = [self.delegate nodeView_OnClick:self.data];
        TPLog(@"> %@", desc);
    }
}
- (IBAction)contentViewTouchCancel:(id)sender {
    TPLog(@"松开");
}
- (void)topBtnOnClick:(id)sender {
    [self nodeView_TopClick:self.data];
}
- (void)bottomBtnOnClick:(id)sender {
    [self nodeView_BottomClick:self.data];
}
- (void)leftBtnOnClick:(id)sender {
    [self nodeView_LeftClick:self.data];
}
- (void)rightBtnOnClick:(id)sender {
    [self nodeView_RightClick:self.data];
}

//MARK:===============================================================
//MARK:                     < SelfDelegate >
//MARK:===============================================================
-(UIView*) nodeView_GetCustomSubView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetCustomSubView:)]) {
        return [self.delegate nodeView_GetCustomSubView:nodeData];
    }
    return nil;
}
-(UIColor*) nodeView_GetNodeColor:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetNodeColor:)]) {
        return [self.delegate nodeView_GetNodeColor:nodeData];
    }
    return nil;
}
-(void) nodeView_TopClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_TopClick:)]) {
        [self.delegate nodeView_TopClick:nodeData];
    }
}
-(void) nodeView_BottomClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_BottomClick:)]) {
        [self.delegate nodeView_BottomClick:nodeData];
    }
}
-(void) nodeView_LeftClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_LeftClick:)]) {
        [self.delegate nodeView_LeftClick:nodeData];
    }
}
-(void) nodeView_RightClick:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_RightClick:)]) {
        [self.delegate nodeView_RightClick:nodeData];
    }
}

@end
