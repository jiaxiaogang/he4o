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
    //1. 数据准备;
    NSLog(@"%@",sender.titleLabel.text);
    AINodeBase *node = [SMGUtils searchNode:self.data];
    NSArray *addDatas = nil;
    
    //2. 取新增节点;
    if (self.type == DirectionType_Top) {
        addDatas = Ports2Pits([SMGUtils filterPorts_Normal:[AINetUtils absPorts_All:node]]);
    }else if (self.type == DirectionType_Bottom) {
        addDatas = Ports2Pits([SMGUtils filterPorts_Normal:[AINetUtils conPorts_All:node]]);
    }else if (self.type == DirectionType_Left) {
        addDatas = node.content_ps;
    }else if (self.type == DirectionType_Bottom) {
        addDatas = Ports2Pits([SMGUtils filterPorts_Normal:[AINetUtils refPorts_All:self.data]]);
    }
    
    //3. 显示到网络可视化;
    [theNV setNodeDatas:addDatas];
    
    //4. 关闭
    [self close];
}
- (IBAction)hnClick:(UIButton*)sender {
    NSLog(@"%@",sender.titleLabel.text);
    [self close];
}
- (IBAction)glClick:(UIButton*)sender {
    NSLog(@"%@",sender.titleLabel.text);
    [self close];
}
- (IBAction)spClick:(UIButton*)sender {
    NSLog(@"%@",sender.titleLabel.text);
    [self close];
}
- (IBAction)dsdfClick:(UIButton*)sender {
    NSLog(@"%@",sender.titleLabel.text);
    [self close];
}
- (IBAction)recallClick:(UIButton*)sender {
    NSLog(@"%@",sender.titleLabel.text);
    [self close];
}
- (IBAction)closeClick:(id)sender {
    [self close];
}

@end

