//
//  Input.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/9.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Input.h"
#import "InputHeader.h"
#import "SMGHeader.h"
#import "FeelHeader.h"

@implementation Input


-(void) seeWorld{
    //1,收集摄像头图片
    //2,收集麦克风声音
    //3,收集用户输入的文字
    InputModel *inputModel = [[InputModel alloc] init];
    inputModel.text = @"";
    inputModel.img = [UIImage imageNamed:@""];
    inputModel.audio = nil;
    //4,提交给Feel
    [[SMG sharedInstance].feel commitInputModel:inputModel];
}



@end
