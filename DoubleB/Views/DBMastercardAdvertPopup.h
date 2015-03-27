//
//  DBMastercardAdvertPopup.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DBMastercardAdvertPopup : UIView
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UIView *progressContentView;
@property (weak, nonatomic) IBOutlet UILabel *accumulatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *mugCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mugImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

- (instancetype)initWithCurrentProgress:(NSInteger)count
                               maxCount:(NSInteger)maxCount
                      completionHandler:(void (^)())handler;

- (instancetype)initWithCurrentProgress:(NSInteger)count
                               maxCount:(NSInteger)maxCount
                    accumulatedMugCount:(NSInteger)mugCount
                      completionHandler:(void (^)())handler;

@end
