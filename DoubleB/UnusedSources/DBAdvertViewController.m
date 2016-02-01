//
//  DBAdvertViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBAdvertViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DBAdvertViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *topImageImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *advertMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *advertIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *topSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertContainerTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertIconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertIconAndMessageSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constriantAdvertMessageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertTextAndBottomSeparatorSpace;

@property (strong, nonatomic) NSString *htmlText;
@property (strong, nonatomic) NSString *imageUrl;

@end

@implementation DBAdvertViewController

- (instancetype)initWithIcon:(NSString *)imageUrl htmlText:(NSString *)text{
    DBAdvertViewController *advertVC = [[DBAdvertViewController alloc] init];
    advertVC.htmlText = text;
    advertVC.imageUrl= imageUrl;
    
    return advertVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.confirmButton.layer.cornerRadius = 5.f;
    self.confirmButton.clipsToBounds = YES;
    
    [self.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure text
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithData:[self.htmlText dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                       documentAttributes:nil
                                                                    error:nil];
    
    NSRange range = NSMakeRange(0, 1);
    for(int index = 0; index < string.length; index++){
        id attribute = [string attribute:NSFontAttributeName atIndex:index effectiveRange:&range];
        
        NSString *fontName = ((UIFont *)attribute).fontName;
        
        // Bold font
        if([fontName rangeOfString:@"Bold"].location != NSNotFound){
            [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.f] range:range];
        } else {
            [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:14.f] range:range];
        }
    }
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:15.f];
    self.advertMessageLabel.attributedText = string;
    self.advertMessageLabel.textAlignment = NSTextAlignmentCenter;
    
    CGRect rect = [self.advertMessageLabel.text boundingRectWithSize:CGSizeMake(self.advertMessageLabel.frame.size.width, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName: font}
                                                                context:nil];
    self.constriantAdvertMessageHeight.constant = (int)rect.size.height;
    
    
    // Configure Icon
    if(self.imageUrl){
        [self.advertIconImageView setImageWithURL:[NSURL URLWithString:self.imageUrl]];
    } else {
        self.advertIconImageView.hidden = YES;
        self.constraintAdvertIconHeight.constant = 0;
        self.constraintAdvertIconAndMessageSpace.constant = 0;
    }
    
    // Configure Alignment
    int screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    int spaceHeight = screenHeight - 10 - self.confirmButton.frame.size.height - self.topImageImageView.frame.size.height;
    int advertHeight = self.advertMessageLabel.frame.origin.y + rect.size.height + self.constraintAdvertTextAndBottomSeparatorSpace.constant + self.bottomSeparatorView.frame.size.height - self.topSeparatorView.frame.origin.y;
    int spaceSize = spaceHeight - advertHeight;
    self.constraintAdvertContainerTopSpace.constant = (int)(spaceSize / 2);
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)closeButtonClick:(id)sender{
    [self.delegate dbAdvertViewControllerUserDidClose:self];
}

- (IBAction)confirmButtonClick:(id)sender{
    [self.delegate dbAdvertViewControllerUserDidClose:self];
}

@end
