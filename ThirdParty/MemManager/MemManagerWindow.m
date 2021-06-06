//
//  MemManagerWindow.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/6.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "MemManagerWindow.h"

@interface MemManagerWindow () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *saveNameTF;
@property (weak, nonatomic) IBOutlet UITableView *readTableView;

@end

@implementation MemManagerWindow

- (IBAction)clearMemOnClick:(id)sender {
}

- (IBAction)saveMemOnClick:(id)sender {
}

- (IBAction)readMemOnClick:(id)sender {
}

@end
