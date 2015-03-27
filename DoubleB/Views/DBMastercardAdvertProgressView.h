//
//  DBMastercardAdvertProgressView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMastercardAdvertProgressView;

@protocol DBMasterCardAdvertProgressViewDelegate <NSObject>
@optional
- (void)db_mastercardAdvertProgressViewClick:(DBMastercardAdvertProgressView *)view;
@end

@interface DBMastercardAdvertProgressView : UIView
@property (weak, nonatomic) IBOutlet UIView *progressContentView;
@property (weak, nonatomic) IBOutlet UIImageView *mugImageView;

@property (weak, nonatomic) id<DBMasterCardAdvertProgressViewDelegate> advertDelegate;

- (instancetype)initWithDelegate:(id<DBMasterCardAdvertProgressViewDelegate>)delegate;
- (void)updateData;

@end
