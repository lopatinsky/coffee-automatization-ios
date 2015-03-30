//
//  DBCategoryHeaderView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuCategory;

@interface DBCategoryHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) DBMenuCategory *category;

- (instancetype)initWithMenuCategory:(DBMenuCategory *)category;

@end
