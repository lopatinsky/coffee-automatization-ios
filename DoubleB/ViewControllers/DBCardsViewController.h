//
//  DBCardsViewController.h
//  DoubleB
//
//  Created by Sergey Pronin on 8/1/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CardsViewControllerMode) {
    CardsViewControllerModeManageCards = 0,
    CardsViewControllerModeChoosePayment
};

@class DBCardsViewController;
@protocol DBCardsViewControllerDelegate <NSObject>
- (void)cardsControllerDidChoosePaymentItem:(DBCardsViewController *)controller;
@end

@interface DBCardsViewController : UIViewController

@property (nonatomic) CardsViewControllerMode mode;
@property (weak, nonatomic) id<DBCardsViewControllerDelegate> delegate;

@end
