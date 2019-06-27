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

@interface NVNodeView ()

@property (strong,nonatomic) IBOutlet UIControl *containerView;
@property (strong, nonatomic) UIView *customSubView;
@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

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
    [self setFrame:CGRectMake(0, 0, 15, 15)];
    [self.layer setMasksToBounds:true];
    [self.layer setCornerRadius:7.5f];
    [self.layer setBorderColor:UIColorWithRGBHex(0xAAAAAA).CGColor];
    [self.layer setBorderWidth:1];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    //btn
    NSArray *btns = @[self.topBtn,self.bottomBtn,self.leftBtn,self.rightBtn];
    for (UIButton *btn in btns) {
        [btn.layer setCornerRadius:5.5f];
        [btn.layer setBorderWidth:1.0f / UIScreen.mainScreen.scale];
        [btn.layer setBorderColor:[UIColor grayColor].CGColor];
    }
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
        [self.containerView setBackgroundColor:nodeColor];
    }
}

//MARK:===============================================================
//MARK:                     < onClick >
//MARK:===============================================================
- (IBAction)contentViewTouchDown:(id)sender {
    NSString *desc = [self nodeView_GetTipsDesc:self.data];
    TPLog(@"> %@", desc);
}
- (IBAction)contentViewTouchCancel:(id)sender {
    TPLog(@"松开");
}
- (IBAction)topBtnOnClick:(id)sender {
    [self nodeView_TopClick:self.data];
    TPLog(@"absPorts");
}
- (IBAction)bottomBtnOnClick:(id)sender {
    [self nodeView_BottomClick:self.data];
    TPLog(@"conPorts");
}
- (IBAction)leftBtnOnClick:(id)sender {
    [self nodeView_LeftClick:self.data];
    TPLog(@"content");
}
- (IBAction)rightBtnOnClick:(id)sender {
    [self nodeView_RightClick:self.data];
    TPLog(@"refPorts");
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
-(NSString*) nodeView_GetTipsDesc:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetTipsDesc:)]) {
        return [self.delegate nodeView_GetTipsDesc:nodeData];
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

