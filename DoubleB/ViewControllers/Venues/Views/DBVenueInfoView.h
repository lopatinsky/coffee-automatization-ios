//
//  DBVenueInfoView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Venue;
@interface DBVenueInfoView : UIView
@property (nonatomic) BOOL choiceEnabled;
@property (strong, nonatomic) Venue *venue;

@property (nonatomic, readonly) BOOL visible;

+ (DBVenueInfoView *)create;
- (void)configure:(Venue *)venue;

- (void)show:(UIView *)holder;
- (void)hide;

@end
