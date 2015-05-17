//
//  IHWebPageViewController.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 04.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "IHWebPageViewController.h"
#import "DBCardsViewController.h"
#import "IHPaymentManager.h"

@interface IHWebPageViewController () <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) IHPaymentManager *paymentManager;

@property (strong, nonatomic) NSString *screenName;

@end

@implementation IHWebPageViewController {
    NSDate *start;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView = [UIWebView new];
    self.webView.frame = self.view.bounds;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self setTitle:NSLocalizedString(@"Добавление карты", nil)];
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.webView.scrollView.scrollEnabled = YES;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.sourceUrl]]];
    self.paymentManager = [IHPaymentManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *controllers = self.navigationController.viewControllers;
    UIViewController *previousInStackVC;
    if([controllers count] > 1){
        previousInStackVC = controllers[[controllers count] - 2];
    }
    if(previousInStackVC && [previousInStackVC isKindOfClass:[DBCardsViewController class]]){
        DBCardsViewController *cardsVC = (DBCardsViewController *)previousInStackVC;
        if([cardsVC.screen isEqualToString:@"Cards_screen"]){
            self.screenName = @"Card_add_screen_settings";
        } else {
            self.screenName = @"Card_add_screen_payment";
        }
    }

    [GANHelper analyzeScreen:self.screenName];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //NSLog(@"%@", [request.URL absoluteString]);
    start = [NSDate date];
    if([[request.URL absoluteString] rangeOfString:@"return-page"].length > 0){
        BLOCK_SAFE_RUN(self.completionHandler, YES);
        self.completionHandler = nil;
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    long interval = (long)-[start timeIntervalSinceNow];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    BLOCK_SAFE_RUN(self.completionHandler, NO);
    self.completionHandler = nil;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

@end
