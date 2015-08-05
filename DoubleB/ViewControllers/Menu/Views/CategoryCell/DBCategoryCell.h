//
//  IHCategoryTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuCategory;

@interface DBCategoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *categoryIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicator;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic, readonly) DBMenuCategory *category;

- (void)configureWithCategory:(DBMenuCategory *)category;

@end
