//
//  LongTipWindow.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/8/12.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "LongTipWindow.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "AIKVPointer.h"
#import "AINetUtils.h"

@interface LongTipWindow ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong, nonatomic) AIKVPointer *data;
@property (assign, nonatomic) DirectionType type;

@end

@implementation LongTipWindow

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
    }
    return self;
}

-(void) initView{
    //self
    [self setFrame:CGRectMake(0, 0,ScreenWidth, ScreenHeight)];
    
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

//MARK:===============================================================
//MARK:                     < publieMethod >
//MARK:===============================================================
-(void) close{
    [self removeFromSuperview];
}
-(void) setData:(NSString*)moduleTitle data:(AIKVPointer*)data direction:(DirectionType)type{
    //1. 保留数据
    self.data = data;
    self.type = type;
    
    //2. 重置显示
    NSString *directionStr = @"";
    if (type == DirectionType_Top) {
        directionStr = @"上";
    }else if (type == DirectionType_Bottom) {
        directionStr = @"下";
    }else if (type == DirectionType_Left) {
        directionStr = @"左";
    }else if (type == DirectionType_Right) {
        directionStr = @"右";
    }
    [self.titleLab setText:STRFORMAT(@"%@%ld (%@)",moduleTitle,data.pointerId,directionStr)];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)normalClick:(UIButton*)sender {
    [self generalClick:sender filter:^NSArray *(NSArray *ports) {
        return [SMGUtils filterPorts_Normal:ports];
    }];
}
- (IBAction)hnClick:(UIButton*)sender {
    [self generalClick:sender filter:^NSArray *(NSArray *ports) {
        return [SMGUtils filterPorts:ports havTypes:@[@(ATHav),@(ATNone)] noTypes:nil];
    }];
}
- (IBAction)glClick:(UIButton*)sender {
    [self generalClick:sender filter:^NSArray *(NSArray *ports) {
        return [SMGUtils filterPorts:ports havTypes:@[@(ATGreater),@(ATLess)] noTypes:nil];
    }];
}
- (IBAction)spClick:(UIButton*)sender {
    [self generalClick:sender filter:^NSArray *(NSArray *ports) {
        return [SMGUtils filterPorts:ports havTypes:@[@(ATSub),@(ATPlus)] noTypes:nil];
    }];
}
- (IBAction)dsdfClick:(UIButton*)sender {
    NSLog(@"%@",sender.titleLabel.text);
    //目前仅top方向的fo支持dsPorts;
    if (PitIsFo(self.data) && self.type == DirectionType_Top) {
        AIFoNodeBase *node = [SMGUtils searchNode:self.data];
        NSArray *dsPorts = @[];
        [theNV setNodeDatas:Ports2Pits(dsPorts)];
    }
    [self close];
}
- (IBAction)recallClick:(UIButton*)sender {
    NSLog(@"%@",sender.titleLabel.text);
    NSArray *removeDatas = [self generalGetDatas:^NSArray *(NSArray *ports) {
        return ports;
    }];
    [theNV removeNodeDatas:removeDatas];
    [self close];
}
- (IBAction)closeClick:(id)sender {
    [self close];
}

-(void)generalClick:(UIButton*)sender filter:(NSArray*(^)(NSArray *ports))filter{
    //1. 数据准备;
    NSLog(@"%@",sender.titleLabel.text);
    
    //2. 取新增节点;
    NSArray *addDatas = [self generalGetDatas:filter];
    
    //3. 显示到网络可视化;
    [theNV setNodeDatas:addDatas];
    
    //4. 关闭
    [self close];
}

-(NSArray*)generalGetDatas:(NSArray*(^)(NSArray *ports))filter{
    //1. 数据准备;
    AINodeBase *node = [SMGUtils searchNode:self.data];
    NSArray *result = nil;
    
    //2. 取新增节点;
    if (self.type == DirectionType_Top) {
        result = Ports2Pits(filter([AINetUtils absPorts_All:node]));
    }else if (self.type == DirectionType_Bottom) {
        result = Ports2Pits(filter([AINetUtils conPorts_All:node]));
    }else if (self.type == DirectionType_Left) {
        result = node.content_ps;
    }else if (self.type == DirectionType_Right) {
        result = Ports2Pits(filter([AINetUtils refPorts_All:self.data]));
    }
    return result;
}

@end

