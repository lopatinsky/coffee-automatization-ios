//
//  DBMastercardAdView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMastercardAdView;

@protocol DBMasterCardAdViewDelegate <NSObject>
@optional
- (void)db_mastercardAdvertViewPlusClick:(DBMastercardAdView *)view;
- (void)db_mastercardAdvertViewClick:(DBMastercardAdView *)view;
@end

@interface DBMastercardAdView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *mastercardIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *plusImageView;
@property (weak, nonatomic) IBOutlet UILabel *advertMessageLabel;

@property (weak, nonatomic) id<DBMasterCardAdViewDelegate> advertDelegate;
@property (strong, nonatomic) NSString *screen;

- (instancetype)initWithDelegate:(id<DBMasterCardAdViewDelegate>)delegate onScreen:(NSString *)screen;

@end
