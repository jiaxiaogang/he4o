//
//  FoodView.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/11/9.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "FoodView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"

@interface FoodView ()

@property (strong,nonatomic) IBOutlet UIView *containerView;

@end

@implementation FoodView

-(void) initView{
    [super initView];
    //self
    [self setFrame:CGRectMake(0, 50, 5, 5)];
    [self.layer setBorderColor:[UIColor grayColor].CGColor];
    [self setBackgroundColor:[UIColor greenColor]];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    //imgView
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(-5.5f, -35, 15, 15)];
    [self addSubview:self.imgView];
    [self.imgView setAlpha:0.3f];
    [self sendSubviewToBack:self.imgView];
}

static int cSUBNUM = 0;

-(void) initData{
    [super initData];
    self.status = FoodStatus_Border;
    
    //2025.04.05: 依次直投从0_1到0_17号坚果，然后在此过程中观察特征识别类比抽象及累计SP过程（参考34112）。
    int num = 1;//arc4random() % 2;//给吃0到1号坚果
    int subNum = (cSUBNUM++ % 17) + 1;//(arc4random() % 17) + 1;
    self.imgName = STRFORMAT(@"%d_%d",num,subNum);
}

-(void) initDisplay{
    [super initDisplay];
    [self refreshDisplay];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) refreshDisplay{
    if (self.status == FoodStatus_Border) {
        [self.layer setBorderWidth:1];
    }else if(self.status == FoodStatus_Eat){
        [self.layer setBorderWidth:0];
    }else if(self.status == FoodStatus_Remove){
        [self removeFromSuperview];
    }
    
    [self.imgView setImage:[AIVisionAlgsV2 createImageFromProtoMnistImageWithName:self.imgName forTest:false]];
}

-(void) hit{
    self.status ++;
    [self refreshDisplay];
}

-(void)setStatus:(FoodStatus)status {
    _status = status;
    [self refreshDisplay];
}

/**
 *  MARK:--------------------可吃--------------------
 *  @version
 *      2025.04.02: 只有x号坚果可吃（参考34111-测试点3）。
 */
-(BOOL) canEat {
    BOOL canEat4Num = [@"0" isEqualToString:[self.imgName substringToIndex:1]];
    BOOL canEat4Status = self.status == FoodStatus_Eat;
    return canEat4Status && canEat4Num;
}

@end

