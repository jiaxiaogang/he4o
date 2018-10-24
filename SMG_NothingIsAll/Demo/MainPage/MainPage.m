//
//  MainPage.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/24.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "MainPage.h"
#import "TestHungryPage.h"
#import "RavenTotemPage.h"

@implementation MainPage

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)testHungryOnClick:(id)sender {
    TestHungryPage *page = [[TestHungryPage alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

- (IBAction)ravenTotemOnClick:(id)sender {
    RavenTotemPage *page = [[RavenTotemPage alloc] init];
    [self.navigationController pushViewController:page animated:true];
}

@end
