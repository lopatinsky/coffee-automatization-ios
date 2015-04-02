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

typedef NS_ENUM(NSUInteger, DBCategoryHeaderViewState) {
    DBCategoryHeaderViewStateCompact = 0,
    DBCategoryHeaderViewStateFull
};

@protocol DBCatecoryHeaderViewDelegate <NSObject>
- (void) db_categoryHeaderViewDidSelect:(DBCategoryHeaderView *)headerView;
- (void) db_categoryHeaderViewDidSelectCategoryChoice:(DBCategoryHeaderView *)headerView;
@end

@interface DBCategoryHeaderView : UIView
@property (nonatomic, readonly) CGFloat viewHeight;
@property (nonatomic, readonly) DBCategoryHeaderViewState state;

@property (strong, nonatomic) DBMenuCategory *category;
@property (strong, nonatomic) id<DBCatecoryHeaderViewDelegate> delegate;

- (instancetype)initWithMenuCategory:(DBMenuCategory *)category state:(DBCategoryHeaderViewState)state;

- (void)changeState:(DBCategoryHeaderViewState)state animated:(BOOL)animated;
- (void)showAccessoryView:(BOOL)animated;
- (void)hideAccessoryView:(BOOL)animated;

@end
