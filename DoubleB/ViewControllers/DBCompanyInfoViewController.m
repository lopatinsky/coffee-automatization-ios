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

#import <CoreImage/CoreImage.h>
#import <MessageUI/MessageUI.h>


@interface DBCompanyInfoViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *callUsView;
@property (weak, nonatomic) IBOutlet UIView *mailUsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonToTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation DBCompanyInfoViewController

static void (^dbMailViewControllerCallBack)(BOOL completed);

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.companyDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.companyDescriptionLabel alignLeading:@"8" trailing:@"-8" toView:self.view];
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    self.buttonToTopConstraint.constant = screenHeight - 146.f;
    
    self.navigationItem.title = NSLocalizedString(@"О компании", nil);
    [self setBackground];
    [self setContactUsViews];
    self.companyDescriptionLabel.text = @"as;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpigas;dfjaghpqergjhqnpdgjihqwpgiqjregp[qkijhgpjuirhuieegjhqpigjqpegpig";
}

- (void)mailUsGestureAction:(UITapGestureRecognizer *)sender {
    [self presentMailViewControllerWithRecipients:nil callback:nil];
}

- (void)callUsGestureAction:(UITapGestureRecognizer *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"+7 (123) 456-78-90" delegate:self cancelButtonTitle:@"Отменить" otherButtonTitles:@"Позвонить", nil];
    alert.delegate = self;
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 02 && buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:+71234567890"]];
    }
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
    [callUs smallBackgroundColourDefault];
    [callUs setText:@"ПОЗВОНИ НАМ"];
    [self.callUsView addSubview:callUs];
    UITapGestureRecognizer *callTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callUsGestureAction:)];
    callTapRecognizer.cancelsTouchesInView = NO;
    [self.callUsView addGestureRecognizer:callTapRecognizer];
    
    // Mail
    self.mailUsView.backgroundColor = [UIColor clearColor];
    DBContactUsView *mailUs = [[DBContactUsView alloc] init];
    [mailUs setIconImage:[UIImage imageNamed:@"email"]];
    [mailUs smallBackgroundColourDefault];
    [mailUs setText:@"НАПИШИ НАМ"];
    [self.mailUsView addSubview:mailUs];
    UITapGestureRecognizer *mailTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mailUsGestureAction:)];
    mailTapRecognizer.cancelsTouchesInView = NO;
    [self.mailUsView addGestureRecognizer:mailTapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
