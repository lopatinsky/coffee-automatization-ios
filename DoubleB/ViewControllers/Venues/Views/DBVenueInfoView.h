//
//  DBVenueInfoView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Venue;
@class DBVenueInfoView;

@protocol DBVenueInfoViewDelegate <NSObject>

- (void)db_venueViewInfo:(DBVenueInfoView *)view clickedVenue:(Venue *)venue;
- (void)db_venueViewInfo:(DBVenueInfoView *)view didSelectVenue:(Venue *)venue;

@end

@interface DBVenueInfoView : UIView
@property (nonatomic) BOOL selectionEnabled;
@property (strong, nonatomic) Venue *venue;
@property (weak, nonatomic) id<DBVenueInfoViewDelegate> delegate;

@property (nonatomic, readonly) BOOL visible;

+ (DBVenueInfoView *)create;
- (void)configure:(Venue *)venue;

- (void)show:(UIView *)holder;
- (void)hide;

@end
