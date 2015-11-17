//
//  RatingBarView.h
//  IIkoHackathon
//
//  Created by Ivan Oschepkov on 07.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RatingBarView;

@protocol RatingBarViewDelegate
- (void)rateView:(RatingBarView *)rateView ratingDidChange:(float)rating;
@end

@interface RatingBarView : UIView

@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;
@property (nonatomic) float rating;
@property (nonatomic) BOOL editable;
@property (nonatomic,strong) NSMutableArray * imageViews;
@property (nonatomic) int maxRating;
@property (nonatomic) int midMargin;
@property (nonatomic) int leftMargin;
@property (nonatomic) CGSize minImageSize;
@property (nonatomic) id <RatingBarViewDelegate> delegate;

@end
