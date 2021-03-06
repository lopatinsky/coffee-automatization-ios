//
//  ReviewViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 17/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ReviewViewController.h"
#import "RatingBarView.h"
#import "DBAPIClient.h"

#import "GANHelper.h"

@interface ReviewViewController () <UITextViewDelegate, RatingBarViewDelegate>

@property (nonatomic, strong) NSString *orderId;

@property (weak, nonatomic) IBOutlet UIView *serviceView;
@property (weak, nonatomic) IBOutlet RatingBarView *serviceRatingBarView;
@property (weak, nonatomic) IBOutlet UILabel *serviceLabel;

@property (weak, nonatomic) IBOutlet UIView *foodView;
@property (weak, nonatomic) IBOutlet RatingBarView *foodRatingBarView;
@property (weak, nonatomic) IBOutlet UILabel *foodLabel;

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (nonatomic) BOOL cancelWithoutAnalytics;

@end

@implementation ReviewViewController


- (void)viewDidLoad{
    [self setTitle:@"Оцените заказ"];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.serviceRatingBarView.backgroundColor = [UIColor clearColor];
    self.serviceRatingBarView.notSelectedImage = [UIImage imageNamed:@"star_rate_inactive_icon.png"];
    self.serviceRatingBarView.fullSelectedImage = [UIImage imageNamed:@"star_rate_icon.png"];
    self.serviceRatingBarView.rating = 0;
    self.serviceRatingBarView.maxRating = 5;
    self.serviceRatingBarView.editable = YES;
    self.serviceRatingBarView.delegate = self;
    
    self.foodRatingBarView.backgroundColor = [UIColor clearColor];
    self.foodRatingBarView.notSelectedImage = [UIImage imageNamed:@"star_rate_inactive_icon.png"];
    self.foodRatingBarView.fullSelectedImage = [UIImage imageNamed:@"star_rate_icon.png"];
    self.foodRatingBarView.rating = 0;
    self.foodRatingBarView.maxRating = 5;
    self.foodRatingBarView.editable = YES;
    self.foodRatingBarView.delegate = self;
    
    self.commentTextView.delegate = self;
    
    [self setupCancelButton];
    [self setupDoneButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [GANHelper analyzeScreen:@"Review_screen"];
}

- (void)setupCancelButton{
    UIButton *button = [UIButton new];
    button.contentEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSString *title = @"Отменить";
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: font}];
    button.frame = CGRectMake(0, 0, size.width, 35);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [button addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickCancel {
    if (self.cancelWithoutAnalytics) {
        NSString *label = [NSString stringWithFormat:@"food: %d service: %d comment: %@", (int)self.foodRatingBarView.rating, (int)self.serviceRatingBarView.rating, self.commentTextView.text];
        [GANHelper analyzeEvent:@"cancel_click" label:label category:@"Review_screen"];
        self.cancelWithoutAnalytics = NO;
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupDoneButton{
    UIButton *button = [UIButton new];
    button.contentEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSString *title = @"Отправить";
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: font}];
    button.frame = CGRectMake(0, 0, size.width, 35);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [button addTarget:self action:@selector(clickDone) forControlEvents:UIControlEventTouchUpInside];
    
    [self reloadDoneButton];
}

- (void)reloadDoneButton {
    if(self.serviceRatingBarView.rating > 0 && self.foodRatingBarView.rating > 0){
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.customView.alpha = 1.f;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.customView.alpha = 0.5f;
    }
}

- (void)clickDone{
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *label = [NSString stringWithFormat:@"food: %d service: %d comment: %@", (int)self.foodRatingBarView.rating, (int)self.serviceRatingBarView.rating, self.commentTextView.text];
    [GANHelper analyzeEvent:@"send_click" label:label category:@"Review_screen"];
    
    [self sendReview:^(BOOL success) {
        if(success){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [GANHelper analyzeEvent:@"send_review_ok" label:label category:@"Review_screen"];
            self.cancelWithoutAnalytics = YES;
            [self clickCancel];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [GANHelper analyzeEvent:@"send_review_failed" label:label category:@"Review_screen"];
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Не удалось отправить ваш отзыв, пожалуйста, попробуйте еще раз" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil] show];
        }
    }];
}

- (void)sendReview:(void(^)(BOOL success))callback{
    [[DBAPIClient sharedClient] POST:@"review"
                          parameters:@{@"order_id": self.orderId,
                                       @"meal_rate": @(self.foodRatingBarView.rating),
                                       @"service_rate": @(self.serviceRatingBarView.rating),
                                       @"comment": self.commentTextView.text}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                if (callback)
                                    callback(YES);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                if (callback)
                                    callback(NO);
                            }];
}

#pragma mark - RatingBarViewDelegate

- (void)rateView:(RatingBarView *)rateView ratingDidChange:(float)rating{
    [self reloadDoneButton];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
}

- (void)textViewDidEndEditing:(UITextView *)textView{
}

#pragma mark - ReviewViewControllerProtocol
- (void)setOrderId:(NSString *)orderId {
    _orderId = orderId;
}

@end
