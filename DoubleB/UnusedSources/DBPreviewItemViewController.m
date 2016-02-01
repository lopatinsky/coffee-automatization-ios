//
//  DBPreviewItemViewController.m
//  DoubleB
//
//  Created by Ощепков Иван on 18.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPreviewItemViewController.h"

#import <BlocksKit/UIControl+BlocksKit.h>
#import "MenuHelper.h"

@interface DBPreviewItemViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIButton *addCardButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *noInternetLabel;

@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL finalViewController;
@end

@implementation DBPreviewItemViewController

- (instancetype)initWithImage:(UIImage *)image final:(BOOL)final{
    self = [super init];
    
    self.image = image;
    self.finalViewController = final;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.previewImageView.backgroundColor = [UIColor clearColor];
    
    self.previewImageView.image = self.image;
    if (!self.finalViewController) {
        self.addCardButton.hidden = YES;
        self.skipButton.hidden = YES;
    } else {
        [self.addCardButton setTitleColor:[UIColor db_blueColor] forState:UIControlStateNormal];
        self.addCardButton.layer.cornerRadius = self.addCardButton.frame.size.height / 2;
        self.addCardButton.layer.masksToBounds = YES;
        
        @weakify(self)
        [self.addCardButton bk_addEventHandler:^(id sender) {
            @strongify(self)
            if([self.delegate respondsToSelector:@selector(db_previewItemDidChooseBindCard:)]){
                [self.delegate db_previewItemDidChooseBindCard:self];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self.skipButton bk_addEventHandler:^(id sender) {
            @strongify(self)
            if([self.delegate respondsToSelector:@selector(db_previewItemDidChooseSkipBinding:)]){
                [self.delegate db_previewItemDidChooseSkipBinding:self];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(self.finalViewController){
        self.noInternetLabel.layer.cornerRadius = self.noInternetLabel.frame.size.height / 2;
        self.noInternetLabel.layer.masksToBounds = YES;
        self.noInternetLabel.textColor = [UIColor db_blueColor];
        self.noInternetLabel.text = NSLocalizedString(@"NoInternetConnectionErrorMessage", nil);
        self.noInternetLabel.hidden = YES;
        
        @weakify(self)
        [self.noInternetLabel addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            @strongify(self)
            [self updateViewConfig];
        }]];
        self.noInternetLabel.userInteractionEnabled = YES;
    } else {
        self.noInternetLabel.hidden = YES;
    }
    
    if([UIScreen mainScreen].bounds.size.height == 480){
        // resize image on iPhone 4/4s
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.previewImageView.contentMode = UIViewContentModeCenter;
    }
    
    if(self.finalViewController){
        [self updateViewConfig];
    }
}

- (void)updateViewConfig{
    NSNumber *shouldBindCardStored = [[NSUserDefaults standardUserDefaults] objectForKey:kDBBindingNecessaryForAuthorization];
    if(shouldBindCardStored)
        self.skipButton.hidden = [shouldBindCardStored boolValue];
    else
        self.skipButton.hidden = YES;
    
    [[MenuHelper sharedHelper] fetchMenuAndGetPreviewFlag:^(BOOL shouldBindCard, NSError *error) {
        if(!error){
            self.addCardButton.hidden = NO;
            self.skipButton.hidden = shouldBindCard;
            self.noInternetLabel.hidden = YES;
        } else {
            if(!shouldBindCardStored){
                self.addCardButton.hidden = YES;
                self.skipButton.hidden = YES;
                self.noInternetLabel.hidden = NO;
            }
        }
    }];
}


@end
