//
//  MemManagerWindow.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/6/6.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "MemManagerWindow.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "NSFile+Extension.h"
#import "MemManager.h"

@interface MemManagerWindow () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *saveNameTF;
@property (weak, nonatomic) IBOutlet UITableView *readTableView;

@property (strong, nonatomic) NSMutableArray *datas;   //已存的所有历史;

@end

@implementation MemManagerWindow

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
    
    //readTableView
    self.readTableView.delegate = self;
    self.readTableView.dataSource = self;
}

-(void) initData{
    self.datas = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    [self refreshDisplay];
    [self close];
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) open{
    [self setHidden:false];
}

-(void) close{
    [self setHidden:true];
}

-(void) refreshDisplay{
    //1. 重加载数据_加载save下的路径;
    NSString *cachePath = kCachePath;
    NSArray *paths = [NSFile_Extension subFolders:STRFORMAT(@"%@/save",cachePath)];
    
    //2. 按创建时间排序;
    paths = [paths sortedArrayUsingComparator:^NSComparisonResult(NSString *path1, NSString *path2) {
        NSDictionary *info1 = DICTOOK([[NSFileManager defaultManager] attributesOfItemAtPath:path1 error:nil]);
        NSDictionary *info2 = DICTOOK([[NSFileManager defaultManager] attributesOfItemAtPath:path2 error:nil]);
        NSDate *date1 = [info1 objectForKey:NSFileCreationDate];
        NSDate *date2 = [info2 objectForKey:NSFileCreationDate];
        NSTimeInterval time1 = [date1 timeIntervalSince1970];
        NSTimeInterval time2 = [date2 timeIntervalSince1970];
        return (time1 == time2) ? NSOrderedSame : ((time1 < time2) ? NSOrderedAscending : NSOrderedDescending);
    }];
    
    //3. 重加载数据_转为folderName;
    NSArray *foloders = [SMGUtils convertArr:paths convertBlock:^id(NSString *path) {
        NSString *sep = @"/";
        NSString *folderName = STRTOOK(ARR_INDEX_REVERSE(STRTOARR(path, sep), 0));
        return folderName;
    }];
    
    //4. 重加载数据_收集到datas中;
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:foloders];
    
    //5. 重显示;
    [self.readTableView reloadData];
    
    //6. 默认选中最后一个cell;
    if (ARRISOK(self.datas)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSIndexPath *row = [NSIndexPath indexPathForRow:self.datas.count - 1 inSection:0];
            [self.readTableView selectRowAtIndexPath:row animated:true scrollPosition:UITableViewScrollPositionTop];
        });
    }
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)clearMemOnClick:(id)sender {
    DemoLog(@"清空记忆");
    [theApp.heLogView addDemoLog:@"清空记忆"];
    [MemManager removeAllMemory];
}

- (IBAction)saveMemOnClick:(id)sender {
    if (STRISOK(self.saveNameTF.text)) {
        DemoLog(@"保存记忆");
        [MemManager saveAllMemory:self.saveNameTF.text];
        [self refreshDisplay];
    }
}

- (IBAction)readMemOnClick:(id)sender {
    NSIndexPath *selected = [self.readTableView indexPathForSelectedRow];
    NSString *data = ARR_INDEX(self.datas, selected.row);
    if (STRISOK(data)) {
        DemoLog(@"恢复记忆");
        [MemManager readAllMemory:data];
        [self close];
    }
}

- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}

- (IBAction)deleteSaveOnClick:(id)sender {
    NSIndexPath *selected = [self.readTableView indexPathForSelectedRow];
    NSString *data = ARR_INDEX(self.datas, selected.row);
    if (STRISOK(data)) {
        DemoLog(@"删除记忆:%@",data);
        NSString *cachePath = kCachePath;
        [[NSFileManager defaultManager] removeItemAtPath:STRFORMAT(@"%@/save/%@",cachePath,data) error:nil];
        [self refreshDisplay];
    }
}

//MARK:===============================================================
//MARK:       < UITableViewDataSource &  UITableViewDelegate>
//MARK:===============================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSString *data = STRTOOK(ARR_INDEX(self.datas, indexPath.row));
    [cell.textLabel setText:data];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

@end
