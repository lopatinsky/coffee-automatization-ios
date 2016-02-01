//
//  DBWebViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBWebViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface DBWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation DBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self db_setTitle:self.title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect webViewRect = CGRectMake(screenBounds.origin.x, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
    _webView = [[UIWebView alloc] initWithFrame:webViewRect];
    [self.view addSubview:_webView];
    [self displayURL:[NSURL URLWithString:self.urlString]];
}

- (void)displayURL:(NSURL *)URL {
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

#pragma Mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

@end
