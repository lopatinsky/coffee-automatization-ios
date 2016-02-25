//
//  DBSettingsCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBSettingsCell;

@interface DBSettingsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *settingsImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) BOOL hasIcon;
@end
