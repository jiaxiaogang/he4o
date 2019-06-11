//
//  NodeView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/11.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NodeView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface NodeView ()

@property (strong,nonatomic) IBOutlet UIControl *containerView;
@property (strong, nonatomic) id data;//一般为一个指针

@end

@implementation NodeView

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
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setDataWithNodeData:(id)nodeData{
    self.data = nodeData;
    [self refreshDisplay];
}

-(void) refreshDisplay{
    //1. 移除旧的subView
    [self.containerView removeAllSubviews];
    
    //2. 优先取自定义subView
    UIView *subView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetCustomSubView:)]) {
        subView = [self.delegate nodeView_GetCustomSubView:self.data];
    }
    
    //3. 再取默认subView
    if (!subView) {
        subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [subView setBackgroundColor:[UIColor redColor]];
    }
    
    //4. 显示
    [self.containerView addSubview:subView];
}

- (IBAction)contentViewTouchDown:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nodeView_GetDesc:)]) {
        NSString *desc = [self.delegate nodeView_GetDesc:self.data];
        NSLog(@"按下:%@",desc);
    }
}
- (IBAction)contentViewTouchCancel:(id)sender {
    NSLog(@"松开");
}

@end

