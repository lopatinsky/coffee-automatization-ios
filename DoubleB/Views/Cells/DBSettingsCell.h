//
//  DBSettingsCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBSettingsCell;

@protocol DBSettingsCellDelegate <NSObject>
- (void)db_settingsCell:(DBSettingsCell *)cell didChangeSwitchValue:(BOOL)switchValue;
@end

@interface DBSettingsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *settingsImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;

@property (weak, nonatomic) id<DBSettingsCellDelegate> delegate;
@property (nonatomic) BOOL hasIcon;
@property (nonatomic) BOOL hasSwitch;
@end
