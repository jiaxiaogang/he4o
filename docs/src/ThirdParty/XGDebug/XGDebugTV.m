//
//  XGDebugTV.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/4/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "XGDebugTV.h"
#import "XGDebugModel.h"
#import "XGLabCell.h"

@interface XGDebugTV () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *models;       //刷新显示时的models;
@property (assign, nonatomic) NSTimeInterval modelsSumTime; //刷新显示时的总耗时;
@property (assign, nonatomic) NSTimeInterval modelsOnceTime;//models的平均时间之和;

@end

@implementation XGDebugTV

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil){
        [self initView];
        [self initData];
    }
    return self;
}

-(void) initView{
    self.delegate = self;
    self.dataSource = self;
    [self registerClass:[XGLabCell class] forCellReuseIdentifier:@"debugCell"];
}

-(void) initData{
    self.models = [[NSMutableArray alloc] init];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) updateModels{
    //1. 数据准备;
    [self.models removeAllObjects];
    self.modelsSumTime = 0;
    self.modelsOnceTime = 0;
    
    //2. 更新数据;
    [self.models addObjectsFromArray:theDebug.models];
    for (XGDebugModel *model in self.models) {
        self.modelsSumTime += model.sumTime;
        self.modelsOnceTime += model.sumTime / model.sumCount;
    }
    
    //3. 刷新显示;
    [self reloadData];
}

//MARK:===============================================================
//MARK:       < UITableViewDataSource &  UITableViewDelegate>
//MARK:===============================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.models.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //1. 数据准备;
    XGDebugModel *model = ARR_INDEX(self.models, indexPath.row);
    NSTimeInterval onceTime = model.sumTime / model.sumCount;
    double onceRate = onceTime / self.modelsOnceTime * 100;
    NSInteger onceR = model.sumReadCount / model.sumCount;
    NSInteger onceW = model.sumWriteCount / model.sumCount;
    NSTimeInterval sumTime = model.sumTime / 1000;
    double sumRate = model.sumTime / self.modelsSumTime * 100;
    NSString *cellStr = STRFORMAT(@"%@ 次:%ld x 均耗:%.0f (%.0f％ 读:%ld 写:%ld) = 总耗:%.1f (%.0f％)",model.key,model.sumCount,onceTime,onceRate,onceR,onceW,sumTime,sumRate);
    
    //2. 创建cell;
    XGLabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"debugCell"];
    [cell setText:STRFORMAT(@"%ld. %@",indexPath.row+1, cellStr) color:nil font:6];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 10;
}

@end
