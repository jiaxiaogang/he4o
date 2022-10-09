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
#import "AIKVPointer.h"
#import "ImvAlgsHungerModel.h"
#import "ImvAlgsHurtModel.h"

@interface CustomAddNodeWindow ()

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *moduleSegment;
@property (weak, nonatomic) IBOutlet UITextField *pointerIdTF;
@property (weak, nonatomic) IBOutlet UITextField *algsTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *dataSourceTF;

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
    float height = 380;
    [self setFrame:CGRectMake((ScreenWidth - 300) / 2.0f, (ScreenHeight - height) / 2.0f,300, height)];
    
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
    //2. folderName
    NSArray *folderNames = nil;
    if (self.moduleSegment.selectedSegmentIndex == 0) {
        folderNames = @[kPN_VALUE];
    }else if (self.moduleSegment.selectedSegmentIndex == 1) {
        folderNames = @[kPN_ALG_ABS_NODE,kPN_ALG_NODE];
    }else if (self.moduleSegment.selectedSegmentIndex == 2) {
        folderNames = @[kPN_FO_ABS_NODE,kPN_FRONT_ORDER_NODE];
    }else if (self.moduleSegment.selectedSegmentIndex == 3) {
        folderNames = @[kPN_ABS_CMV_NODE,kPN_CMV_NODE];
    }
    
    //3. pointerId
    NSInteger pointerId = [STRTOOK(self.pointerIdTF.text) integerValue];
    
    //6. algsType
    NSArray *ats = nil;
    if (STRISOK(self.algsTypeTF.text)) {
        ats = @[self.algsTypeTF.text];
    }else if (self.moduleSegment.selectedSegmentIndex == 3) {
        ats = @[@"ImvAlgsHungerModel",@"ImvAlgsHurtModel"];
    }else {
        ats = @[DefaultAlgsType];
    }
    
    //7. dataSource
    NSString *dataSource = STRISOK(self.dataSourceTF.text) ? self.dataSourceTF.text : DefaultDataSource;
    
    //8. 提交到网络
    for (NSNumber *isOut in @[@(true),@(false)]) {
        for (NSString *fn in folderNames) {
            for (NSString *at in ats) {
                AIKVPointer *node_p = [AIKVPointer newWithPointerId:pointerId
                                                         folderName:fn
                                                           algsType:at
                                                         dataSource:dataSource
                                                              isOut:isOut.boolValue
                                                               type:ATDefault];
                
                //9. 验证是否存在;
                BOOL isValid = false;
                if (PitIsValue(node_p)) {
                    isValid = NUMISOK([AINetIndex getData:node_p]);//稀疏码读value类型
                }else{
                    isValid = [SMGUtils searchNode:node_p];//读node类型
                }
                
                //11. 追加到网;
                if (isValid) {
                    [theNV setNodeData:node_p];
                    TPLog(@"追加节点:%@",Pit2FStr(node_p));
                }
            }
        }
    }
    
    //9. 关闭窗口
    [self removeFromSuperview];
}

- (IBAction)closeBtnOnClick:(id)sender {
    [self removeFromSuperview];
}

@end

