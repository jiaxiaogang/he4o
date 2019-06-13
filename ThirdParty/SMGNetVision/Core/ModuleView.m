//
//  ModuleView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/6/12.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "ModuleView.h"
#import "MASConstraint.h"
#import "View+MASAdditions.h"
#import "NodeView.h"

@interface ModuleView ()<NodeViewDelegate>

@property (strong,nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong, nonatomic) NSMutableArray *nodeArr;

@end

@implementation ModuleView

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
    [self setBackgroundColor:[UIColor clearColor]];
    
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
    self.nodeArr = [[NSMutableArray alloc] init];
}

-(void) initDisplay{
    
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================
-(void) setDataWithModuleId:(NSString*)moduleId{
    _moduleId = moduleId;
    [self.titleLab setText:STRTOOK(self.moduleId)];
}

-(void) setDataWithNodeData:(id)nodeData{
    if (![self.nodeArr containsObject:nodeData]) {
        [self.nodeArr addObject:nodeData];
        [self refreshDisplayWithNodeData:nodeData];
    }
}

-(void) refreshDisplayWithNodeData:(id)nodeData{
    //1. 显示新节点
    if (nodeData) {
        NodeView *nodeView = [[NodeView alloc] init];
        nodeView.delegate = self;
        [nodeView setDataWithNodeData:nodeData];
        [self addSubview:nodeView];
    }
    
    //2. 节点排版算法,重置计算所有节点坐标;
    [self refreshDisplay_Node];
    
    //3. 重绘关联线
    
    
    
}

/**
 *  MARK:--------------------节点排版算法--------------------
 *  1. 有可能,a组与b组间没抽具象关系;此时只能默认往底部排;
 */
-(void) refreshDisplay_Node{
    //1. 对所有节点数据,逐个纵向打通,来做层级判断;
    NSMutableDictionary *numDic = [NSMutableDictionary new];
    for (id curItem in self.nodeArr) {
        NSArray *abss = ARRTOOK([self moduleView_AbsNodeDatas:curItem]);
        NSArray *cons = ARRTOOK([self moduleView_ConNodeDatas:curItem]);
        
        for (id checkItem in self.nodeArr) {
            if ([abss containsObject:checkItem]) {
                //抽象关系
            }
            if ([cons containsObject:checkItem]) {
                //具象关系
            }
        }
    }
    
    
    
    
}

/**
 *  MARK:--------------------NodeViewDelegate--------------------
 */
-(UIView *)nodeView_GetCustomSubView:(id)nodeData{
    return [self moduleView_GetCustomSubView:nodeData];
}
-(NSString*) nodeView_GetTipsDesc:(id)nodeData{
    return [self moduleView_GetTipsDesc:nodeData];
}
-(void) nodeView_TopClick:(id)nodeData{
    NSArray *absNodeDatas = [self moduleView_AbsNodeDatas:nodeData];
    NSLog(@"%@",absNodeDatas);
}
-(void) nodeView_BottomClick:(id)nodeData{
    NSArray *conNodeDatas = [self moduleView_ConNodeDatas:nodeData];
    NSLog(@"%@",conNodeDatas);
}
-(void) nodeView_LeftClick:(id)nodeData{
    NSArray *contentNodeDatas = [self moduleView_ContentNodeDatas:nodeData];
    NSLog(@"%@",contentNodeDatas);
}
-(void) nodeView_RightClick:(id)nodeData{
    NSArray *refNodeDatas = [self moduleView_RefNodeDatas:nodeData];
    NSLog(@"%@",refNodeDatas);
}

//MARK:===============================================================
//MARK:                     < SelfDelegate >
//MARK:===============================================================
-(UIView *)moduleView_GetCustomSubView:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetCustomSubView:)]) {
        return [self.delegate moduleView_GetCustomSubView:nodeData];
    }
    return nil;
}

-(NSString*)moduleView_GetTipsDesc:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_GetTipsDesc:)]) {
        return [self.delegate moduleView_GetTipsDesc:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_AbsNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_AbsNodeDatas:)]) {
        return [self.delegate moduleView_AbsNodeDatas:nodeData];
    }
    return nil;
}
-(NSArray*)moduleView_ConNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_ConNodeDatas:)]) {
        return [self.delegate moduleView_ConNodeDatas:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_ContentNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_ContentNodeDatas:)]) {
        return [self.delegate moduleView_ContentNodeDatas:nodeData];
    }
    return nil;
}

-(NSArray*)moduleView_RefNodeDatas:(id)nodeData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moduleView_RefNodeDatas:)]) {
        return [self.delegate moduleView_RefNodeDatas:nodeData];
    }
    return nil;
}

@end

