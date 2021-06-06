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
    
    //2. 重加载数据_转为folderName;
    NSArray *foloders = [SMGUtils convertArr:paths convertBlock:^id(NSString *path) {
        NSString *sep = @"/";
        NSString *folderName = STRTOOK(ARR_INDEX_REVERSE(STRTOARR(path, sep), 0));
        return folderName;
    }];
    
    //3. 重加载数据_收集到datas中;
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:foloders];
    
    //4. 重显示;
    [self.readTableView reloadData];
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
    }
}

- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}

- (IBAction)deleteSaveOnClick:(id)sender {
    NSIndexPath *selected = [self.readTableView indexPathForSelectedRow];
    NSString *data = ARR_INDEX(self.datas, selected.row);
    if (STRISOK(data)) {
        DemoLog(@"删除记忆");
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
