//
//  DBDiscountAdvertView.h
//  DoubleB
//
//  Created by Ощепков Иван on 02.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBDiscountAdvertView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *advertImageView;
@property (weak, nonatomic) IBOutlet UILabel *advertLabel;

- (instancetype)init;

@end
