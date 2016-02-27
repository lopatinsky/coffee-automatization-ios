//
//  PopupNewsViewController.m
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import "PopupNewsViewController.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+PINRemoteImage.h"

@interface PopupNewsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *popupTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *popupImageView;
@property (weak, nonatomic) IBOutlet UITextView *popupTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@property (strong, nonatomic) NSDictionary *data;

@end

@implementation PopupNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.popupImageView.clipsToBounds = YES;
    self.okButton.backgroundColor = [UIColor db_defaultColor];
    self.okButton.layer.cornerRadius = 5.;
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self.data[@"title"] isEqualToString:@""]) {
        self.titleHeightConstraint.constant = 0;
        self.popupTitleLabel.hidden = YES;
    } 
    
    self.popupTextLabel.text = self.data[@"text"];
    self.popupTitleLabel.text = self.data[@"title"];
    if ([self.data objectForKey:@"image_url"]) {
        [self.popupImageView sd_setImageWithURL:[NSURL URLWithString:[self.data objectForKey:@"image_url"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
}

#pragma mark - PopupNewsViewControllerProtocol
- (void)setData:(NSDictionary *)data {
    _data = data;
}

@end
