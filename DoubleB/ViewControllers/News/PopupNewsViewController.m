//
//  PopupNewsViewController.m
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import "PopupNewsViewController.h"

#import "UIImageView+WebCache.h"

@interface PopupNewsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *popupImageView;
@property (weak, nonatomic) IBOutlet UILabel *popupTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) NSDictionary *data;

@end

@implementation PopupNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.popupImageView.clipsToBounds = YES;
    self.popupImageView.layer.cornerRadius = 70.;
    
    self.okButton.backgroundColor = [UIColor db_defaultColor];
    self.okButton.layer.cornerRadius = 5.;
}

- (void)viewWillAppear:(BOOL)animated {
    self.popupTextLabel.text = self.data[@"text"];
    if ([self.data objectForKey:@"image_url"]) {
        [self.popupImageView sd_setImageWithURL:[NSURL URLWithString:[self.data objectForKey:@"image_url"]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - PopupNewsViewControllerProtocol
- (void)setData:(NSDictionary *)data {
    _data = data;
}

@end
