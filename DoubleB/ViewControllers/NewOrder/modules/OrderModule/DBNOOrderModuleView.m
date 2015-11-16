//
//  DBNOOrderModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOOrderModuleView.h"
#import "UIView+RoundedCorners.h"
#import "OrderCoordinator.h"
#import "NetworkManager.h"
#import "DBClientInfo.h"

@interface DBNOOrderModuleView ()
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) NSInteger activeTasks;

@end

@implementation DBNOOrderModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOOrderModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.orderButton setRoundedCorners];
    [self.orderButton setTitle:NSLocalizedString(@"Заказать", nil) forState:UIControlStateNormal];
    [self.orderButton addTarget:self action:@selector(clickOrderButton) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *events = @[CoordinatorNotificationNewDeliveryType, CoordinatorNotificationNewSelectedTime, CoordinatorNotificationNewPaymentType, CoordinatorNotificationNewVenue, CoordinatorNotificationNewShippingAddress, CoordinatorNotificationNDAAccept];
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPaths:events selector:@selector(reload)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAnimating) name:kDBConcurrentOperationCheckOrderSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAnimating) name:kDBConcurrentOperationCheckOrderFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimating) name:kDBConcurrentOperationCheckOrderStarted object:nil];
}

- (void)viewWillAppearOnVC {
    [self reload:NO];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if (_activeTasks == 0) {
        if (![OrderCoordinator sharedInstance].validOrder) {
            self.errorLabel.hidden = NO;
            self.errorLabel.text = [OrderCoordinator sharedInstance].orderErrorReason;
            
            self.orderButton.hidden = YES;
            
            self.backgroundColor = [UIColor colorWithRed:155./255 green:155./255 blue:155./255 alpha:0.7f];
        } else {
            self.errorLabel.hidden = YES;
            self.orderButton.hidden = NO;
            [self reloadOrderButton];
            
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7f];
        }
    } else {
        self.errorLabel.hidden = YES;
        self.orderButton.hidden = YES;
        self.backgroundColor = [UIColor colorWithRed:155./255 green:155./255 blue:155./255 alpha:0.7f];
    }
}

- (void)reloadOrderButton {
    if (![OrderCoordinator sharedInstance].validOrder) {
        self.orderButton.backgroundColor = [UIColor db_grayColor];
        self.orderButton.alpha = 0.5f;
    } else {
        self.orderButton.backgroundColor = [UIColor db_defaultColor];
        self.orderButton.alpha = 1;
    }
}

- (void)startAnimating{
    _activeTasks += 1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
        [self reload:YES];
    });
}

- (void)endAnimating{
    _activeTasks -= 1;
    if (_activeTasks <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            [self reload:YES];
        });
        
    }
}

- (void)clickOrderButton {
    [GANHelper analyzeEvent:@"order_button_click" category:ORDER_SCREEN];
}

@end
