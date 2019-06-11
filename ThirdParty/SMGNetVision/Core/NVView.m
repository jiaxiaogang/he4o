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

@interface NVView () <NodeViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSMutableArray *nodeArr;
@property (assign, nonatomic) BOOL isOpen;
@property (weak, nonatomic) IBOutlet UIButton *openCloseBtn;

@end

@implementation NVView

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
    [self setBackgroundColor:[UIColor grayColor]];
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
}

-(void) initData{
    self.nodeArr = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setData:(NSArray*)arr{
    [self.nodeArr removeAllObjects];
    if (ARRISOK(arr)) {
        [self.nodeArr addObjectsFromArray:arr];
    }
    [self refreshDisplay];
}

-(void) refreshDisplay{
    //1. 显示所有node
    for (id nodeData in self.nodeArr) {
        NodeView *nodeView = [[NodeView alloc] init];
        nodeView.delegate = self;
        [nodeView setDataWithNodeData:nodeData];
        [self.contentView addSubview:nodeView];
    }
    
    //2. 显示所有line
    
    //3. 排版,重置计算所有坐标;
}

/**
 *  MARK:--------------------NodeViewDelegate--------------------
 */
-(UIView *)nodeView_GetCustomSubView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetCustomNodeView:)]) {
        return [self.delegate nv_GetCustomNodeView:nodeData];
    }
    return nil;
}

-(NSString*) nodeView_GetDesc:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nv_GetNodeDesc:)]) {
        return [self.delegate nv_GetNodeDesc:nodeData];
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

@end

