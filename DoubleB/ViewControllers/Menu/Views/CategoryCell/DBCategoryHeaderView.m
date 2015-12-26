//
//  DBCategoryHeaderView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCategoryHeaderView.h"
#import "DBMenuCategory.h"

@interface DBCategoryHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@end

@implementation DBCategoryHeaderView

- (instancetype)initWithMenuCategory:(DBMenuCategory *)category {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryHeaderView" owner:self options:nil] firstObject];
    
    self.category = category;
    
    [self commonInit];
    
    return self;
}

- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.categoryTitleLabel.textColor = [UIColor blackColor];
    self.categoryTitleLabel.text = self.category.name;
}

@end
