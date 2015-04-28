//
//  SharePermissionViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBSharePermissionViewController.h"
#import "UIViewController+ShareExtension.h"
#import "UIViewController+DBMessage.h"
#import "DBShareHelper.h"

@interface DBSharePermissionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *permissionLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *contactUsButton;

@property (strong, nonatomic) NSString *screen;
@end

@implementation DBSharePermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screen = @"Share_screen";
    
    self.closeButton.imageView.image = [UIImage imageNamed:@"close_gray.png"];
    
    [self.shareButton setBackgroundColor:[UIColor db_blueColor]];
    self.shareButton.layer.cornerRadius = 5;
    [self.shareButton setTitle:NSLocalizedString(@"Рассказать", nil) forState:UIControlStateNormal];
    
    [self.contactUsButton setBackgroundColor:[UIColor db_grayColor]];
    self.contactUsButton.layer.cornerRadius = 5;
    [self.contactUsButton setTitle:NSLocalizedString(@"Написать нам", nil) forState:UIControlStateNormal];
    
    
    [self.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactUsButton addTarget:self action:@selector(contactUsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *titleText = [DBShareHelper sharedInstance].titleShareScreen;
    NSString *permissionText = [DBShareHelper sharedInstance].textShareScreen;
    self.titleLabel.attributedText = [titleText attributedStringWithBoldKeyWordsWithFontSize:self.titleLabel.font.pointSize];
    self.permissionLabel.attributedText = [permissionText attributedStringWithBoldKeyWordsWithFontSize:self.permissionLabel.font.pointSize];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.shareImageView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.5 constant:0]];
}

- (void)viewDidAppear:(BOOL)animated{
    [GANHelper analyzeScreen:self.screen];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)closeButtonClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareButtonClick:(id)sender{
    [self shareSuccessfulOrder:^(BOOL completed) {
        if(completed){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)contactUsButtonClick:(id)sender{    
    [self presentMailViewControllerWithRecipients:nil callback:^(BOOL completed) {
        if(completed)
            [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
