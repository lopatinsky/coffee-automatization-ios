//
//  IHBarButtonItem.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 19.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBBarButtonItem.h"
#import "DBOrderBarButtonView.h"
#import "OrderManager.h"

@interface DBBarButtonItem ()
@property (strong, nonatomic) OrderManager *orderManager;

@property (strong, nonatomic) DBOrderBarButtonView *orderView;
@end

@implementation DBBarButtonItem

-(instancetype)initWithViewController:(UIViewController *)viewController
                     action:(SEL)action{
    UIButton *buttonOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOrder setTitleColor:[UIColor db_defaultColor]
                      forState:UIControlStateNormal];
    buttonOrder.frame = CGRectMake(0, 0, 1, 26);
    [buttonOrder addTarget:viewController action:action forControlEvents:UIControlEventTouchUpInside];
    
    self.orderView = [DBOrderBarButtonView new];
    self.orderView.userInteractionEnabled = NO;
    self.orderView.exclusiveTouch = NO;
    [buttonOrder addSubview:self.orderView];
    self.orderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.orderView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:buttonOrder];
    
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
    [self.orderView.totalLabel setAttributedText:string];
    
    CGRect newTitleRect = self.orderView.totalLabel.frame;
    newTitleRect.size.width = string.size.width + 5;
    
    CGRect newButtonRect = button.frame;
    newButtonRect.size.width = self.orderView.orderImageView.frame.size.width + newTitleRect.size.width;
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
