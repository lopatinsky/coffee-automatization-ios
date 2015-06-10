//
//  HTMLViewController.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBHTMLViewController.h"

@interface DBHTMLViewController () <UIWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation DBHTMLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [GANHelper analyzeScreen:self.screen];
    
    if (self.file) {
        NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.file ofType:@"html"]
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        [self.webView loadHTMLString:html baseURL:nil];
    } else if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:CONFIDENCE_SCREEN];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *strUrl = request.URL.absoluteString;
    if ([strUrl rangeOfString:@"doubleb"].length > 0 && self.url != request.URL && navigationType == UIWebViewNavigationTypeLinkClicked) {
        DBHTMLViewController *controller = [DBHTMLViewController new];
        controller.url = request.URL;
        [self.navigationController pushViewController:controller animated:YES];
        return NO;
    }
    return YES;
}


@end
