//
//  IHBarButtonItem.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 19.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBBarButtonItem.h"
#import "OrderManager.h"

@interface DBBarButtonItem ()
@property (strong, nonatomic) OrderManager *orderManager;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation DBBarButtonItem

-(instancetype)initWithViewController:(UIViewController *)viewController action:(SEL)action{
    UIButton *buttonOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOrder setTitleColor:[UIColor db_defaultColor]
                      forState:UIControlStateNormal];
    buttonOrder.frame = CGRectMake(0, 0, 1, 26);
    
    int imageSize = 16;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (buttonOrder.frame.size.height - imageSize) / 2, imageSize, imageSize)];
    [self.imageView templateImageWithName:@"orders_icon.png" tintColor:[UIColor whiteColor]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.frame.size.width, 0, 1, buttonOrder.frame.size.height)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.f];
    
    [buttonOrder addSubview:self.imageView];
    [buttonOrder addSubview:self.titleLabel];
    [buttonOrder addTarget:viewController action:action forControlEvents:UIControlEventTouchUpInside];

    self = [super initWithCustomView:buttonOrder];
    
    self.orderManager = [OrderManager sharedManager];
    [self.orderManager addObserver:self forKeyPath:@"mixedTotalPrice"
                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                           context:nil];
    
    [self update];
    return self;
}

-(void)dealloc{
    [self.orderManager removeObserver:self forKeyPath:@"mixedTotalPrice"];
}

-(NSAttributedString *)attributedStringWithCount:(NSInteger)count withTotalPrice:(double)totalPrice{
    NSString *price = [NSString stringWithFormat:@"%.0fр.", totalPrice];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:
                                         [NSString stringWithFormat:@" | %@", price]];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.f]
                   range:NSMakeRange(0, [string.string length])];
    return string;
}

-(void)update{
    UIButton *button = (UIButton *)self.customView;
    NSAttributedString *string = [self attributedStringWithCount:self.orderManager.positionsCount
                                                  withTotalPrice:self.orderManager.mixedTotalPrice];
    [self.titleLabel setAttributedText:string];
    
    CGRect newTitleRect = self.titleLabel.frame;
    newTitleRect.size.width = string.size.width + 5;
    self.titleLabel.frame = newTitleRect;
    
    CGRect newButtonRect = button.frame;
    newButtonRect.size.width = self.imageView.frame.size.width + self.titleLabel.frame.size.width;
    button.frame = newButtonRect;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context{
    if([keyPath isEqualToString:@"mixedTotalPrice"]){
        [self update];
    }
}

@end
