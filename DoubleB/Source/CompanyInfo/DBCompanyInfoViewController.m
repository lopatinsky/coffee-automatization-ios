//
//  DBCompanyInfoViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 16.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCompanyInfoViewController.h"
#import "Venue.h"
#import "DBTextResourcesHelper.h"
#import "DBContactUsView.h"
#import "UIViewController+DBMessage.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"

#import <CoreImage/CoreImage.h>
#import <MessageUI/MessageUI.h>


@interface DBCompanyInfoViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *companyDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *callUsView;
@property (weak, nonatomic) IBOutlet UIView *mailUsView;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWebSiteTopSpace;

@property (nonatomic, strong) NSArray *phoneNumbers;

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
    if ([self.phoneNumbers count] > 1) {
        UIActionSheet *phoneSheet = [UIActionSheet bk_actionSheetWithTitle:NSLocalizedString(@"Номера телефонов", nil)];
        for (NSString *number in self.phoneNumbers) {
            [phoneSheet bk_addButtonWithTitle:number handler:^{
                [UIAlertView bk_showAlertViewWithTitle:nil message:number
                                     cancelButtonTitle:NSLocalizedString(@"Отменить", nil)
                                     otherButtonTitles:@[NSLocalizedString(@"Позвонить", nil)]
                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        NSString *phone = [NSString stringWithFormat:@"tel:+%@", number];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
                    }
                }];
            }];
        }
        [phoneSheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Отменить", nil) handler:^{
            
        }];
        [phoneSheet showInView:self.view];
    } else {
        [UIAlertView bk_showAlertViewWithTitle:nil message:[DBCompanyInfo sharedInstance].phoneNumber cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:@[NSLocalizedString(@"Позвонить", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *phone = [NSString stringWithFormat:@"tel:+%@", [DBCompanyInfo sharedInstance].phoneNumber];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
            }
        }];
    }
}

- (void)websiteButtonClick {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[DBCompanyInfo sharedInstance].webSiteUrl]];
}

- (void)setBackground {
    UIImage *backImage = [UIImage imageNamed:[DBTextResourcesHelper db_bgImageName]];
    self.backgroundImageView.image = backImage;
}

- (void)setContactUsViews {
    // Call
    self.phoneNumbers = [[DBCompanyInfo sharedInstance].phoneNumber componentsSeparatedByString:@","];
    self.callUsView.backgroundColor = [UIColor clearColor];
    DBContactUsView *callUs = [[DBContactUsView alloc] init];
    [callUs setIconImage:[UIImage imageNamed:@"call"]];
    [callUs setText:NSLocalizedString(@"Позвонить нам", nil).uppercaseString];
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
    [mailUs setText:NSLocalizedString(@"Написать нам", nil).uppercaseString];
    UITapGestureRecognizer *mailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mailUsGestureAction:)];
    mailTapRecognizer.cancelsTouchesInView = NO;
    [self.mailUsView addGestureRecognizer:mailTapRecognizer];
    
    [self.mailUsView addSubview:mailUs];
    mailUs.translatesAutoresizingMaskIntoConstraints = NO;
    [mailUs alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.mailUsView];
}

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"aboutCompany";
    settingsItem.iconName = @"about_icon";
    settingsItem.title = NSLocalizedString(@"О компании", nil);
    settingsItem.eventLabel = @"about_click";
    settingsItem.viewController = [DBCompanyInfoViewController new];
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}

@end
