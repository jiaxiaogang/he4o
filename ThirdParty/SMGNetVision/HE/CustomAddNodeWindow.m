//
//  CustomAddNodeWindow.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/7/1.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "CustomAddNodeWindow.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface CustomAddNodeWindow ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *moduleSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;
@property (weak, nonatomic) IBOutlet UITextField *pointerIdTF;

@end

@implementation CustomAddNodeWindow

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
    [self setFrame:CGRectMake((ScreenWidth - 300) / 2.0f, (ScreenHeight - 275) / 2.0f,300, 275)];
    
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
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)commitBtnOnClick:(id)sender {
    NSLog(@"-----------------");
    //1. 抽具象;
    BOOL isAbs = self.typeSegment.selectedSegmentIndex == 0;
    
    //2. folderName
    NSString *folderName = nil;
    if (self.moduleSegment.selectedSegmentIndex == 0) {
        folderName = kPN_VALUE;
    }if (self.moduleSegment.selectedSegmentIndex == 1) {
        folderName = isAbs ? kPN_ALG_ABS_NODE : kPN_ALG_NODE;
    }if (self.moduleSegment.selectedSegmentIndex == 2) {
        folderName = isAbs ? kPN_FO_ABS_NODE : kPN_FRONT_ORDER_NODE;
    }if (self.moduleSegment.selectedSegmentIndex == 3) {
        folderName = isAbs ? kPN_ABS_CMV_NODE : kPN_CMV_NODE;
    }
    
    //3. pointerId
    NSInteger pointerId = [STRTOOK(self.pointerIdTF.text) integerValue];
    
    NSLog(@"追加节点: %@,%ld",folderName,(long)pointerId);
    NSLog(@"-----------------");
    
    //4. 提交到网络
    //[theApp.nvView setNodeData:nil];
}

@end

