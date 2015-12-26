//
//  DBCategoryHeaderView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBCategoryHeaderView;
@class DBMenuCategory;

@interface DBCategoryHeaderView : UIView

@property (strong, nonatomic) DBMenuCategory *category;

- (instancetype)initWithMenuCategory:(DBMenuCategory *)category;

@end
