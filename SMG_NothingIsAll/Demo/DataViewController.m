//
//  DataViewController.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/28.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "DataViewController.h"
#import "DataCell.h"
#import "SMGHeader.h"



@interface DataViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *datas;
@property (assign, nonatomic) StoreType curStoreType;

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initDisplay];
}

-(void) initView{
    UINib *nib = [UINib nibWithNibName:[DataCell reuseIdentifier] bundle: nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:[DataCell reuseIdentifier]];
}

-(void) initData{
    self.datas = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


/**
 *  MARK:--------------------UITableViewDelegate,UITableViewDataSource--------------------
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataCell *cell = [tableView dequeueReusableCellWithIdentifier:[DataCell reuseIdentifier]];
    if (indexPath.row >= 0 && indexPath.row < self.datas.count) {
        [cell setData:self.datas[indexPath.row] withStoreType:self.curStoreType];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [DataCell getCellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 *  MARK:--------------------onclick--------------------
 */
- (IBAction)memoryBtnOnClick:(id)sender {
    NSMutableArray *arr = [[SMG sharedInstance].store.memStore getMemoryWithWhereDic:nil];
    [self setDatas:arr withStoreType:StoreType_Mem];
}

- (IBAction)doBtnOnClick:(id)sender {
    [self setDatas:nil withStoreType:StoreType_Do];
}

- (IBAction)objBtnOnClick:(id)sender {
    [self setDatas:nil withStoreType:StoreType_Obj];
}

- (IBAction)textBtnOnClick:(id)sender {
    [self setDatas:nil withStoreType:StoreType_Text];
}

- (IBAction)logicBtnOnClick:(id)sender {
    [self setDatas:nil withStoreType:StoreType_Logic];
}

/**
 *  MARK:--------------------method--------------------
 */
-(void) setDatas:(NSArray*)arr withStoreType:(StoreType)storeType{
    self.curStoreType = storeType;
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:ARRTOOK(arr)];
    [self.tableView reloadData];
}











@end
