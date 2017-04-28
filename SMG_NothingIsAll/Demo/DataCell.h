//
//  DataCell.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/28.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMGHeader.h"

@interface DataCell : UITableViewCell

+ (CGFloat) getCellHeight;
+ (NSString*)reuseIdentifier;
-(void) setData:(NSDictionary*)dic withStoreType:(StoreType)storeType;

@end
