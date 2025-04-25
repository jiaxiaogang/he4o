//
//  ImgTrainerView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/25.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "ImgTrainerView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "PINDiskCache.h"
#import "TVUtil.h"
#import "XGLabCell.h"
#import "ImgTrainerItemModel.h"

@interface ImgTrainerView () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIImageView *curImgView;
@property (strong, nonatomic) NSMutableArray *tvDatas;
@property (assign, nonatomic) NSInteger curSelectRow;

@end

@implementation ImgTrainerView

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
    [self setAlpha:0.7f];
    CGFloat width = 550;//ScreenWidth * 0.667f;
    [self setFrame:CGRectMake(ScreenWidth - width - 20, 64, width, ScreenHeight - 128)];
    
    //containerView
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    [self.containerView.layer setCornerRadius:8.0f];
    [self.containerView.layer setBorderWidth:1.0f];
    [self.containerView.layer setBorderColor:UIColorWithRGBHex(0x000000).CGColor];
    
    //tv
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv.layer setBorderWidth:1.0f];
    [self.tv.layer setBorderColor:UIColorWithRGBHex(0x0000FF).CGColor];
    [self.tv setContentInset:UIEdgeInsetsMake(0, -10, 0, -10)];
}

-(void) initData{
    self.tvDatas = [NSMutableArray new];

    // Read words.txt file
    NSString *cachePath = kCachePath;
    NSString *wordsPath = STRFORMAT(@"%@/assets/TinyImageNetImages/words.txt", cachePath);
    NSString *wordsContent = [NSString stringWithContentsOfFile:wordsPath encoding:NSUTF8StringEncoding error:nil];
    
    // Split into lines and get first line
    NSArray *wordsLines = [wordsContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableDictionary *wordsDic = [NSMutableDictionary new];
    for (NSString *line in wordsLines) {
        
        // Find first tab position in line
        NSRange tabRange = [line rangeOfString:@"\t"];
        if (tabRange.location == NSNotFound) {
            continue;
        }

        // Extract key and value from line using tab position
        NSString *key = [line substringToIndex:tabRange.location];
        NSString *value = [line substringFromIndex:tabRange.location + 1];
        wordsDic[key] = value;
    }
    //NSLog(@"读到物品名字典%ld条",wordsDic.count);
    
    // Read wnids.txt file
    NSString *filePath = STRFORMAT(@"%@/assets/TinyImageNetImages/wnids.txt", cachePath);
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // Split into lines and create array
    NSArray *imgIds = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // Collect for every one
    for (NSString *imgId in imgIds) {
        NSString *imgName = [wordsDic objectForKey:imgId];
        if (!imgId || !imgName) continue;
        [self.tvDatas addObject:[ImgTrainerItemModel new:imgId imgName:imgName]];
    }
    //NSLog(@"读到物品类别数%ld条",self.tvDatas.count);
}

-(void) initDisplay{
    [self close];
}

-(void) refreshDisplay{
    //5. 重显示;
    [self.tv reloadData];
    if (self.curSelectRow < self.tvDatas.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.curSelectRow inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
        });
    }
}

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================
-(void) reloadData{
    [self refreshDisplay];
}
-(void) open{
    [self setHidden:false];
}
-(void) close{
    [self setHidden:true];
}

//MARK:===============================================================
//MARK:                     < onclick >
//MARK:===============================================================
- (IBAction)playBtnOnClick:(id)sender {
    //NSIndexPath *selected = [self.tv indexPathForSelectedRow];
    ImgTrainerItemModel *model = ARR_INDEX(self.tvDatas, self.curSelectRow);
    if (model) {
        //1. 取图
        NSString *cachePath = kCachePath;
        NSString *readPath = STRFORMAT(@"%@/assets/TinyImageNetImages/train/%@/images",cachePath,model.imgId);
        NSString *fileName = STRFORMAT(@"%@_%ld.JPEG",model.imgId,model.imgIndex);
        NSString *fullPath = [readPath stringByAppendingPathComponent:fileName];
        UIImage *img = [UIImage imageWithContentsOfFile:fullPath];
        
        //2. 提交视觉
        [AIVisionAlgsV2 commitInput:img logDesc:STRFORMAT(@"%@_%ld",model.imgName,model.imgIndex)];
        
        //3. 预览图
        [self.curImgView setImage:img];
        
        //4. 下一张
        model.imgIndex++;
        [self refreshDisplay];
    }
}

- (IBAction)closeBtnOnClick:(id)sender {
    [self close];
}


//MARK:===============================================================
//MARK:       < UITableViewDataSource &  UITableViewDelegate>
//MARK:===============================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tvDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    ImgTrainerItemModel *model = ARR_INDEX(self.tvDatas, indexPath.row);
    NSString *curIndexing = (model.imgIndex==0) ? @"" : STRFORMAT(@"%ld",model.imgIndex - 1);//当前正在处理中的图
    [cell.textLabel setText:STRFORMAT(@"%ld. %@ %@ %@",indexPath.row+1,model.imgId,model.imgName,curIndexing)];
    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.curSelectRow = indexPath.row;
}

@end
