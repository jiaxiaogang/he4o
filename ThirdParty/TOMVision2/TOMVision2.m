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
#import "TOMVisionNodeView.h"

@interface TOMVision2 ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *openCloseBtn;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) NSInteger loopId;     //当前循环Id
@property (strong, nonatomic) NSMutableArray *datas;//所有帧数据 List<TOMVisionItemModel>
@property (strong, nonatomic) UILabel *lab;

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
    [self.containerView insertSubview:self.scrollView belowSubview:self.openCloseBtn];
    [self.scrollView setFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight - 20)];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setContentSize:CGSizeMake(ScreenWidth, ScreenHeight * 2)];
    
    //contentView
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight * 2)];
    
    //lab
    self.lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.contentView addSubview:self.lab];
    [self.lab setTextColor:UIColorWithRGBHex(0x000000)];
    [self.lab setFont:[UIFont systemFontOfSize:8]];
    [self.lab setBackgroundColor:UIColorWithRGBHex(0xEEEEEE)];
    [self.lab setNumberOfLines:0];
    [self.lab setText:@"contentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontentcontent"];
}

-(void) initData{
}

-(void) initDisplay{
    [self close];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setNodeData:(id)nodeData{
    if (nodeData) {
        [self setNodeDatas:@[nodeData]];
    }
}

-(void) setNodeDatas:(NSArray*)nodeDatas{
    //1. 数据准备
    if (!self.isOpen && !self.forceMode) return;
    nodeDatas = ARRTOOK(nodeDatas);
    
    
}
-(void) updateLoopId{
    self.loopId++;
}

-(void) updateFrame{
    //1. 记录快照;
    TOMVisionItemModel *newFrame = [[TOMVisionItemModel alloc] init];
    newFrame.loopId = self.loopId;
    newFrame.data = theTC.outModelManager.getAllDemand;
    [self.datas addObject:newFrame];
    
    //2. 更新UI
    for (DemandModel *demand in newFrame.data) {
        [self.lab setText:STRFORMAT(@"content: %@",CLEANSTR([TOModelVision cur2Sub:demand]))];
    }
    
    //2. 更新UI
    NSArray *nodeViews = [self.contentView subViews_AllDeepWithClass:TOMVisionNodeView.class];
    for (TOMVisionNodeView *nodeView in nodeViews) {
        //3. 每个节点有则更新,无则新建;
        
        
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

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)openCloseBtnOnClick:(id)sender {
    [self close];
}

@end
