//
//  DBMastercardPromoAboutViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBAboutPromoViewController.h"
#import "DBMastercardPromo.h"

@implementation DBAboutPromoViewController

- (void)viewDidLoad{
    self.title = NSLocalizedString(@"Об акции", nil);
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    int originY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, originY + 20, self.view.frame.size.width, 70)];
    imageView.image = [UIImage imageNamed:@"mcard_logo.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    CGRect rect = CGRectMake(5, imageView.frame.origin.y + imageView.frame.size.height, self.view.frame.size.width - 10, 0);
    rect.size.height = self.view.frame.size.height - rect.origin.y;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:rect];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSString *expDate = [dateFormatter stringFromDate:[DBMastercardPromo sharedInstance].promoEndDate];
    NSString *textAbout = [NSString stringWithFormat:NSLocalizedString(@"Привяжите карту MasterCard и получите скидку 50%% на первый напиток.\nРасплачивайтесь MasterCard  и каждый %d-ой напиток получайте в подарок.\n\nАкция действует до %@", nil), [DBMastercardPromo sharedInstance].promoMaxPointsCount + 1, expDate];
    
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.f];
    textLabel.text = textAbout;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    [self.view addSubview:textLabel];
}

@end
