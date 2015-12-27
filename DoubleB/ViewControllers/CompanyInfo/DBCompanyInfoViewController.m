//
//  DBCompanyInfoViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 16.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfoViewController.h"
#import "Venue.h"
#import "DBContactUsView.h"
#import "UIViewController+DBMessage.h"
#import "UIAlertView+BlocksKit.h"

#import <CoreImage/CoreImage.h>
#import <MessageUI/MessageUI.h>


@interface DBCompanyInfoViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *callUsView;
@property (weak, nonatomic) IBOutlet UIView *mailUsView;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWebSiteTopSpace;

@end

@implementation DBCompanyInfoViewController

static void (^dbMailViewControllerCallBack)(BOOL completed);

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.companyDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.companyDescriptionLabel alignLeading:@"8" trailing:@"-8" toView:self.view];
    
    float screenHeight = [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    self.constraintWebSiteTopSpace.constant = screenHeight - self.websiteButton.frame.size.height - 5;
    
    [self db_setTitle:NSLocalizedString(@"О компании", nil)];
    
    [self setBackground];
    [self setContactUsViews];
    
    NSString *imageName = [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] lastObject];
    self.logoImageView.image = [UIImage imageNamed:imageName];
    self.logoImageView.layer.cornerRadius = 5.;
    self.logoImageView.clipsToBounds = YES;
    
    self.companyNameLabel.text = [DBCompanyInfo sharedInstance].applicationName;
    self.companyDescriptionLabel.text = [DBCompanyInfo sharedInstance].companyDescription;
    
    [self.websiteButton setTitle:[DBCompanyInfo sharedInstance].webSiteUrl forState:UIControlStateNormal];
    [self.websiteButton addTarget:self action:@selector(websiteButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)mailUsGestureAction:(UITapGestureRecognizer *)sender {
    [self presentMailViewControllerWithRecipients:nil callback:nil];
}

- (void)callUsGestureAction:(UITapGestureRecognizer *)sender {
    [UIAlertView bk_showAlertViewWithTitle:nil message:[DBCompanyInfo sharedInstance].phoneNumber cancelButtonTitle:@"Отменить" otherButtonTitles:@[@"Позвонить"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *phone = [NSString stringWithFormat:@"tel:+%@", [DBCompanyInfo sharedInstance].phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
        }
    }];
}

- (void)websiteButtonClick {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[DBCompanyInfo sharedInstance].webSiteUrl]];
}

- (void)setBackground {
    float screenHeight = [UIScreen mainScreen].nativeBounds.size.height;
    UIImage *backImage = [UIImage imageNamed:[NSString stringWithFormat:@"bg%.0f.jpg", screenHeight]];
    if (backImage) {
        self.backgroundImageView.image = backImage;
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"bg.jpg"];
    }
}

- (void)setContactUsViews {
    // Call
    self.callUsView.backgroundColor = [UIColor clearColor];
    DBContactUsView *callUs = [[DBContactUsView alloc] init];
    [callUs setIconImage:[UIImage imageNamed:@"call"]];
    [callUs setText:@"ПОЗВОНИТЬ НАМ"];
    UITapGestureRecognizer *callTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callUsGestureAction:)];
    callTapRecognizer.cancelsTouchesInView = NO;
    [self.callUsView addGestureRecognizer:callTapRecognizer];
    
    [self.callUsView addSubview:callUs];
    callUs.translatesAutoresizingMaskIntoConstraints = NO;
    [callUs alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.callUsView];
    
    // Mail
    self.mailUsView.backgroundColor = [UIColor clearColor];
    DBContactUsView *mailUs = [[DBContactUsView alloc] init];
    [mailUs setIconImage:[UIImage imageNamed:@"email"]];
    [mailUs setText:@"НАПИСАТЬ НАМ"];
    UITapGestureRecognizer *mailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mailUsGestureAction:)];
    mailTapRecognizer.cancelsTouchesInView = NO;
    [self.mailUsView addGestureRecognizer:mailTapRecognizer];
    
    [self.mailUsView addSubview:mailUs];
    mailUs.translatesAutoresizingMaskIntoConstraints = NO;
    [mailUs alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.mailUsView];
}

@end
