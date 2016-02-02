//
//  DBMPOrderModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMPOrderModuleView.h"
#import "DBPositionBalanceView.h"
#import "DBMenuPosition.h"

#import "OrderCoordinator.h"
#import "DBModulesManager.h"
#import "DBMenu.h"

#import "UIViewController+DBPopupContainer.h"
#import "UIView+RoundedCorners.h"

@interface DBMPOrderModuleView ()
@property (weak, nonatomic) UIView *balanceHolderView;
@property (weak, nonatomic) UILabel *balanceLabel;

@property (weak, nonatomic) UIView *orderHolderView;
@property (weak, nonatomic) UIView *orderView;
@property (weak, nonatomic) UILabel *orderLabel;
@property (weak, nonatomic) UILabel *priceLabel;
@property (weak, nonatomic) UIView *separatorView;

@property (strong, nonatomic) DBPositionBalanceView *balanceView;

@property (strong, nonatomic) NSArray *balance;
@end

@implementation DBMPOrderModuleView

+ (DBMPOrderModuleView *)create {
    DBMPOrderModuleView *view;
    
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypePositionBalances]) {
        view = [[[NSBundle mainBundle] loadNibNamed:@"DBMPOrderBalanceModuleView" owner:self options:nil] firstObject];
    } else {
        view = [[[NSBundle mainBundle] loadNibNamed:@"DBMPOrderModuleView" owner:self options:nil] firstObject];
    }
    
    return view;
}

- (void)awakeFromNib {
    self.balanceHolderView = [self viewWithTag:2];
    self.balanceLabel = [self.balanceHolderView viewWithTag:21];
    
    self.orderHolderView = [self viewWithTag:1];
    self.orderView = [self.orderHolderView viewWithTag:11];
    self.priceLabel = [self.orderView viewWithTag:111];
    self.orderLabel = [self.orderView viewWithTag:112];
    self.separatorView = [self.orderView viewWithTag:113];
    
    
    self.backgroundColor = [UIColor db_defaultColorWithAlpha:0.9];
    
    self.balanceLabel.layer.cornerRadius = 6.f;
    self.balanceLabel.layer.borderWidth = 1.f;
    self.balanceLabel.layer.borderColor = self.balanceLabel.textColor.CGColor;
    self.balanceLabel.layer.masksToBounds = YES;
    
    self.orderView.layer.cornerRadius = 6.f;
    self.orderView.layer.masksToBounds = YES;
    
    self.priceLabel.textColor = [UIColor db_defaultColor];
    self.orderLabel.textColor = [UIColor db_defaultColor];
    self.separatorView.backgroundColor = [UIColor db_defaultColor];
    
    @weakify(self)
    [self.balanceHolderView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self balanceClick];
    }]];
    
    [self.orderHolderView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self orderClick];
    }]];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.actualPrice, [Compatibility currencySymbol]];
}

- (void)setPosition:(DBMenuPosition *)position {
    _position = position;
    
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypePositionBalances]) {
        [[DBMenu sharedInstance] updatePositionBalance:self.position callback:^(BOOL success, NSArray *balance) {
            self.balance = balance;
        }];
    }
    
    [self reload:NO];
}

- (void)balanceClick {
    self.balanceView = [DBPositionBalanceView new];
    self.balanceView.mode = DBPositionBalanceViewModeBalance;
    self.balanceView.position = self.position;
    self.balanceView.balance = self.balance;

    [self.balanceView reload];
    [self.ownerViewController presentView:self.balanceView];
}

- (void)orderClick {
    [GANHelper analyzeEvent:@"product_price_click" label:[NSString stringWithFormat:@"%f", self.position.actualPrice] category:PRODUCT_SCREEN];
    
    void (^addBlock)() = ^void() {
        UIView *view = [[UIView alloc] initWithFrame:self.orderView.frame];
        [view setRoundedCorners];
        view.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:view];
        
        self.orderView.alpha = 0;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         }
                         completion:^(BOOL finished) {
                             [view removeFromSuperview];
                             
                             [[OrderCoordinator sharedInstance].itemsManager addPosition:self.position];
                         }];
        
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.alpha = 0;
                             self.orderView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [view removeFromSuperview];
                         }];
    };
    
    if ([[DBModulesManager sharedInstance] moduleEnabled:DBModuleTypePositionBalances] && ![self positionAvailable]) {
        self.balanceView = [DBPositionBalanceView new];
        self.balanceView.mode = DBPositionBalanceViewModeChooseVenue;
        self.balanceView.position = self.position;
        self.balanceView.balance = self.balance;
        
        self.balanceView.venueSelectedBlock = ^void(Venue *venue) {
            [OrderCoordinator sharedInstance].orderManager.venue = venue;
            addBlock();
        };
        
        [self.balanceView reload];
        [self.ownerViewController presentView:self.balanceView];
    } else {
        addBlock();
    }
}

- (BOOL)positionAvailable {
    BOOL available = NO;
    for (DBMenuPositionBalance *balance in self.balance) {
        if (balance.venue == [OrderCoordinator sharedInstance].orderManager.venue) {
            available = YES;
        }
    }
    
    return available;
}

@end